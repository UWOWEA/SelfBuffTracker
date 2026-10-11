local addonName, addon = ...
local Core = _G["Core"]

local function MigrateTrackedSpellsToIDs()
    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedSpells then return end

    local updatedSpells = {}
    local migratedCount = 0

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        local spellID = tonumber(spellInput)
        local targetID = spellID

        if not targetID then
            local info = Core.Spells:GetInfo(spellInput)
            if info and info.spellID then
                targetID = info.spellID
            end
        end

        if targetID and C_Spell and C_Spell.GetOverrideSpell then
            local overrideID = C_Spell.GetOverrideSpell(targetID)
            if overrideID and overrideID > 0 then
                targetID = overrideID
            end
        end

        if targetID then
            local keyStr = tostring(targetID)
            updatedSpells[keyStr] = enabled

            if keyStr ~= tostring(spellInput) then
                migratedCount = migratedCount + 1
            end
        else
            updatedSpells[spellInput] = enabled
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

    if spellID then
        local targetID = spellID
        if C_Spell.GetOverrideSpell then
            local overrideID = C_Spell.GetOverrideSpell(spellID)
            if overrideID and overrideID > 0 then
                targetID = overrideID
            end
        end

        local info = Core.Spells:GetInfo(targetID) or Core.Spells:GetInfo(spellID)
        if info then
            return info.name or ("Spell " .. spellInput), info.iconID
        end
    end

    local info = Core.Spells:GetInfo(spellInput)
    if info then
        return info.name or spellInput, info.iconID
    end

    if spellID and C_Item and C_Item.GetItemInfo then
        local itemName, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(spellID)
        if itemName and itemName ~= "" then
            return itemName, itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
        end
    end

    if addon.Database.Flasks then
        for _, entry in ipairs(addon.Database.Flasks) do
            if tostring(entry.spellID) == tostring(spellInput) then
                local spellInfo = Core.Spells:GetInfo(entry.spellID)
                if spellInfo then
                    return spellInfo.name, spellInfo.iconID or "Interface\\Icons\\INV_Misc_QuestionMark"
                end
                return entry.name, entry.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
            end
        end
    end

    return spellInput, "Interface\\Icons\\INV_Misc_QuestionMark"
end

addon.GetSpellDisplayNameAndIcon = GetSpellDisplayNameAndIcon
