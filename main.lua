---@enum survivor
SURVIVOR = {
    commando = 0,
    huntress = 1,
    enforcer = 2,
    bandit = 3,
    finger = 4,
    engi = 5,
    miner = 6,
    sniper = 7,
    acrid = 8,
    merc = 9,
    loader = 10,
    chef = 11,
    pilot = 12,
    arti = 13,
    drifter = 14,
    funnyman = 15,
}

---@class CullingDimensions
---@field top integer
---@field bottom integer
---@field sides integer

---@param src table
---@param dest table
function table.copy(src, dest)
    for key, value in pairs(src) do
        dest[key] = value
    end
end

local asset_name_overrides = {}

gm.post_script_hook(gm.constants.asset_get_index, function(self, other, result, args)
    local asset_name = args[1].value
    if asset_name_overrides[asset_name] ~= nil then
        result.value = asset_name_overrides[asset_name]
    end
end)

---@param sprite number
---@param base_sprite_name string
---@param palette_skin PaletteSkin
function set_palette_sprite_name(sprite, base_sprite_name, palette_skin)
    asset_name_overrides[base_sprite_name .. "_PAL" .. math.tointeger(palette_skin.runtime_index)] = sprite
end

local plugin_path = _ENV["!plugins_mod_folder_path"]
local config = require "./config"
local loadout_params = require "./loadout_params"
local portrait_params = require "./portrait_params"
local drifter_params = require "./drifter_params"

local sprite_caching
if config.use_sprite_cache then
    sprite_caching = require "./sprite_caching"
end

---@alias color integer

---@param surface any
---@param surface_width integer
---@param surface_height integer
---@return unknown
local function get_buffer_for_surface(surface, surface_width, surface_height)
    local buffer = gm.buffer_create(surface_width * surface_height * 4, 0 --[[buffer_fixed]], 1)
    gm.buffer_get_surface(buffer, surface, 0)
    return buffer
end

---@param x integer
---@param y integer
---@param width integer
---@return integer
local function get_buffer_pixel_offset(x, y, width)
    return ((y * width) + x) * 4
end

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

---@class set<T> : table<T, boolean>

---@param base_colors color[]
---@param palettes_colors color[][]
---@param palette_swapped_colors table<color, color[]>
---@param base_sprite integer
---@param sub_image_start_index integer
---@param sub_image_count integer
---@param palettes_count integer
---@param cull_sub_images integer
---@param cull_top_pixels integer
---@param cull_bottom_pixels integer
---@param cull_side_pixels integer
---@param cull_colors_set set<color>
---@param invert_cull_colors boolean
---@param color_overrides table<color, integer>
---@return table
local function generate_palette_swapped_sprites(base_colors, palettes_colors, palette_swapped_colors, base_sprite, sub_image_start_index, sub_image_count, palettes_count,
    cull_sub_images, cull_top_pixels, cull_bottom_pixels, cull_side_pixels, cull_colors_set, invert_cull_colors, color_overrides)
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

    local buffer = get_buffer_for_surface(sprites_surface, surface_w, surface_h)

    for sub_image = cull_sub_images, sub_image_count - 1 do
        for y = (sub_image * sprite_h) + cull_top_pixels, ((sub_image + 1) * sprite_h) - 1 - cull_bottom_pixels do
            gm.buffer_seek(buffer, 0--[[buffer_seek_start]], get_buffer_pixel_offset(cull_side_pixels, y, surface_w))
            for x = cull_side_pixels, sprite_w - 1 - cull_side_pixels do
                local pixel = gm.buffer_read(buffer, 5--[[buffer_u32]])
                local alpha = pixel & (0xFF << 24)
                if alpha == 0 then
                    goto continue
                end
                local color = pixel & 0xFFFFFF
                if (cull_colors_set[color] == nil) == invert_cull_colors then
                    goto continue
                end
                local swapped_colors = palette_swapped_colors[color]
                if swapped_colors == nil then
                    swapped_colors = {}
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
                local offset = get_buffer_pixel_offset(x, y, surface_w)
                for palette_index = 1, palettes_count do
                    gm.buffer_poke(buffer, offset + (sprite_w * (palette_index - 1) * 4), 5--[[buffer_u32]], swapped_colors[palette_index])
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
    gm.surface_free(sprites_surface);
    return result
end

