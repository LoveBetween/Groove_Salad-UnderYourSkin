local survivors = {
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

return {
    ---@type CullingDimensions[]
    survivor_loadout_culling_dimensions = {
        [0] = { top = 40, bottom = 48, sides = 4 }, --commando
        [1] = { top = 40, bottom = 48, sides = 6 }, --huntress
        [2] = { top = 25, bottom = 48, sides = 1 }, --enforcer
        [3] = { top = 35, bottom = 48, sides = 2 }, --bandit
        [4] = { top = 30, bottom = 48, sides = 20 }, --hand
        [5] = { top = 36, bottom = 52, sides = 1 }, --engi
        [6] = { top = 42, bottom = 50, sides = 0 }, --miner
        [7] = { top = 41, bottom = 50, sides = 5 }, --sniper
        [8] = { top = 10, bottom = 48, sides = 0 }, --acrid
        [9] = { top = 13, bottom = 50, sides = 3 }, --merc
        [10] = { top = 40, bottom = 52, sides = 3 }, --loader
        [11] = { top = 20, bottom = 50, sides = 0 }, --chef
        [12] = { top = 44, bottom = 51, sides = 4 }, --pilot
        [13] = { top = 20, bottom = 50, sides = 0 }, --artificer
        [14] = { top = 42, bottom = 50, sides = 1 }, --drifter
        [15] = { top = 44, bottom = 76, sides = 14 }, --funnyman
    },
    ---@type CullingDimensions
    default_loadout_culling_dimensions = { top = 10, bottom = 10, sides = 0 },
    ---@type CullingDimensions
    portrait_culling_dimensions = { top = 0, bottom = 0, sides = 0 },
    loadout_cull_colors_set = {
        [0x242220] = -1,
        [0x373436] = -1,
        [0x5A6365] = -1,
        [0x3D4654] = -1,
        [0x2E2B2A] = -1,
        [0xB7BBC9] = -1,
        [0x9193A2] = -1,
        [0x3AC5C1] = -1,
        [0x3D876E] = -1,
        [0xFFFFFF] = -1,
        [0x408988] = -1,
        [0x3A77C3] = -1,
        [0x1A4494] = -1,
        [0x60637A] = -1,
        [0xADCFCE] = -1,
    },
    survivor_loadout_color_overrides = {
        [survivors.huntress] = {
            --body dark color
            [0x2D2A58] = 10,
        },
        [survivors.finger] = {
            --body highlights
            [0xC5D9D4] = 1,
            --eye
            [0x8596F6] = 7,
        },
        --[[[survivors.funnyman] = {
            --helmet dark spots
            [0x798EBE] = 3,
        },--]]
    },
    portrait_cull_colors_set = {
        [0x191615] = -1,
        [0x77604F] = -1,
        [0x5C483C] = -1,
        [0x4C3B31] = -1,
        [0x392923] = -1,
    },
    survivor_portrait_color_overrides = {
        [survivors.commando] = {
            --helmet colors
            [0x7BA5B7] = 2,
            [0x78BCC7] = 1,
            [0x93CED2] = 1,
            [0xAFE0DD] = 1,
            --body dark color
            [0x31395E] = 4,
        },
        [survivors.finger] = {
            --face colors
            [0xA1AA92] = 1,
            [0xC4D4BF] = 1,
            [0xDAEFE6] = 1,
            [0x92978A] = 2,
            --[0x928079] = 3,
            --eye
        },
        [survivors.engi] = {
            --helmet colors
            [0xC8CDAB] = 4,
            [0xBABD78] = 4,
        },
        [survivors.acrid] = {
            --face shading
            [0x423B5D] = 3,
        },
        [survivors.funnyman] = {
            --helmet
            [0xA7AEA7] = 3,
            [0xCBCBB8] = 2,
            [0xE2E1D7] = 2,
        },
    },
    drifter_base_loadout_sprites = {
        gm.constants.sSelectDrifterW1,
        gm.constants.sSelectDrifterW2,
        gm.constants.sSelectDrifterG1,--16 to 24
        gm.constants.sSelectDrifterG2,
        gm.constants.sSelectDrifterR, --16 to 24 9 items
    }
}