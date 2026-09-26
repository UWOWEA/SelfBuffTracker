local addonName, addon = ...

local function MigrateTrackedSpellsToIDs()
    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedSpells then return end

    local updatedSpells = {}
    local migratedCount = 0

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        local spellID = tonumber(spellInput)

        if spellID then
            updatedSpells[tostring(spellID)] = enabled
        else
            local officialID = nil

            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellInput)
                if info and info.spellID then
                    officialID = info.spellID
                end
            end

            if officialID then
                updatedSpells[tostring(officialID)] = enabled
                migratedCount = migratedCount + 1
            else
                updatedSpells[spellInput] = enabled
            end
        end
    end

    SelfBuffTrackerDB.trackedSpells = updatedSpells

    if SelfBuffTrackerDB.isDebug and migratedCount > 0 then
        print("|cff00ff00[SBT Debug]|r migrated " .. migratedCount .. " spells to Spell ID.")
    end
end

addon.MigrateTrackedSpellsToIDs = MigrateTrackedSpellsToIDs

local function GetSpellDisplayNameAndIcon(spellInput)
    local spellID = tonumber(spellInput)

    if spellID and C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            return info.name or ("Spell " .. spellInput), info.iconID
        end
    end

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellInput)
        if info then
            return info.name or spellInput, info.iconID
        end
    end

    return spellInput, "Interface\\Icons\\INV_Misc_QuestionMark"
end

addon.GetSpellDisplayNameAndIcon = GetSpellDisplayNameAndIcon