---@param sprite_loadout integer
---@param loadout_culling_dimensions CullingDimensions
---@param loadout_color_overrides table<color, integer>
---@param loadout_cull_colors_set set<color>
---@param directory string
---@param palette_skins PaletteSkin[]
---@param base_colors color[]
---@param palettes_colors color[][]
local function handle_drifter_loadout_sprites(sprite_loadout, loadout_culling_dimensions, loadout_color_overrides, loadout_cull_colors_set, directory, palette_skins, base_colors, palettes_colors)
    if sprite_caching then
        ---@type set<PaletteSkin>
        local required_palette_skins_set = {}
        for _, base_loadout_sprite in ipairs(drifter_params.drifter_base_loadout_sprites) do
            local x_offset = gm.sprite_get_xoffset(base_loadout_sprite.sprite)
            local y_offset = gm.sprite_get_yoffset(base_loadout_sprite.sprite)
            local remaining_palette_skins = sprite_caching.load_sprite_palettes(
                directory,base_loadout_sprite.sprite_name,  palette_skins,
                gm.sprite_get_number(base_loadout_sprite.sprite), x_offset, y_offset, palettes_colors
            )
            for _, remaining_palette_skin in ipairs(remaining_palette_skins) do
                required_palette_skins_set[remaining_palette_skin] = true
            end
        end
        ---@type PaletteSkin[]
        local final_palette_skins = {}
        ---@type color[][]
        local final_palettes_colors = {}
        for i, palette_skin in ipairs(palette_skins) do
            if required_palette_skins_set[palette_skin] then
                table.insert(final_palette_skins, palette_skin)
                table.insert(final_palettes_colors, palettes_colors[i])
            end
        end
        if #final_palette_skins == 0 then
            return
        end
        palette_skins = final_palette_skins
        palettes_colors = final_palettes_colors
    end
    local palette_swapped_colors = {}
    local sprite_loadout_top_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_loadout,
        0, 16,
        #palette_skins,
        2,
        loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
        loadout_cull_colors_set,
        false,
        loadout_color_overrides
    )
    local sprite_loadout_bottom_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite_loadout,
        25, gm.sprite_get_number(sprite_loadout) - 25,
        #palette_skins,
        0,
        loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
        loadout_cull_colors_set,
        false,
        loadout_color_overrides
    )
    for _, base_loadout_sprite in ipairs(drifter_params.drifter_base_loadout_sprites) do
        local sprite_loadout_middle_palette_swaps = generate_palette_swapped_sprites
        (
            base_colors,
            palettes_colors,
            palette_swapped_colors,
            base_loadout_sprite.sprite,
            16, 9,
            #palette_skins,
            0,
            loadout_culling_dimensions.top, loadout_culling_dimensions.bottom, loadout_culling_dimensions.sides,
            base_loadout_sprite.cull_colors_set,
            false,
            loadout_color_overrides
        )
        for index, middle_sprite in ipairs(sprite_loadout_middle_palette_swaps) do
            local combined_sprite_palette_swap = gm.sprite_duplicate(sprite_loadout_top_palette_swaps[index])
            gm.sprite_merge(combined_sprite_palette_swap, middle_sprite)
            gm.sprite_delete(middle_sprite)
            gm.sprite_merge(combined_sprite_palette_swap, sprite_loadout_bottom_palette_swaps[index])

            local palette_skin = palette_skins[index]
            set_palette_sprite_name(combined_sprite_palette_swap, base_loadout_sprite.sprite_name, palette_skin)
            if sprite_caching then
                sprite_caching.save_sprite_palette(directory, base_loadout_sprite.sprite_name, combined_sprite_palette_swap, palette_skin)
            end
        end
    end
    for i = 1, #palette_skins do
        gm.sprite_delete(sprite_loadout_top_palette_swaps[i])
        gm.sprite_delete(sprite_loadout_bottom_palette_swaps[i])
    end
end

