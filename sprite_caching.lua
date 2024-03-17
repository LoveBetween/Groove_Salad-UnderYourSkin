local plugin_data_path = _ENV["!plugins_data_mod_folder_path"]
local sprite_cache_path = path.combine(plugin_data_path, "sprite_cache")
local sprite_caching = {}

---@param directory string
---@param skin_file_name string
---@param base_sprite_name string
---@return string
sprite_caching.get_palette_sprite_cache_path = function (directory, skin_file_name, base_sprite_name)
    return path.combine(sprite_cache_path, directory, skin_file_name, base_sprite_name .. ".png")
end

---@param directory string
---@param base_sprite_name string
---@param palette_skins PaletteSkin[]
---@param sub_image_count integer
---@param x_offset integer
---@param y_offset integer
---@param palettes_colors color[][]
---@return PaletteSkin[]
---@return color[][]
sprite_caching.load_sprite_palettes = function (directory, base_sprite_name, palette_skins, sub_image_count, x_offset, y_offset, palettes_colors)
    local remaining_palette_skins = {}
    local remaining_palette_colors = {}
    for index, palette_skin in ipairs(palette_skins) do
        local cached_sprite = gm.sprite_add(
            sprite_caching.get_palette_sprite_cache_path(directory, palette_skin.file_name, base_sprite_name),
            sub_image_count, false, false, x_offset, y_offset
        )
        if cached_sprite >= 0 then
            set_palette_sprite_name(cached_sprite, base_sprite_name, palette_skin)
        else
            table.insert(remaining_palette_skins, palette_skin)
            table.insert(remaining_palette_colors, palettes_colors[index])
        end
    end
    return remaining_palette_skins, remaining_palette_colors
end

---@param directory string
---@param base_sprite_name string
---@param sprite integer
---@param palette_skin PaletteSkin
sprite_caching.save_sprite_palette = function (directory, base_sprite_name, sprite, palette_skin)
    gm.sprite_save_strip(sprite, sprite_caching.get_palette_sprite_cache_path(
        directory,
        palette_skin.file_name,
        base_sprite_name
    ))
end

return sprite_caching