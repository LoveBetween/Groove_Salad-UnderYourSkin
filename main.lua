local static_values = require("./static_values")
local plugin_path = _ENV["!plugins_mod_folder_path"]
local plugin_data_path = _ENV["!plugins_data_mod_folder_path"]
local sprite_cache_path = path.combine(plugin_data_path, "sprite_cache")
local config_path = path.combine(paths.config(), "Groove_Salad-UnderYourSkin.cfg")

local exists, config = pcall(toml.decodeFromFile, config_path)
if not exists then
    log.info("Generating config file")
    config = {
        use_sprite_cache = false
    }
    pcall(toml.encodeToFile, config, config_path)
end

local asset_name_overrides = {}

gm.post_script_hook(gm.constants.asset_get_index, function(self, other, result, args)
    local asset_name = args[1].value
    if asset_name_overrides[asset_name] ~= nil then
        result.value = asset_name_overrides[asset_name]
    end
end)

--[[
local function get_color_info(color)
    return {
        color = color, hue = gm.colour_get_hue(color), saturation = gm.colour_get_saturation(color), value = gm.colour_get_value(color),
        b = (color >> 16) & 0xFF,
        g = (color >> 8) & 0xFF,
        r = color & 0xFF 
    }
end
]]

---@alias color integer

---@param target color
---@param options color[]
---@return integer
---@return boolean
local function find_closest_color(target, options)
    local best_dif = math.huge
    local result_index = -1
    local target_r = target & 0xFF
    local target_g = (target >> 8) & 0xFF
    local target_b = (target >> 16) & 0xFF
    for index, color in ipairs(options) do
        if color == target then
            return index, true
        end
        local r = color & 0xFF
        local r_mean = (r + target_r) // 2
        local R = r - target_r
        local G = ((color >> 8) & 0xFF) - target_g
        local B = ((color >> 16) & 0xFF) - target_b
        --fast rgb comparison https://stackoverflow.com/questions/9018016/how-to-compare-two-colors-for-similarity-difference
        local dif = (((512 + r_mean) * R * R) >> 8) + 4 * G * G + (((767 - r_mean) * B * B) >> 8)
        if dif < best_dif then
            best_dif = dif
            result_index = index
        end
    end
    return result_index, false
end