---@param sprite integer
---@param sub_image_count integer
---@param cull_sub_images integer
---@param culling_dimensions CullingDimensions
---@param cull_colors_set set<color>
---@param invert_cull_colors boolean
---@param color_overrides table<color, integer>
---@param directory string
---@param palette_skins PaletteSkin[]
---@param base_colors color[]
---@param palettes_colors color[][]
---@param palette_swapped_colors table<color, color[]>
local function setup_palette_swapped_sprite(sprite, sub_image_count, cull_sub_images, culling_dimensions, cull_colors_set, invert_cull_colors, color_overrides,
    directory, palette_skins, base_colors, palettes_colors, palette_swapped_colors)
    local sprite_name = gm.sprite_get_name(sprite)
    if sprite_caching then
        local x_offset = gm.sprite_get_xoffset(sprite)
        local y_offset = gm.sprite_get_yoffset(sprite)
        palette_skins, palettes_colors = sprite_caching.load_sprite_palettes(
            directory,sprite_name,  palette_skins,
            sub_image_count, x_offset, y_offset, palettes_colors
        )
        if #palette_skins == 0 then
            return
        end
        palette_swapped_colors = {}
    end
    local sprite_palette_swaps = generate_palette_swapped_sprites
    (
        base_colors,
        palettes_colors,
        palette_swapped_colors,
        sprite,
        0, sub_image_count,
        #palette_skins,
        cull_sub_images,
        culling_dimensions.top, culling_dimensions.bottom, culling_dimensions.sides,
        cull_colors_set,
        invert_cull_colors,
        color_overrides
    )
    for index, sprite_palette_swap in ipairs(sprite_palette_swaps) do
        local palette_skin = palette_skins[index]
        set_palette_sprite_name(sprite_palette_swap, sprite_name, palette_skin)
        if sprite_caching then
            sprite_caching.save_sprite_palette(directory, sprite_name, sprite_palette_swap, palette_skin)
        end
    end
end

---@param survivor any
---@param survivor_id integer
---@param directory string
---@param palette_skins PaletteSkin[]
---@param base_colors color[]
---@param palettes_colors color[][]
local function setup_palette_swapped_sprites_for_survivor(survivor, survivor_id, directory, palette_skins, base_colors, palettes_colors)
    local sprite_loadout = gm.array_get(survivor, 13)
    local loadout_culling_dimensions = loadout_params.survivor_culling_dimensions[survivor_id] or loadout_params.default_culling_dimensions
    local loadout_color_overrides = loadout_params.survivor_color_overrides[survivor_id]
    local loadout_cull_colors_set = loadout_params.survivor_cull_colors_sets[survivor_id] or loadout_params.default_cull_colors_set
    if survivor_id == SURVIVOR.drifter then
        handle_drifter_loadout_sprites(sprite_loadout, loadout_culling_dimensions, loadout_color_overrides, loadout_cull_colors_set, directory, palette_skins, base_colors, palettes_colors)
    else
        setup_palette_swapped_sprite(
            sprite_loadout, gm.sprite_get_number(sprite_loadout), 2, loadout_culling_dimensions, loadout_cull_colors_set, survivor_id == SURVIVOR.enforcer, loadout_color_overrides,
            directory, palette_skins, base_colors, palettes_colors, {}
        )
    end
    local portrait_palette_swapped_colors = {}
    local portrait_color_overrides = portrait_params.survivor_color_overrides[survivor_id]
    local sprite_portrait = gm.array_get(survivor, 16)
    setup_palette_swapped_sprite(
        sprite_portrait, math.min(gm.sprite_get_number(sprite_portrait), 2), 0, portrait_params.culling_dimensions, portrait_params.cull_colors_set, false, portrait_color_overrides,
        directory, palette_skins, base_colors, palettes_colors, portrait_palette_swapped_colors
    )
    local sprite_portrait_small = gm.array_get(survivor, 17)
    setup_palette_swapped_sprite(
        sprite_portrait_small, 1, 0, portrait_params.culling_dimensions, portrait_params.cull_colors_set, false, portrait_color_overrides,
        directory, palette_skins, base_colors, palettes_colors, portrait_palette_swapped_colors
    )
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

