-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Interface.lua
-- -----------------------------------------------------------------------------

function SFC.DrawUI()
    local c = WINDOW_MANAGER:CreateTopLevelWindow("SFCContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(SFC.preferences.size, SFC.preferences.size)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(SFC.preferences.unlocked)
    c:SetHidden(false)
    c:SetHandler("OnMoveStop", function(...) SFC.SavePosition() end)

    -- Check for valid texture
    -- Potential fix for UI error discovered by Porkjet
    if not SFC.TEXTURE_VARIANTS[SFC.preferences.selectedTexture] then
        -- If texture selection is not a valid option, reset to default
        SFC:Trace(1, 'Invalid texture selection: ' .. SFC.preferences.selectedTexture)
        SFC.preferences.selectedTexture = SFC:GetDefaults().selectedTexture
    end

    local t = WINDOW_MANAGER:CreateControl("SFCTexture", c, CT_TEXTURE)
    t:SetTexture(SFC.TEXTURE_VARIANTS[SFC.preferences.selectedTexture].asset)
    t:SetDimensions(SFC.preferences.size, SFC.preferences.size)
    t:SetTextureCoords(SFC.TEXTURE_FRAMES[0].REL, SFC.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    SFC.SFCContainer = c
    SFC.SFCTexture = t

    SFC.SetPosition(SFC.preferences.positionLeft, SFC.preferences.positionTop)
    SFC.SetSkillColorOverlay('default')

    SFC:Trace(2, "Finished DrawUI()")
end

function SFC.SetSkillColorOverlay(overlayType)

    -- Read saved color
    color = SFC.preferences.colors[overlayType]

    if SFC.preferences.overlay[overlayType] then
        -- Set active color overlay
        SFC.SFCTexture:SetColor(color.r, color.g, color.b, color.a)
    else
        -- Set to default if it's set
        if SFC.preferences.overlay.default then
            default = SFC.preferences.colors.default
            SFC.SFCTexture:SetColor(default.r, default.g, default.b, default.a)
        else
            -- Set to white AKA none if no default set
            SFC.SFCTexture:SetColor(1, 1, 1, 1)
        end

    end
end

function SFC.SetSkillFade(faded)
    -- Only change fade if our options want us to fade
    if SFC.preferences.fadeInactive then
        if faded then
            alpha = SFC.preferences.fadeAmount / 100
            SFC.SFCContainer:SetAlpha(alpha)
        else
            SFC.SFCContainer:SetAlpha(1)
        end
    end
end

function SFC.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if SFC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            SFC:Trace(3, "Hiding HUD")
            SFC.HUDHidden = true
            SFC.SFCContainer:SetHidden(true)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            SFC:Trace(3, "Showing HUD")
            SFC.HUDHidden = false
            SFC.SFCContainer:SetHidden(false)
        end
    end)

    SFC:Trace(2, "Finished ToggleHUD()")
end

function SFC.LockToReticle(lockToReticle)
    if lockToReticle then
        SFC.preferences.lockedToReticle = true
        SFC:Trace(1, "Locked to Reticle")
    else
        SFC.preferences.lockedToReticle = false
        SFC:Trace(1, "Unlocked from Reticle")
    end
    SFC.SetPosition(SFC.preferences.positionLeft, SFC.preferences.positionTop)
end

function SFC.OnMoveStop()
    SFC:Trace(1, "Moved")
    SFC.SavePosition()
end

function SFC.SavePosition()
    local top   = SFC.SFCContainer:GetTop()
    local left  = SFC.SFCContainer:GetLeft()

    -- If locked to reticle, but unlocked and moved,
    -- then we are no longer locked to reticle.
    SFC.preferences.lockedToReticle = false

    SFC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    SFC.preferences.positionLeft = left
    SFC.preferences.positionTop  = top
end

function SFC.SetPosition(left, top)
    if SFC.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        SFC.SFCContainer:ClearAnchors()
        SFC.SFCContainer:SetAnchor(CENTER, GuiRoot, TOP, 0, height/2)
    else
        SFC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        SFC.SFCContainer:ClearAnchors()
        SFC.SFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function SFC.UpdateStacks(stackCount)

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount > 0 then

        -- Show stacks
        SFC.SFCTexture:SetTextureCoords(SFC.TEXTURE_FRAMES[stackCount].REL, SFC.TEXTURE_FRAMES[stackCount+1].REL, 0, 1)

    else

        -- Show zero stack indicator for active ability
        if SFC.preferences.showEmptyStacks and (SFC.abilityActive or SFC.isInCombat) then
            SFC:Trace(1, "Stack #0 (Show Empty)")
            SFC.SFCTexture:SetTextureCoords(SFC.TEXTURE_FRAMES[6].REL, SFC.TEXTURE_FRAMES[7].REL, 0, 1)
            return
        end

        -- Skill dead or do not show empty stacks
        SFC:Trace(1, "Skill inactive or don't show empty stacks")
        SFC.SFCTexture:SetTextureCoords(SFC.TEXTURE_FRAMES[0].REL, SFC.TEXTURE_FRAMES[1].REL, 0, 1)

    end
end

function SFC.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(SFC.prefix .. "Setting debug level to 0 (Off)")
        SFC.debugMode = 0
        SFC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(SFC.prefix .. "Setting debug level to 1 (Low)")
        SFC.debugMode = 1
        SFC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(SFC.prefix .. "Setting debug level to 2 (Medium)")
        SFC.debugMode = 2
        SFC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(SFC.prefix .. "Setting debug level to 3 (High)")
        SFC.debugMode = 3
        SFC.preferences.debugMode = 3

    -- Position Options -------------------------------------------------------
    elseif command == "position reset" then
        d(SFC.prefix .. "Resetting position to reticle")
        local tempPos = SFC.preferences.lockedToReticle
        SFC.preferences.lockedToReticle = true
        SFC.SetPosition()
        SFC.preferences.lockedToReticle = tempPos
    elseif command == "position show" then
        d(SFC.prefix .. "Display position is set to: [" ..
            SFC.preferences.positionTop ..
            ", " ..
            SFC.preferences.positionLeft ..
            "]")
    elseif command == "position lock" then
        d(SFC.prefix .. "Locking display")
        SFC.preferences.unlocked = false
        SFC.SFCContainer:SetMovable(false)
    elseif command == "position unlock" then
        d(SFC.prefix .. "Unlocking display")
        SFC.preferences.unlocked = true
        SFC.SFCContainer:SetMovable(true)

    -- Manage Registration ----------------------------------------------------
    elseif command == "register" then
        d(SFC.prefix .. "Reregistering all events")
        SFC.UnregisterEvents()
        SFC.RegisterEvents()
    elseif command == "unregister" then
        d(SFC.prefix .. "Unregistering all events")
        SFC.UnregisterEvents()
        SFC.abilityActive = false
        SFC.UpdateStacks(0)
    elseif command == "register unfiltered" then
        d(SFC.prefix .. "Unregistering all events")
        SFC.UnregisterEvents()
        SFC.abilityActive = false
        SFC.UpdateStacks(0)
        d(SFC.prefix .. "Registering for ALL events unfiltered")
        SFC.RegisterUnfilteredEvents()
    elseif command == "unregister unfiltered" then
        d(SFC.prefix .. "Unregistering unfiltered events")
        SFC.UnregisterUnfilteredEvents()
        SFC.abilityActive = false
        SFC.UpdateStacks(0)

    -- Default ----------------------------------------------------------------
    else
        d(SFC.prefix .. "Command not recognized!")
    end
end

