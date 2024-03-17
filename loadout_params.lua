local loadout_params = {}

---@type table<survivor, CullingDimensions>
loadout_params.survivor_culling_dimensions = {
    [SURVIVOR.commando] = { top = 40, bottom = 48, sides = 4 },
    [SURVIVOR.huntress] = { top = 40, bottom = 48, sides = 6 },
    [SURVIVOR.enforcer] = { top = 25, bottom = 48, sides = 1 },
    [SURVIVOR.bandit] = { top = 35, bottom = 48, sides = 2 },
    [SURVIVOR.finger] = { top = 30, bottom = 48, sides = 20 },
    [SURVIVOR.engi] = { top = 36, bottom = 52, sides = 1 },
    [SURVIVOR.miner] = { top = 42, bottom = 50, sides = 0 },
    [SURVIVOR.sniper] = { top = 41, bottom = 50, sides = 5 },
    [SURVIVOR.acrid] = { top = 10, bottom = 48, sides = 0 },
    [SURVIVOR.merc] = { top = 13, bottom = 50, sides = 3 },
    [SURVIVOR.loader] = { top = 40, bottom = 52, sides = 3 },
    [SURVIVOR.chef] = { top = 20, bottom = 50, sides = 0 },
    [SURVIVOR.pilot] = { top = 44, bottom = 51, sides = 4 },
    [SURVIVOR.arti] = { top = 20, bottom = 50, sides = 0 },
    [SURVIVOR.drifter] = { top = 42, bottom = 50, sides = 1 },
    [SURVIVOR.funnyman] = { top = 44, bottom = 76, sides = 14 },
}

---@type CullingDimensions
loadout_params.default_culling_dimensions = { top = 10, bottom = 10, sides = 0 }

---@type set<color>
loadout_params.default_cull_colors_set = {
    [0x242220] = true,
    [0x373436] = true,
    [0x5A6365] = true,
    [0x3D4654] = true,
    [0x2E2B2A] = true,
    [0xB7BBC9] = true,
    [0x9193A2] = true,
    [0x3AC5C1] = true,
    [0x3D876E] = true,
    [0xFFFFFF] = true,
    [0x408988] = true,
    [0x3A77C3] = true,
    [0x1A4494] = true,
    [0x60637A] = true,
    [0xADCFCE] = true,
}

--[[
local enforcer_cull_colors_set = {
    --red light
    [0x1783FF] = true,
    [0x0044FF] = true,
    [0x0000E1] = true,
    [0x0000B6] = true,
    [0x000078] = true,
    --red highlights
    [0x3D95FF] = true,
    [0x2A2415] = true,
    [0x3D46B5] = true,
    [0x4EC5FF] = true,
    [0x4CE3FF] = true,
    [0x57A4FF] = true,
    [0x3D87C0] = true,
    [0x191699] = true,
    [0x4F39A9] = true,
}
table.copy(loadout_params.default_cull_colors_set, enforcer_cull_colors_set)
-]]

--enforcer has so many colors in the flashing animation that its easier to say what to include than what to cull
local enforcer_include_colors_set = {
    --armor
    [0x191615] = true,
    [0x4F393A] = true,
    [0xA57666] = true,
    [0xC09B83] = true,
    [0xCBAB90] = true,
    [0xD7D0C0] = true,
    --helmet
    [0xB7F3F4] = true,
    [0x70878D] = true,
    [0x515861] = true,
    --belt
    [0x424B59] = true,
    [0xA4A699] = true,
    --shotgun
    [0x464440] = true,
    [0x46D6B9] = true,
    --dim armor
    [0x433637] = true,
    [0x816258] = true,
    [0x987F6F] = true,
}

local miner_cull_colors_set = {}
table.copy(loadout_params.default_cull_colors_set, miner_cull_colors_set)
miner_cull_colors_set[0xADCFCE] = nil

local drifter_cull_colors_set = {
    --medkit?
    [0xCCD1D8] = true,
    [0x676275] = true,
    [0x584652] = true,
    [0x362D30] = true,
    [0x797454] = true,
    [0x58DB99] = true,
    --fungus
    [0xA7D681] = true,
    [0x838466] = true,
    [0x473C33] = true,
}
table.copy(loadout_params.default_cull_colors_set, drifter_cull_colors_set)

---@type table<survivor, set<color>>
loadout_params.survivor_cull_colors_sets = {
    --[SURVIVOR.enforcer] = enforcer_cull_colors_set,
    [SURVIVOR.enforcer] = enforcer_include_colors_set,
    [SURVIVOR.miner] = miner_cull_colors_set,
    [SURVIVOR.drifter] = drifter_cull_colors_set,
}

---@type table<survivor, table<color, integer>>
loadout_params.survivor_color_overrides = {
    [SURVIVOR.huntress] = {
        --body dark color
        [0x2D2A58] = 10,
    },
    [SURVIVOR.enforcer] = {
        --helmet
        [0x70878D] = 6,
        [0x515861] = 6,
    },
    [SURVIVOR.bandit] = {
        --coat collar dark spots
        [0x494E50] = 6,
        --eye and gun glow (taking whip color)
        [0xEDC4FE] = 14,
        [0x553952] = 14,
        --coat shading
        [0x303D50] = 7,
    },
    [SURVIVOR.finger] = {
        --body highlights
        [0xC5D9D4] = 1,
        --eye
        [0x8596F6] = 7,
    },
    [SURVIVOR.miner] = {
        --helmet
        [0x576B71] = 2,
        [0xADCFCE] = 2,
        --visor dark
        [0x99D7EB] = 1,
    },
    [SURVIVOR.sniper] = {
        --helmet
        [0xC4919B] = 1,
        [0xE3BFCD] = 1,
    },
    [SURVIVOR.loader] = {
        --suit markings
        [0x2C436A] = 6,
        --suit highlights
        [0xC1FFEE] = 5,
    },
    [SURVIVOR.pilot] = {
        --suit highlights
        [0x687D60] = 6,
        --collar shadows
        [0x5D7A84] = 5,
        --mask
        [0x2C2B28] = 4,
        [0x50534B] = 4,
    },
    [SURVIVOR.arti] = {
        --visor
        [0xDBE6F6] = 1,
    },
    --[[[survivors.funnyman] = {
        --helmet dark spots
        [0x798EBE] = 3,
    },--]]
}

return loadout_params