---@param base_colors color[]
---@param palettes_colors table<integer, color[]>
---@param palette_swapped_colors table<color, color[]>
---@param base_sprite number
---@param sub_image_start_index integer
---@param sub_image_count integer
---@param palettes_count integer
---@param cull_sub_images integer
---@param cull_top_pixels integer
---@param cull_bottom_pixels integer
---@param cull_side_pixels integer
---@param cull_colors_set color[]
---@param color_overrides table<color, integer>
---@return table
local function generate_palette_swapped_sprites(base_colors, palettes_colors, palette_swapped_colors, base_sprite, sub_image_start_index, sub_image_count, palettes_count,
    cull_sub_images, cull_top_pixels, cull_bottom_pixels, cull_side_pixels, cull_colors_set, color_overrides)
    local sprite_w = gm.sprite_get_width(base_sprite)
    local sprite_h = gm.sprite_get_height(base_sprite)
    local surface_w = sprite_w * palettes_count
    local surface_h = sprite_h * sub_image_count
    local x_offset = gm.sprite_get_xoffset(base_sprite)
    local y_offset = gm.sprite_get_yoffset(base_sprite)
    local sprites_surface = gm.surface_create(surface_w, surface_h);
    gm.surface_set_target(sprites_surface)
    for palette_index = 0, palettes_count - 1 do
        for sub_image = 0, sub_image_count - 1 do
            gm.draw_sprite(base_sprite, sub_image_start_index + sub_image, (palette_index * sprite_w) + x_offset, (sub_image * sprite_h) + y_offset)
        end
    end
    gm.surface_reset_target();
    local buffer = gm.buffer_create(surface_h * surface_w * 4, 0--[[buffer_fixed]], 1)
    gm.buffer_get_surface(buffer, sprites_surface, 0)

    for sub_image = cull_sub_images, sub_image_count - 1 do
        for y = (sub_image * sprite_h) + cull_top_pixels, ((sub_image + 1) * sprite_h) - 1 - cull_bottom_pixels do
            local seek = ((y * surface_w) + cull_side_pixels) * 4
            gm.buffer_seek(buffer, 0--[[buffer_seek_start]], seek)
            for x = cull_side_pixels, sprite_w - 1 - cull_side_pixels do
                local offset = ((y * surface_w) + x) * 4
                --local pixel = gm.buffer_peek(buffer, offset, 5--[[buffer_u32]])
                local pixel = gm.buffer_read(buffer, 5--[[buffer_u32]])
                --log.info(pixel)
                local alpha = pixel & (0xFF << 24)
                if alpha == 0 then
                    goto continue
                end
                --local blue = (pixel >> 16) & 0xFF
                --local green = (pixel >> 8) & 0xFF
	            --local red = pixel & 0xFF
                --local color = gm.make_colour_rgb(red, green, blue)
                local color = pixel & 0xFFFFFF
                if cull_colors_set[color] then
                    goto continue
                end
                --local color = gm.surface_getpixel(sprites_surface, x, y)
                local swapped_colors = palette_swapped_colors[color]
                if swapped_colors == nil then
                    swapped_colors = {}
                    --local bad_color = gm.surface_getpixel(sprites_surface, x, y)
                    --log.info("color " .. color .. ", bad color " .. bad_color)
                    --local color_info = get_color_info(color)
                    local closest_color_index, exact_match
                    if color_overrides and color_overrides[color] then
                        closest_color_index, exact_match = color_overrides[color], false
                    else
                        closest_color_index, exact_match = find_closest_color(color, base_colors)
                    end
                    if exact_match then
                        for i = 1, palettes_count do
                            swapped_colors[i] = (palettes_colors[i][closest_color_index] | alpha)
                        end
                    else
                        local base_color = base_colors[closest_color_index]
                        --local hue_offset = base_color_info.hue - color_info.hue
                        local saturation_offset =  gm.colour_get_saturation(base_color) - gm.colour_get_saturation(color)
                        local value_offset = gm.colour_get_value(base_color) - gm.colour_get_value(color)
                        for i = 1, palettes_count do
                            local palette_color = palettes_colors[i][closest_color_index]
                            swapped_colors[i] = (gm.make_colour_hsv(
                                gm.colour_get_hue(palette_color),
                                gm.colour_get_saturation(palette_color) - saturation_offset,
                                gm.colour_get_value(palette_color) - value_offset
                            ) | alpha)
                        end
                    end
                    palette_swapped_colors[color] = swapped_colors
                end
                for palette_index = 1, palettes_count do
                    gm.buffer_poke(buffer, offset + (sprite_w * (palette_index - 1) * 4), 5--[[buffer_u32]], swapped_colors[palette_index])
                    --gm.draw_point_colour(x + (sprite_w * (palette_index)), y, swapped_colors[palette_index])
                end
                ::continue::
            end
        end
    end
    gm.buffer_set_surface(buffer, sprites_surface, 0)
    gm.buffer_delete(buffer)
    local result = {}
    for palette_index = 0, palettes_count - 1 do
        local palette_swapped_sprite = gm.sprite_create_from_surface(sprites_surface, palette_index * sprite_w, 0, sprite_w, sprite_h, false, false, x_offset, y_offset)
        if sub_image_count > 1 then
            for sub_image = 1, sub_image_count - 1 do
                gm.sprite_add_from_surface(palette_swapped_sprite, sprites_surface, palette_index * sprite_w, sub_image * sprite_h, sprite_w, sprite_h, false, false)
            end
        end
        result[palette_index + 1] = palette_swapped_sprite
    end
    --gm.surface_save(sprites_surface, path.combine(plugin_path, "generated palette swaps", "swapped.png"))
    gm.surface_free(sprites_surface);
    return result
end

