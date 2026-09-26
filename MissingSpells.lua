local addonName, addon = ...

local function getMissingSpells()
    local missingSpells = {}

    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedSpells then
        return missingSpells
    end

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled then
            local isPresent = false
            local spellID = tonumber(spellInput)
            local officialName = nil

            if spellID and C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                isPresent = true
            end

            if not isPresent and C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellInput)
                if info then
                    officialName = info.name
                    if info.spellID and C_UnitAuras.GetPlayerAuraBySpellID(info.spellID) then
                        isPresent = true
                    end
                end
            end

            if not isPresent and C_UnitAuras.GetAuraDataBySpellName then
                if officialName and C_UnitAuras.GetAuraDataBySpellName("player", officialName, "HELPFUL") then
                    isPresent = true
                elseif C_UnitAuras.GetAuraDataBySpellName("player", spellInput, "HELPFUL") then
                    isPresent = true
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