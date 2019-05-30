-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Seething Fury Counter",
    displayName = "Seething Fury Counter",
    author      = "g4rr3t",
    version     = SFC.version,
    registerForRefresh  = true,
}

local optionsTable = {
    {
        type = "header",
        name = "Positioning",
        width = "full",
    },
    {
        type = "button",
        name = function() if SFC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    {
        type = "button",
        name = function() if SFC.ForceShow then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = function(control) ForceShow(control) end,
        width = "half",
    },
    {
        type = "checkbox",
        name = "Lock to Reticle",
        tooltip = "Snap display of counter to center of reticle. Some display options may appear better than others positioned this way.",
        getFunc = function() return GetLockReticle() end,
        setFunc = function(value) SetLockReticle(value) end,
        width = "full",
    },
    {
        type = "header",
        name = "Style",
        width = "full",
    },
    {
        type = "iconpicker",
        name = "Counter Style",
        choices = {
            "GrimFocusCounter/art/textures/Picker-ColorSquares.dds",
            "GrimFocusCounter/art/textures/Picker-Doom.dds",
            "GrimFocusCounter/art/textures/Picker-HorizontalDots.dds",
            "GrimFocusCounter/art/textures/Picker-FilledDots.dds",
            "GrimFocusCounter/art/textures/Picker-Numbers.dds",
            "GrimFocusCounter/art/textures/Picker-NumbersThickStroke.dds",
            "GrimFocusCounter/art/textures/Picker-Dice.dds",
            "GrimFocusCounter/art/textures/Picker-PlayMagsorc.dds",
            "GrimFocusCounter/art/textures/Picker-CH01_red.dds",
            "GrimFocusCounter/art/textures/Picker-CH01_BW.dds",
        },
        getFunc = function() return GetTexture() end,
        setFunc = function(texture) SetTexture(texture) end,
        tooltip = "Style of counter display.",
        choicesTooltips = {
            "Color Squares",
            "DOOM",
            "Horizontal Dots",
            "Filled Dots",
            "Numbers",
            "Numbers (Thick Stroke)",
            "Dice",
            "Play Magsorc",
            "Red Compass (by Porkjet)",
            "Mono Compass (by Porkjet)",
        },
        maxColumns = 3,
        visibleRows = 2.5,
        iconSize = 64,
        width = "full",
    },
    {
        type = "slider",
        name = "Display Size",
        tooltip = "Display size of counter.",
        min = 0,
        max = 500,
        step = 5,
        getFunc = function() return GetSize() end,
        setFunc = function(value) SetSize(value) end,
        width = "full",
        default = 40,
    },
    {
        type = "checkbox",
        name = "Show Zero Stacks",
        tooltip = "Show when skill is active but no stacks tracked.",
        getFunc = function() return GetZeroStacks() end,
        setFunc = function(value) SetZeroStacks(value) end,
        width = "full",
    },
    {
        type = "description",
        text = "Not all display styles include indicators for zero stacks.",
        width = "full",
    },
    {
        type = "header",
        name = "Advanced Options",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Fade on Skill Inactive",
        tooltip = "Lower opacity when stacks exist and in combat, but buff has expired.",
        getFunc = function() return GetFade() end,
        setFunc = function(value) SetFade(value) end,
        width = "full",
    },
    {
        type = "slider",
        name = "Fade Amount",
        tooltip = "Opacity of inactive skill with counted stacks",
        min = 0,
        max = 100,
        disabled = function() return not GetFade() end,
        getFunc = function() return GetFadeAmount() end,
        setFunc = function(value) SetFadeAmount(value) end,
        width = "full",
        default = 90,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Default",
        tooltip = "Overlay the indicator with a color. Works better on some textures than others.",
        getFunc = function() return GetColorOverlay('default') end,
        setFunc = function(value) SetColorOverlay('default', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('default') end,
        tooltip = "Color used for Color Overlay: Default",
        getFunc = function() return GetColor('default') end,
        setFunc = function(r, g, b, a) SetColor('default', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Inactive",
        tooltip = "When skill is inactive, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlay('inactive') end,
        setFunc = function(value) SetColorOverlay('inactive', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('inactive') end,
        tooltip = "Color used for Color Overlay: Inactive",
        getFunc = function() return GetColor('inactive') end,
        setFunc = function(r, g, b, a) SetColor('inactive', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: 4 Stacks",
        tooltip = "Differentiate the significance of 4 stacks to prepare to fire bow proc.",
        getFunc = function() return GetColorOverlay('four') end,
        setFunc = function(value) SetColorOverlay('four', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('four') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColor('four') end,
        setFunc = function(r, g, b, a) SetColor('four', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Proc",
        tooltip = "When a proc is active and spectral bow is ready to be fired, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlay('proc') end,
        setFunc = function(value) SetColorOverlay('proc', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlay('proc') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColor('proc') end,
        setFunc = function(r, g, b, a) SetColor('proc', r, g, b, a) end,
    },
    {
        type = "submenu",
        name = "Acknowledgements",
        controls = {
            [1] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Porkjet|u|rCreator of Red Compass and Mono Compass textures",
                width = "full",
            },
            [2] = {
                type = "description",
                text = "|cBCBCBC|u0:40::aquamantom|u|rHomeowner of primary facility for testing, parsing and AFKing",
                width = "full",
            },
            [3] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Vierron|u|rAdditional blind-people perspective, testing and input",
                width = "full",
            },
            [4] = {
                type = "description",
                text = "|cBCBCBC|u0:40::meanmegan|u|rMy amazing wife and baby's mama who, through her support by allowing me to spend far too much time in-game, has made Grim Focus Counter possible -- send all your gold and goodies to her!",
                width = "full",
            },
        },
    },
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
function ToggleLocked(control)
    SFC.preferences.unlocked = not SFC.preferences.unlocked
    SFC.SFCContainer:SetMovable(SFC.preferences.unlocked)
    if SFC.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Force Showing
function ForceShow(control)
    SFC.ForceShow = not SFC.ForceShow
    if SFC.ForceShow then
        control:SetText("Hide")
        SFC.HUDHidden = false
        SFC.SFCContainer:SetHidden(false)
        SFC.UpdateStacks(5)
    else
        control:SetText("Show")
        SFC.HUDHidden = true
        SFC.SFCContainer:SetHidden(true)
        SFC.UpdateStacks(0)
    end
end

-- Lock to Reticle
function SetLockReticle(value)
    SFC.LockToReticle(value)
end

function GetLockReticle(value)
    return SFC.preferences.lockedToReticle
end

-- Textures
function SetTexture(value)

    -- Search texture array
    -- We are passed the picker's texture,
    -- convert to the index of the texture table.
    for index, texture in pairs(SFC.TEXTURE_VARIANTS) do
        if texture.picker == value then
            selectedTexture = index
            break
        end
    end

    if selectedTexture ~= nil then
        SFC.SFCTexture:SetTexture(SFC.TEXTURE_VARIANTS[selectedTexture].asset)
        SFC.preferences.selectedTexture = selectedTexture
    else
        d('[SFC] Could not load specified texture!')
    end

end

function GetTexture()
    selectedTexture = SFC.preferences.selectedTexture
    return SFC.TEXTURE_VARIANTS[selectedTexture].picker
end

-- Sizing
function SetSize(value)
    SFC.preferences.size = value
    SFC.SFCContainer:SetDimensions(value, value)
    SFC.SFCTexture:SetDimensions(value, value)
end

function GetSize()
    return SFC.preferences.size
end

-- Zero Stacks
function SetZeroStacks(value)
    SFC.preferences.showEmptyStacks = value
end

function GetZeroStacks()
    return SFC.preferences.showEmptyStacks
end

-- Color Overlay
function SetColorOverlay(overlayType, value)
    SFC.preferences.overlay[overlayType] = value
    SFC.SetSkillColorOverlay('default')
end

function GetColorOverlay(overlayType, key)
    return SFC.preferences.overlay[overlayType]
end

function SetColor(overlayType, r, g, b, a)
    SFC.preferences.colors[overlayType] = {
        r = r,
        g = g,
        b = b,
        a = a,
    }
    SFC.SetSkillColorOverlay('default')
end

function GetColor(overlayType)
    return SFC.preferences.colors[overlayType].r,
        SFC.preferences.colors[overlayType].g,
        SFC.preferences.colors[overlayType].b,
        SFC.preferences.colors[overlayType].a
end

-- Fade
function SetFade(value)
    -- Note: To avoid having to change alpha every time,
    -- even if we never wanted to fade in the first place,
    -- turning OFF the option must first SetSkillFade(false)
    -- before setting preferences.fadeInactive to false.
    -- Otherwise we may get stuck in a faded state.
    SFC.SetSkillFade(value)
    SFC.preferences.fadeInactive = value
end

function GetFade()
    return SFC.preferences.fadeInactive
end

function SetFadeAmount(value)
    SFC.preferences.fadeAmount = value
    SFC.SetSkillFade()
end

function GetFadeAmount()
    return SFC.preferences.fadeAmount
end

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function SFC:InitSettings()
    LAM:RegisterAddonPanel(SFC.name, panelData)
    LAM:RegisterOptionControls(SFC.name, optionsTable)

    SFC:Trace(2, "Finished InitSettings()")
end

-- -----------------------------------------------------------------------------
-- Settings Upgrade Function
-- -----------------------------------------------------------------------------

function SFC:UpgradeSettings()
    -- Check if we've already upgraded
    if SFC.preferences.colorOverlay == nil and SFC.preferences.color == nil then return end

    -- Copy default color overlay to new savedvar
    SFC.preferences.overlay.default = SFC.preferences.colorOverlay
    SFC.preferences.colors.default = SFC.preferences.color

    -- Clear old, indicate upgraded
    SFC.preferences.colorOverlay = nil
    SFC.preferences.color= nil
end

