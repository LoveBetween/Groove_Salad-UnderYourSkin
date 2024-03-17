local loadout_params = require "./loadout_params"

---@class (exact) BaseDrifterSelectSprite
---@field sprite number
---@field cull_colors_set set<color>

local drifter_params = {}

---@type BaseDrifterSelectSprite[]
drifter_params.drifter_base_loadout_sprites = {
    { sprite = gm.constants.sSelectDrifterW1, cull_colors_set = {
        [0x300099] = true,
        [0x4444B5] = true,
        [0x2F0F51] = true,
        [0xDFDED7] = true,
        [0xB98D77] = true,
        [0x31B1C8] = true,
        [0x9B3B2C] = true,
        [0x3664C7] = true,
        [0x5E7C9B] = true,
        [0x2F3542] = true,
        [0x1E1C32] = true,
        [0x375E40] = true,
    } },
    { sprite = gm.constants.sSelectDrifterW2, cull_colors_set = {
        [0x47454C] = true,
        [0x5B6D72] = true,
        [0x1A1A1A] = true,
        [0xA8C5B6] = true,
        [0x8DAC9E] = true,
        [0x868B86] = true,
        [0xC3C5C3] = true,
        [0x3F3E3B] = true,
        [0x2A2B29] = true,
    } },
    { sprite = gm.constants.sSelectDrifterG1, cull_colors_set = {
        [0x51775D] = true,
        [0x3F463E] = true,
        [0x292F2E] = true,
        [0x4E5A5D] = true,
        [0x316173] = true,
        [0x4BE5D6] = true,
        [0x46C624] = true,
    } },
    { sprite = gm.constants.sSelectDrifterG2, cull_colors_set = {
        [0x31499B] = true,
        [0x30417C] = true,
        [0x5370A5] = true,
        [0x141024] = true,
        [0x2C3051] = true,
        [0x33467B] = true,
        [0x182459] = true,
        [0xCECECE] = true,
        [0xB7BBC9] = true,
        [0x8FA5C8] = true,
    } },
    { sprite = gm.constants.sSelectDrifterR, cull_colors_set = {
        [0xD1BCB9] = true,
        [0xB08885] = true,
        [0xD9D1D4] = true,
        [0xAEA3A2] = true,
        [0x1A1A1A] = true,
    } },
} --16 to 24

local drifter_cull_colors_set = loadout_params.survivor_cull_colors_sets[SURVIVOR.drifter]
for _, base_loadout_sprite in ipairs(drifter_params.drifter_base_loadout_sprites) do
    table.copy(drifter_cull_colors_set, base_loadout_sprite.cull_colors_set)
end

return drifter_params