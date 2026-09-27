local addonName, addon = ...

addon.activeBuffTimers = addon.activeBuffTimers or {}
addon.auraIDCache = addon.auraIDCache or {}

local function IsAuraActiveOnPlayer(spellInput)
    local now = GetTime()
    local spellID = tonumber(spellInput)
    local officialName = nil

    local buffTimers = addon.activeBuffTimers or {}
    local auraCache = addon.auraIDCache or {}
    local inCombat = InCombatLockdown()

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID or spellInput)
        if info then
            officialName = info.name and info.name:lower()
            spellID = spellID or info.spellID
        end
    end

    if spellID and buffTimers[tostring(spellID)] then
        if buffTimers[tostring(spellID)] > now then
            return true
        end
    end

    if officialName and buffTimers[officialName] then
        if buffTimers[officialName] > now then
            return true
        end
    end

    if inCombat then
        if spellID and auraCache[tostring(spellID)] then
            return true
        end
        if officialName and auraCache[officialName] then
            return true
        end
    end

    if spellID then
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
        if ok and aura then return true end

        if C_Spell and C_Spell.GetOverrideSpell then
            local overrideID = C_Spell.GetOverrideSpell(spellID)

            if overrideID and overrideID ~= spellID then
                local okOv, auraOv = pcall(C_UnitAuras.GetPlayerAuraBySpellID, overrideID)
                if okOv and auraOv then return true end
            end
        end
    end

    if not InCombatLockdown() then
        local filters = { "HELPFUL" }
        if SelfBuffTrackerDB and SelfBuffTrackerDB.isFlasksAllowed then
            table.insert(filters, "HELPFUL|CANCELABLE")
        end

        for _, filter in ipairs(filters) do
            for i = 1, 80 do
                local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, filter)
                if not ok or not aura then break end

                if officialName and aura.name and aura.name:lower() == officialName then
                    if aura.spellId then
                        auraCache[officialName] = aura.spellId
                        if spellID then
                            auraCache[tostring(spellID)] = aura.spellId
                        end
                    end
                    return true
                end

                if spellID and aura.spellId and aura.spellId == spellID then
                    return true
                end
            end
        end
    end
    return false
end

local function getMissingSpells()
    local missingSpells = {}

    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedSpells then
        return missingSpells
    end
    if not InCombatLockdown() and addon.UpdateAuraCache then
        addon.UpdateAuraCache()
    end

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled then
            local isPresent = IsAuraActiveOnPlayer(spellInput)

            if SelfBuffTrackerDB.isDebug then
                print("[SBT Debug] Key:", spellInput, "| isPresent:", isPresent)
            end

            if not isPresent then
                table.insert(missingSpells, spellInput)
            end
        end
    end

    if SelfBuffTrackerDB.isFlasksAllowed and SelfBuffTrackerDB.trackedFlasks then
        for flaskInput, enabled in pairs(SelfBuffTrackerDB.trackedFlasks) do
            if enabled then
                if not IsAuraActiveOnPlayer(tostring(flaskInput)) then
                    table.insert(missingSpells, tostring(flaskInput))
                end
            end
        end
    end

    return missingSpells
end

addon.getMissingSpells = getMissingSpells