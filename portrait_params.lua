local portrait_params = {}

---@type CullingDimensions
portrait_params.culling_dimensions = { top = 0, bottom = 0, sides = 0 }

---@type set<color>
portrait_params.cull_colors_set = {
    [0x191615] = true,
    [0x77604F] = true,
    [0x5C483C] = true,
    [0x4C3B31] = true,
    [0x392923] = true,
}

---@type table<survivor, table<color, integer>>
portrait_params.survivor_color_overrides = {
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

return portrait_params