local function handle_drifter_loadout_sprites(palette_swapped_colors, sprite_loadout, loadout_culling_dimensions, loadout_color_overrides, base_colors, palettes_colors, start_palette_index, palette_count)
    local sprite_loadout_top_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_loadout,
        0, 16,
        palette_count,
        2,
        loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
        static_values.loadout_cull_colors_set,
        loadout_color_overrides
    )
    local sprite_loadout_bottom_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_loadout,
        25, gm.sprite_get_number(sprite_loadout) - 25,
        palette_count,
        0,
        loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
        static_values.loadout_cull_colors_set,
        loadout_color_overrides
    )
    for _, base_loadout_sprite in ipairs(static_values.drifter_base_loadout_sprites) do
        log.info(base_loadout_sprite)
        local sprite_loadout_string = gm.sprite_get_name(base_loadout_sprite) .. "_PAL"
        local sprite_loadout_middle_palette_swaps = generate_palette_swapped_sprites
        (
            base_colors,
            palettes_colors,
            palette_swapped_colors,
            base_loadout_sprite,
            16, 9,
            palette_count,
            0,
            loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
            static_values.loadout_cull_colors_set,
            loadout_color_overrides
        )
        for i, middle_sprite in ipairs(sprite_loadout_middle_palette_swaps) do
            local combined_sprite_palette_swap = gm.sprite_duplicate(sprite_loadout_top_palette_swaps[i])
            gm.sprite_merge(combined_sprite_palette_swap, middle_sprite)
            gm.sprite_merge(combined_sprite_palette_swap, sprite_loadout_bottom_palette_swaps[i])
            local asset_name_override = sprite_loadout_string .. math.tointeger(start_palette_index + i - 1)
            asset_name_overrides[asset_name_override] = combined_sprite_palette_swap
            gm.sprite_save_strip(combined_sprite_palette_swap, path.combine(plugin_path, "generated palette swaps", asset_name_override .. ".png"))
            gm.sprite_delete(middle_sprite)
        end
    end
    for _, top_sprite_palette_swap in ipairs(sprite_loadout_top_palette_swaps) do
        gm.sprite_delete(top_sprite_palette_swap)
    end
    for _, bottom_sprite_palette_swap in ipairs(sprite_loadout_bottom_palette_swaps) do
        gm.sprite_delete(bottom_sprite_palette_swap)
    end
end

local function setup_palette_swapped_sprites(survivor, survivor_id, base_colors, palettes_colors, start_palette_index, palette_count)
    local palette_swapped_colors = {}
    local sprite_loadout = gm.array_get(survivor, 13)
    local loadout_culling_dimensions = static_values.survivor_loadout_culling_dimensions[survivor_id] or static_values.default_loadout_culling_dimensions
    local loadout_color_overrides = static_values.survivor_loadout_color_overrides[survivor_id]
    if survivor_id == 14 then
        handle_drifter_loadout_sprites(palette_swapped_colors, sprite_loadout, loadout_culling_dimensions, loadout_color_overrides, base_colors, palettes_colors, start_palette_index, palette_count)
    else
        local sprite_loadout_palette_swaps = generate_palette_swapped_sprites
        (
            base_colors,
            palettes_colors,
            palette_swapped_colors,
            sprite_loadout,
            0, gm.sprite_get_number(sprite_loadout),
            palette_count,
            2,
            loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
            static_values.loadout_cull_colors_set,
            loadout_color_overrides
        )
        local sprite_loadout_string = gm.sprite_get_name(sprite_loadout) .. "_PAL"
        for i = 1, #sprite_loadout_palette_swaps do
            local asset_name_override = sprite_loadout_string .. math.tointeger(start_palette_index + i - 1)
            asset_name_overrides[asset_name_override] = sprite_loadout_palette_swaps[i]
        end
    end

    local portrait_color_overrides = static_values.survivor_portrait_color_overrides[survivor_id]
    local sprite_portrait = gm.array_get(survivor, 16)
    local sprite_portrait_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_portrait,
        0, math.min(gm.sprite_get_number(sprite_portrait), 2),
        palette_count,
        0,
        0, 0, 0,
        static_values.portrait_cull_colors_set,
        portrait_color_overrides
    )
    local sprite_portrait_string = gm.sprite_get_name(sprite_portrait) .. "_PAL"
    for i = 1, #sprite_portrait_palette_swaps do
        local asset_name_override = sprite_portrait_string .. math.tointeger(start_palette_index + i - 1)
        asset_name_overrides[asset_name_override] = sprite_portrait_palette_swaps[i]
    end

    local sprite_portrait_small = gm.array_get(survivor, 17)
    local sprite_portrait_small_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_portrait_small,
        0, 1,
        palette_count,
        0,
        0, 0, 0,
        static_values.portrait_cull_colors_set,
        portrait_color_overrides
    )
    local sprite_portrait_small_string = gm.sprite_get_name(sprite_portrait_small) .. "_PAL"
    log.info(sprite_portrait_small_string)
    for i = 1, #sprite_portrait_small_palette_swaps do
        local asset_name_override = sprite_portrait_small_string .. math.tointeger(start_palette_index + i - 1)
        asset_name_overrides[asset_name_override] = sprite_portrait_small_palette_swaps[i]
    end
