-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    debugMode = 0,
    showEmptyStacks = true,
    selectedTexture = 8,
    positionLeft = 800,
    positionTop = 600,
    size = 100,
    unlocked = true,
    lockedToReticle = false,
    overlay = {
        default   = false,
        inactive  = false,
        four      = false,
        proc      = false,
    },
    colors = {
        default = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        inactive = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        four = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        proc = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
    },
    fadeInactive = false,
    fadeAmount = 90,
}

function SFC:GetDefaults()
    return defaults
end
