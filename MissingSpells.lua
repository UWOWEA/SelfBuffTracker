local addonName, addon = ...

local function getMissingSpells()
    local missingSpells = {}

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled then
            local isPresent = false
            local targetName = spellInput:lower()
            local spellID = tonumber(spellInput)

            if spellID and C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                isPresent = true
            end

            if not isPresent and C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellInput)
                if info and info.spellID and C_UnitAuras.GetPlayerAuraBySpellID(info.spellID) then
                    isPresent = true
                end
            end

            if not isPresent and C_UnitAuras.GetAuraDataBySpellName then
                local aura = C_UnitAuras.GetAuraDataBySpellName("player", spellInput, "HELPFUL")
                    or C_UnitAuras.GetAuraDataBySpellName("player", targetName, "HELPFUL")
                if aura then
                    isPresent = true
                end
            end

            if not isPresent then
                table.insert(missingSpells, spellInput)
            end
        end
    end

    return missingSpells
end

addon.getMissingSpells = getMissingSpells