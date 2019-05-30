-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local currentStack = 0

function SFC.RegisterEvents()

    -- Events for each skill morph
    -- Separate namespaces for each are required as
    -- duplicate filters against the same namespace
    -- overwrite the previously set filter.
    --
    -- These filter the EVENT_EFFECT_CHANGED event to
    -- hit the callback *only* when these specific
    -- ability IDs change and avoid the need to conditionally
    -- exclude all skills we are not interested in.

    for morph, morphTable in pairs(SFC.ABILITIES) do
        SFC:Trace(2, "Registering: " .. morph)
        for abilityType, abilityId in pairs(morphTable) do
            local name = "SFC_" .. morph .. "_" .. abilityType
            SFC:Trace(3, "Registering: " .. name .. " (" .. abilityId .. ")")

            EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, function(...) SFC.OnEffectChanged(...) end)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
    end

    -- Register start/end combat events
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_COMBAT_STATE, function(...) SFC.IsInCombat(...) end)
end

function SFC.UnregisterEvents()
    for morph, morphTable in pairs(SFC.ABILITIES) do
        for abilityType, abilityId in pairs(morphTable) do
            local name = "SFC_" .. morph .. "_" .. abilityType
            SFC:Trace(3, "Unregistering: " .. name .. " (" .. abilityId .. ")")
            EVENT_MANAGER:UnregisterForEvent(name, EVENT_EFFECT_CHANGED)
        end
    end

    EVENT_MANAGER:UnregisterForEvent(SFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
end

function SFC.RegisterUnfilteredEvents()
    EVENT_MANAGER:RegisterForEvent(SFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, function(...) SFC.IsInCombat(...) end)
    EVENT_MANAGER:RegisterForEvent(SFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, function(...) SFC.OnEffectChanged(...) end)
    SFC:Trace(3, "Registering unfiltered complete")
end

function SFC.UnregisterUnfilteredEvents()
    EVENT_MANAGER:UnregisterForEvent(SFC.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(SFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    SFC:Trace(3, "Unregistering unfiltered complete")
end

function SFC.IsInCombat(_, inCombat)
    SFC.isInCombat = inCombat

    if inCombat then
        SFC:Trace(2, "Entered Combat")
    else
        SFC:Trace(2, "Left Combat")
        SFC.UpdateStacks(currentStack)
    end

end

function SFC.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    SFC:Trace(3, effectName .. " (" .. effectAbilityId .. ")")

    -- If we have a stack
    if stackCount > 0 then
        SFC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)

        SFC.SetSkillColorOverlay('default')

        if changeType == EFFECT_RESULT_FADED then
            currentStack = 0
            SFC:Trace(2, "Faded on stack #" .. stackCount)
            SFC.UpdateStacks(currentStack)
        else
            currentStack = stackCount
            SFC:Trace(1, "Stack #" .. currentStack)

            if currentStack == 3 then
                SFC.SetSkillColorOverlay('proc')
            end

            SFC.UpdateStacks(currentStack)
        end

        return
    end

    -- Not a stack
    if changeType == EFFECT_RESULT_GAINED then
        SFC:Trace(2, "Skill Activated: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        SFC.abilityActive = true
        SFC.SetSkillFade(false)

        if currentStack == 3 then
            SFC.SetSkillColorOverlay('proc')
        else
            SFC.SetSkillColorOverlay('default')
        end

        SFC.UpdateStacks(currentStack)
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        SFC:Trace(2, "Skill Inactive: " ..  effectName .. " (" .. effectAbilityId ..") with " .. currentStack .. " stacks")
        SFC.abilityActive = false
        SFC.SetSkillFade(true)
        SFC.SetSkillColorOverlay('inactive')
        SFC.UpdateStacks(currentStack)
        return
    end

end
