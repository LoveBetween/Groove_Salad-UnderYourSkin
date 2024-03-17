local loadout_params = require "./loadout_params"

---@class (exact) BaseDrifterSelectSprite
---@field sprite number
---@field cull_colors_set set<color>

local drifter_params = {}

---@type BaseDrifterSelectSprite[]
drifter_params.drifter_base_loadout_sprites = {
    gm.constants.sSelectDrifterW1,
    gm.constants.sSelectDrifterW2,
    gm.constants.sSelectDrifterG1,--16 to 24
    gm.constants.sSelectDrifterG2,
    gm.constants.sSelectDrifterR, --16 to 24 9 items
}

return drifter_params