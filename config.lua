local config_path = path.combine(paths.config(), "Groove_Salad-UnderYourSkin.cfg")

local default_config = {
    use_sprite_cache = false,
    dump_palette_sprites = false,
}

local exists, config = pcall(toml.decodeFromFile, config_path)
local update_config = false

if exists then
   ---@param config_table table
   ---@param default_config_table table
   local function check_update_config(config_table, default_config_table)
      for key, default_value in pairs(default_config_table) do
         local value_type = type(default_value)
         local config_value = config_table[key]
         if type(config_value) ~= value_type then
            config_table[key] = default_value
            update_config = true
         elseif value_type == "table" then
            check_update_config(config_value, default_value)
         end
      end
   end
   check_update_config(config, default_config)
else
   config = default_config
   update_config = true
end

if update_config then
   log.info("Updating config file")
   pcall(toml.encodeToFile, config, { file = config_path, overwrite = true })
end

return config