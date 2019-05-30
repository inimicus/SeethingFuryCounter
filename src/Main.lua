-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Track stacks of Seething Fury.
--
-- Main.lua
-- -----------------------------------------------------------------------------
SFC             = {}
SFC.name        = "SeethingFuryCounter"
SFC.version     = "0.0.3"
SFC.dbVersion   = 1
SFC.slash       = "/sfc"
SFC.prefix      = "[SFC] "
SFC.HUDHidden   = false
SFC.ForceShow   = false
SFC.isInCombat  = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
SFC.debugMode = 0
-- -----------------------------------------------------------------------------

function SFC:Trace(debugLevel, ...)
    if debugLevel <= SFC.debugMode then
        d(SFC.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

local resurrectProgress = SFC_PlayerToPlayerResurrectProgress
local resurrectProgressAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("PlayerToPlayerResurrectAnimation", resurrectProgress)
local NO_LEADING_EDGE = false

function SFC.Setup()
    --resurrectProgress:SetScale(3)
    --resurrectProgress:SetFillColor(0.25, 1.0, 0.25, 1.0)
    --resurrectProgress:SetRadialCooldownGradient(1.0, 0.0)
end

function SFC.Play()
    resurrectProgressAnimation:PlayForward()
    --resurrectProgressAnimation:PlayFromStart(0)
    resurrectProgress:StartCooldown(15000, 15000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)
end

function SFC.Initialize(event, addonName)
    if addonName ~= SFC.name then return end

    -- First trace uses above debugMode value until preferences are loaded.
    -- The only way these two messages will appear is by changing the above
    -- value to greater than 0.
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.
    if GetUnitClassId("player") ~= 1 then
        SFC:Trace(1, "Non-dragonknight class detected, aborting addon initialization.")
        EVENT_MANAGER:UnregisterForEvent(SFC.name, EVENT_ADD_ON_LOADED)
        return
    end

    SFC:Trace(1, "SFC Loaded")
    EVENT_MANAGER:UnregisterForEvent(SFC.name, EVENT_ADD_ON_LOADED)

    SFC.preferences = ZO_SavedVars:NewAccountWide("SeethingFuryCounterVariables", SFC.dbVersion, nil, SFC:GetDefaults())

    -- Use saved debugMode value if the above value has not been changed
    if SFC.debugMode == 0 then
        SFC.debugMode = SFC.preferences.debugMode
        SFC:Trace(1, "Setting debug value to saved: " .. SFC.preferences.debugMode)
    end

    SLASH_COMMANDS[SFC.slash] = SFC.SlashCommand

    SFC:InitSettings()
    SFC.DrawUI()
    SFC.ToggleHUD()
    SFC.RegisterEvents()

    SFC.Setup()
    SFC.Play()

    SFC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(SFC.name, EVENT_ADD_ON_LOADED, function(...) SFC.Initialize(...) end)

