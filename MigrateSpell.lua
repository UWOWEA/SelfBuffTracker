local _, addon = ...
local Core = _G["Core"]


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
