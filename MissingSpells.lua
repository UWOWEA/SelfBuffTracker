local addonName, addon = ...

local function getMissingSpells()
    local missingSpells = {}

    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedSpells then
        return missingSpells
    end

    local _, aurasByName, aurasBySpellID = addon.GetAllPlayerAuras()

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled then
            local isPresent = false
            local spellID = tonumber(spellInput)
            local officialName = nil

            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellID or spellInput)
                if info then
                    officialName = info.name
                    spellID = spellID or info.spellID
                end
            end

            if spellID and aurasBySpellID[spellID] then
                isPresent = true
            elseif officialName and aurasByName[officialName:lower()] then
                isPresent = true
            end

            if not isPresent and spellID then
                local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
                if ok and aura then
                    isPresent = true
                end
                if not isPresent and C_Spell and C_Spell.GetOverrideSpell then
                    local overrideID = C_Spell.GetOverrideSpell(spellID)
                    if overrideID and overrideID ~= spellID then
                        local okOverride, overrideAura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, overrideID)
                        if okOverride and overrideAura then
                            isPresent = true
                        end
                    end
                end
            end

            if SelfBuffTrackerDB.isDebug then
                print("[Debug] Spell:", spellInput, "| Official:", officialName, "| isPresent:", isPresent)
            end

            if not isPresent then
                table.insert(missingSpells, spellInput)
            end
        end
    end

    return missingSpells
end

addon.getMissingSpells = getMissingSpells