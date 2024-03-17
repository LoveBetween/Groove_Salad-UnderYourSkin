---@class CullingDimensions
---@field top integer
---@field bottom integer
---@field sides integer

local static_values = {}

---@type table<survivor, CullingDimensions>
static_values.survivor_loadout_culling_dimensions = {
    [SURVIVOR.commando] = { top = 40, bottom = 48, sides = 4 }, --commando
    [SURVIVOR.huntress] = { top = 40, bottom = 48, sides = 6 }, --huntress
    [SURVIVOR.enforcer] = { top = 25, bottom = 48, sides = 1 }, --enforcer
    [SURVIVOR.bandit] = { top = 35, bottom = 48, sides = 2 }, --bandit
    [SURVIVOR.finger] = { top = 30, bottom = 48, sides = 20 }, --hand
    [SURVIVOR.engi] = { top = 36, bottom = 52, sides = 1 }, --engi
    [SURVIVOR.miner] = { top = 42, bottom = 50, sides = 0 }, --miner
    [SURVIVOR.sniper] = { top = 41, bottom = 50, sides = 5 }, --sniper
    [SURVIVOR.acrid] = { top = 10, bottom = 48, sides = 0 }, --acrid
    [SURVIVOR.merc] = { top = 13, bottom = 50, sides = 3 }, --merc
    [SURVIVOR.loader] = { top = 40, bottom = 52, sides = 3 }, --loader
    [SURVIVOR.chef] = { top = 20, bottom = 50, sides = 0 }, --chef
    [SURVIVOR.pilot] = { top = 44, bottom = 51, sides = 4 }, --pilot
    [SURVIVOR.arti] = { top = 20, bottom = 50, sides = 0 }, --artificer
    [SURVIVOR.drifter] = { top = 42, bottom = 50, sides = 1 }, --drifter
    [SURVIVOR.funnyman] = { top = 44, bottom = 76, sides = 14 }, --funnyman
}
---@type CullingDimensions
static_values.default_loadout_culling_dimensions = { top = 10, bottom = 10, sides = 0 }
---@type CullingDimensions
static_values.portrait_culling_dimensions = { top = 0, bottom = 0, sides = 0 }
---@type set<color>
static_values.loadout_cull_colors_set = {
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
---@type table<survivor, table<color, integer>>
static_values.survivor_loadout_color_overrides = {
    [SURVIVOR.huntress] = {
        --body dark color
        [0x2D2A58] = 10,
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
    [SURVIVOR.loader] = {
        --suit markings
        [0x2C436A] = 6,
        --suit highlights
        [0xC1FFEE] = 5,
    },
    --[[[survivors.funnyman] = {
        --helmet dark spots
        [0x798EBE] = 3,
    },--]]
}
---@type set<color>
static_values.portrait_cull_colors_set = {
    [0x191615] = true,
    [0x77604F] = true,
    [0x5C483C] = true,
    [0x4C3B31] = true,
    [0x392923] = true,
}
---@type table<survivor, table<color, integer>>
static_values.survivor_portrait_color_overrides = {
    [SURVIVOR.commando] = {
        --helmet colors
        [0x7BA5B7] = 2,
        [0x78BCC7] = 1,
        [0x93CED2] = 1,
        [0xAFE0DD] = 1,
        --body dark color
        [0x31395E] = 4,
    },
    [SURVIVOR.bandit] = {
        --hat highlight
        [0xF0DDA8] = 1,
        --face color
        [0x36302E] = 4,
        [0x544D4B] = 4,
        --eye and gun glow (taking whip color)
        [0xEDC4FE] = 14,
        [0xAF809F] = 14,
        [0x7F4B54] = 14,
        [0xF3688F] = 14,
        --coat collar highlight
        [0x9AACAA] = 5,
        --coat
        [0x637577] = 7,
        [0x546362] = 7,
    },
    [SURVIVOR.finger] = {
        --face colors
        [0xA1AA92] = 1,
        [0xC4D4BF] = 1,
        [0xDAEFE6] = 1,
        [0x92978A] = 2,
        --[0x928079] = 3,
        --eye
    },
    [SURVIVOR.engi] = {
        --helmet colors
        [0xC8CDAB] = 4,
        [0xBABD78] = 4,
    },
    [SURVIVOR.acrid] = {
        --face shading
        [0x423B5D] = 3,
    },
    [SURVIVOR.merc] = {
        --helmet
        [0x8786BC] = 2,
        [0x858AD6] = 2,
        [0x73A3F8] = 1,
        [0x95CBF6] = 1,
        [0xB7F3F4] = 1,
        --armor
        [0x745938] = 3,
        [0x886D3E] = 3,
        [0x3D2B2C] = 3,
    },
    [SURVIVOR.loader] = {
        --helmet dots
        [0xF2ECA1] = 1,
        [0xEFCE73] = 1,
        --suit highlights
        [0xC1FFEE] = 5,
        --suit shadows
        [0x3B475B] = 7,
        --suit inner shadows
        [0x2C201B] = 10,
        --suit grime
        [0x829295] = 11,
        --clasps
        [0xA1BCB9] = 10,
        --inner suit midtones
        [0x4B6E84] = 6
    },
    [SURVIVOR.funnyman] = {
        --helmet
        [0xA7AEA7] = 3,
        [0xCBCBB8] = 2,
        [0xE2E1D7] = 2,
    },
}
---@type integer[]
static_values.drifter_base_loadout_sprites = {
    gm.constants.sSelectDrifterW1,
    gm.constants.sSelectDrifterW2,
    gm.constants.sSelectDrifterG1,--16 to 24
    gm.constants.sSelectDrifterG2,
    gm.constants.sSelectDrifterR, --16 to 24 9 items
}

return static_values