end

local function find_no_achievement_insertion_index(skin_family)
    local length = gm.array_length(skin_family.elements)
    for i = 0, length - 1 do
        if gm.array_get(skin_family.elements, i).achievement_id >= 0 then
            return i
        end
    end
    return length
end

local function add_palette_skins(survivor, survivor_id, temp_palette_sprites)
    local sprite_palette = gm.array_get(survivor, 18)
    local skin_family = gm.array_get(survivor, 10)
    local w = gm.sprite_get_width(sprite_palette)
    local h = gm.sprite_get_height(sprite_palette)
    local total_w = w + #temp_palette_sprites + 1
    local palette_surface = gm.surface_create(total_w, h);
    log.info("Surface: " .. palette_surface)
    gm.surface_set_target(palette_surface);
    gm.draw_sprite(sprite_palette, 0, 0, 0);
    gm.draw_sprite_part
    (
        sprite_palette, 0,
        w - 1, 0, --offset
        1, h, --size
        w, 0 --position
    )
    local insertion_index = find_no_achievement_insertion_index(skin_family)
    local palettes_colors = {}
    for i = 1, #temp_palette_sprites do
        local palette_index = w + i
        gm.draw_sprite(temp_palette_sprites[i], 0, palette_index, 0);
        gm.array_insert(skin_family.elements, insertion_index + i - 1, gm["@@NewGMLObject@@"](gm.constants.SurvivorSkinLoadoutUnlockable, gm.actor_skin_get_default_palette_swap(palette_index), -1.0))
        local palette_colors_info = {}
        for y = 1, h do
            palette_colors_info[y] = gm.surface_getpixel(palette_surface, palette_index, y - 1)
        end
        palettes_colors[i] = palette_colors_info
    end
    local temp_surface_sprite = gm.sprite_create_from_surface(palette_surface, 0, 0, total_w, h, false, false, 0, 0);
    gm.sprite_assign(sprite_palette, temp_surface_sprite)
    gm.sprite_save(temp_surface_sprite, 0, path.combine(plugin_path, path.combine("generated", gm.array_get(survivor, 1) .. "_generated sprite.png")))
    local base_colors = {}
    for y = 1, h do
        base_colors[y] = gm.surface_getpixel(palette_surface, 0, y - 1)
    end
    gm.surface_reset_target();
    gm.sprite_delete(temp_surface_sprite);
    gm.surface_free(palette_surface);
    setup_palette_swapped_sprites(survivor, survivor_id, base_colors, palettes_colors, w + 1, #temp_palette_sprites)
end

local function setup_survivor_palettes(survivor, survivor_id, files)
    local temp_palette_sprites = {}
    for _, file in ipairs(files) do
        local palette_sprite = gm.sprite_add(file, 1, false, false, 0, 0)
        if palette_sprite >= 0 then
            table.insert(temp_palette_sprites, palette_sprite)
        end
    end
    log.info("sprite count: " .. #temp_palette_sprites)
    add_palette_skins(survivor, survivor_id, temp_palette_sprites)
    for _, sprite in ipairs(temp_palette_sprites) do
        gm.sprite_delete(sprite);
    end
end

local function init()
    log.info("Init!!")
    local class_survivor = gm.variable_global_get("class_survivor")
    local count_survivor = gm.variable_global_get("count_survivor")
    local start_time = gm.get_timer()
    for i = 0, count_survivor - 1 do
        local survivor = gm.array_get(class_survivor, i)
        local full_identifier = gm.array_get(survivor, 0) .. "." .. gm.array_get(survivor, 1)
        local directory_path = path.combine(plugin_path, "skins", full_identifier)
        if gm.directory_exists(directory_path) == .0 then
            gm.directory_create(directory_path)
        end
        local success, files = pcall(path.get_files, directory_path)
        if success and #files > 0 then
            setup_survivor_palettes(survivor, i, files)
        end
    end
    log.info("load time elapsed: " .. ((gm.get_timer() - start_time) / 1000000.0) .. " seconds")
end

local hooks = {}
hooks["gml_Object_oStartMenu_Step_2"] = function()
    hooks["gml_Object_oStartMenu_Step_2"] = nil

    init()
end

gm.pre_code_execute(function(self, other, code, result, flags)
    if hooks[code.name] then
        hooks[code.name](self)
    end
end)