---@param survivor any
---@param survivor_id integer
---@param directory string
---@param palette_skins PaletteSkin[]
local function add_palette_skins(survivor, survivor_id, directory, palette_skins)
    local sprite_palette = gm.array_get(survivor, 18)
    local skin_family = gm.array_get(survivor, 10)
    local w = gm.sprite_get_width(sprite_palette)
    local h = gm.sprite_get_height(sprite_palette)
    local total_w = w + #palette_skins + 1
    local palette_surface = gm.surface_create(total_w, h);
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
    for i, palette_skin in ipairs(palette_skins) do
        local palette_index = w + i
        palette_skin.runtime_index = palette_index
        gm.draw_sprite(palette_skins[i].temp_palette_sprite, 0, palette_index, 0);
        gm.array_insert(skin_family.elements, insertion_index + i - 1, gm["@@NewGMLObject@@"](gm.constants.SurvivorSkinLoadoutUnlockable, gm.actor_skin_get_default_palette_swap(palette_index), -1.0))
    end
    gm.surface_reset_target();
    local temp_surface_sprite = gm.sprite_create_from_surface(palette_surface, 0, 0, total_w, h, false, false, 0, 0);
    gm.sprite_assign(sprite_palette, temp_surface_sprite)
    local buffer = get_buffer_for_surface(palette_surface, total_w, h)
    ---@type color[]
    local base_colors = {}
    for y = 0, h - 1 do
        base_colors[y + 1] = (gm.buffer_peek(buffer, get_buffer_pixel_offset(0, y, total_w), 5 --[[buffer_u32]]) & 0xFFFFFF)
    end
    ---@type color[][]
    local palettes_colors = {}
    for i = 1, #palette_skins do
        local palette_colors = {}
        for y = 0, h - 1 do
            palette_colors[y + 1] = (gm.buffer_peek(buffer, get_buffer_pixel_offset(w + i, y, total_w), 5 --[[buffer_u32]]) & 0xFFFFFF)
        end
        palettes_colors[i] = palette_colors
    end
    gm.buffer_delete(buffer)
    gm.sprite_delete(temp_surface_sprite);
    gm.surface_free(palette_surface);
    setup_palette_swapped_sprites_for_survivor(survivor, survivor_id, directory, palette_skins, base_colors, palettes_colors)
end

---@param survivor any
---@param survivor_id integer
---@param directory string
---@param files string[]
local function setup_survivor_palettes(survivor, survivor_id, directory, files)
    ---@type PaletteSkin[]
    local palette_skins = {}
    for _, file in ipairs(files) do
        local palette_sprite = gm.sprite_add(file, 1, false, false, 0, 0)
        if palette_sprite >= 0 then
            ---@class (exact) PaletteSkin
            ---@field file_name string
            ---@field runtime_index integer?
            ---@field temp_palette_sprite number
            local skin = {}
            skin.file_name = path.filename(file)
            skin.temp_palette_sprite = palette_sprite
            table.insert(palette_skins, skin)
        end
    end
    add_palette_skins(survivor, survivor_id, directory, palette_skins)
    for _, skin in ipairs(palette_skins) do
        gm.sprite_delete(skin.temp_palette_sprite);
    end
end

---@param file string
---@return boolean
local function check_manifest(file)
    if not path.exists(file) then return false end
    local lines = {}
    for line in io.lines(file) do 
            if string.match(line, "Groove_Salad%-UnderYourSkin%-") then
                return true
            end
    end
    return false
end

---@return table
local function find_dependant_plugins()
    local dependant_plugin_paths = {}
    local parent_plugin_path =  path.get_parent(plugin_path)
    local success, subdirectories = pcall(path.get_directories, parent_plugin_path)
    if success and #subdirectories > 0 then
            for _, file in ipairs(subdirectories) do
                if path.get_parent(file) == parent_plugin_path then
                    local manifest_path = path.combine(file, "manifest.json")
                    if check_manifest(manifest_path) then
                        dependant_plugin_paths[#dependant_plugin_paths+1] = file
                    end
                end
            end
    end
    return dependant_plugin_paths
end

local function init()
    log.info("init!")
    local class_survivor = gm.variable_global_get("class_survivor")
    local count_survivor = gm.variable_global_get("count_survivor")
    local start_time = gm.get_timer()
    local sprite_dump_path = path.combine(_ENV["!plugins_data_mod_folder_path"], "sprite_dump")

    local plugins_paths = find_dependant_plugins()
    plugins_paths[#plugins_paths + 1] = plugin_path
    for _, current_plugin_path in ipairs(plugins_paths) do
        
        for i = 0, count_survivor - 1 do
            local survivor = gm.array_get(class_survivor, i)
            local full_identifier = gm.array_get(survivor, 0) .. "." .. gm.array_get(survivor, 1)
            local directory_path = path.combine(current_plugin_path, "skins", full_identifier)
            if gm.directory_exists(directory_path) == .0 then
                gm.directory_create(directory_path)
            end
            local success, files = pcall(path.get_files, directory_path)
            if success and #files > 0 then
                setup_survivor_palettes(survivor, i, full_identifier, files)
            end
            if config.dump_palette_sprites then
                local sprite_palette = gm.array_get(survivor, 18)
                gm.sprite_save(sprite_palette, 0, path.combine(sprite_dump_path, gm.sprite_get_name(sprite_palette) .. ".png"))
            end
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
