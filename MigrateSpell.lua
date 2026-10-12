local _, addon = ...
local Core = _G["Core"]


local function GetSpellDisplayNameAndIcon(spellInput)
    local spellID = tonumber(spellInput)

    if spellID then
        local targetID = spellID
        local overrideID = Core.Spells:GetOverrideSpell(spellID)
        if overrideID and overrideID > 0 then
            targetID = overrideID
        end

        local info = Core.Spells:GetInfo(targetID) or Core.Spells:GetInfo(spellID)
        if info then
            return info.name or ("Spell " .. spellInput), info.iconID or info.icon
        end
    end

    local info = Core.Spells:GetInfo(spellInput)
    if info then
        return info.name or spellInput, info.iconID or info.icon
    end

    if spellID then
        local itemInfo = Core.Item:GetInfo(spellID)
        if itemInfo and itemInfo.itemName and itemInfo.itemName ~= "" then
            return itemInfo.itemName, itemInfo.itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark"
        end
    end

    if addon.Database.Flasks then
        for _, entry in ipairs(addon.Database.Flasks) do
            if tostring(entry.spellID) == tostring(spellInput) then
                local spellInfo = Core.Spells:GetInfo(entry.spellID)
                if spellInfo then
                    return spellInfo.name, spellInfo.iconID or spellInfo.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
                end
                return entry.name, entry.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
            end
        end
    end

    return spellInput, "Interface\\Icons\\INV_Misc_QuestionMark"
end

addon.GetSpellDisplayNameAndIcon = GetSpellDisplayNameAndIcon
