local plugin_data_path = _ENV["!plugins_data_mod_folder_path"]
local sprite_cache_path = path.combine(plugin_data_path, "sprite_cache")
local sprite_caching = {}

---@param directory string
---@param skin_file_name string
---@param sprite_name string
---@return string
sprite_caching.get_palette_sprite_cache_path = function (directory, skin_file_name, sprite_name)
    return path.combine(sprite_cache_path, directory, skin_file_name, sprite_name .. ".png")
end

---@param directory string
---@param palette_skins PaletteSkin[]
---@param sprite_name string
---@param sub_image_count integer
---@param x_offset integer
---@param y_offset integer
---@param palettes_colors table<integer, color[]>
---@return table<integer, integer>
---@return table<integer, integer>
---@return table<integer, color[]>
---@return table<integer, integer>
sprite_caching.load_cached_sprites = function(directory, palette_skins, sprite_name, sub_image_count, x_offset, y_offset, palettes_colors)
    local cached_sprites = {}
    local cached_indices = {}
    local remaining_palette_colors = {}
    local remaining_indices = {}
    for index, palette_skin in ipairs(palette_skins) do
        local cached_sprite = gm.sprite_add(
            sprite_caching.get_palette_sprite_cache_path(directory, palette_skin.file_name, sprite_name),
            sub_image_count, false, false, x_offset, y_offset
        )
        if cached_sprite >= 0 then
            table.insert(cached_sprites, cached_sprite)
            table.insert(cached_indices, index)
        else
            table.insert(remaining_palette_colors, palettes_colors[index])
            table.insert(remaining_indices, index)
        end
    end
    return cached_sprites, cached_indices, remaining_palette_colors, remaining_indices
end

---@param directory string
---@param sprite_name string
---@param sprites integer[]
---@param palette_skins PaletteSkin[]
---@param sprite_index_to_palette_skin_index table<integer, integer>
sprite_caching.cache_sprites = function(directory, sprite_name, sprites, palette_skins, sprite_index_to_palette_skin_index)
    for index, sprite in ipairs(sprites) do
        gm.sprite_save_strip(sprite, sprite_caching.get_palette_sprite_cache_path(
            directory,
            palette_skins[sprite_index_to_palette_skin_index[index]].file_name,
            sprite_name
        ))
    end
end

return sprite_caching