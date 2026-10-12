local addonName, addon = ...
local Core = _G["Core"]
local UI = _G["UI"]

local function GetSpellNameAndIcon(spellID)
    if not spellID then return nil, nil end
    spellID = Core.Spells:NormalizeSpellID(spellID)

    local info = Core.Spells:GetInfo(spellID)
    return info and info.name, info and (info.iconID or info.icon)
end

local function GetCooldownViewerBuffEntries()
    local entries = {}

    if not (C_CooldownViewer and C_CooldownViewer.GetGroupBuffItems) then
        return entries
    end

    local ok, items = pcall(C_CooldownViewer.GetGroupBuffItems)
    if not ok or not items then return entries end

    for _, item in ipairs(items) do
        local spellID

        if type(item) == "number" then
            spellID = item
            if C_CooldownViewer.GetCooldownViewerCooldownInfo then
                local infoOk, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, item)
                if infoOk and info and info.spellID then
                    spellID = info.spellID
                end
            end
        elseif type(item) == "table" then
            spellID = item.spellID or item.overrideSpellID or (item.linkedSpellIDs and item.linkedSpellIDs[1])
        end

        local name, iconID = GetSpellNameAndIcon(spellID)
        if name then
            table.insert(entries, {
                name = name,
                iconID = iconID,
                category = "Cooldown Manager",
                isBuff = true,
                isRecommended = true,
            })
        end
    end

    return entries
end

local ExcludedUtilitySpellNames = {
    -- Basic attacks
    ["Attack"] = true,
    ["Auto Shot"] = true,
    ["Shoot"] = true,
    ["Throw"] = true,

    ["Rootwalking"] = true,
    ["Mobile Banking"] = true,
    ["Revive Battle Pets"] = true,
    ["Prowl"] = true,
    ["Anomaly Detection Mark I"] = true,
    ["Recuperate"] = true,
    ["Bull Rush"] = true,
    ["Remove Corruption"] = true,
    ["Stampeding Roar"] = true,

    -- Professions
    ["Basic Campfire"] = true,
    ["Alchemy"] = true,
    ["First Aid"] = true,
    ["Cooking"] = true,
    ["Fishing"] = true,
    ["Skinning"] = true,
    ["Leatherworking"] = true,
    ["Engineering"] = true,
    ["Enchanting"] = true,
    ["Tailoring"] = true,
    ["Mining"] = true,
    ["Herbalism"] = true,
    ["Blacksmithing"] = true,
    ["Find Herbs"] = true,
}

local ExcludedSkillLineNames = {
    ["Battle Pets"] = true,
    ["Professions"] = true,
    ["Secondary Skills"] = true,
    ["First Aid"] = true,
    ["Cooking"] = true,
    ["Fishing"] = true,
    ["Archaeology"] = true,
}

local function GetSpellbookEntries(buffsOnly)
    local entries = {}
    local seen = {}
    local shapeshiftFormIDs = Core.Spells:GetShapeshiftFormSpellIDs()

    for _, bookEntry in ipairs(Core.Spells:GetSpellbookEntries()) do
        local spellName = bookEntry.name
        local spellID = Core.Spells:NormalizeSpellID(bookEntry.spellID)
        local spellInfo = Core.Spells:GetInfo(spellID or spellName)
        spellID = spellID or (spellInfo and spellInfo.spellID)

        if spellName and not seen[spellName] and not ExcludedUtilitySpellNames[spellName]
            and not ExcludedSkillLineNames[bookEntry.category] and spellInfo
            and not shapeshiftFormIDs[spellID] and not spellInfo:IsAutoAttackSpell()
            and not spellInfo:IsSpellDisabled() and not spellInfo:IsTeleport()
            and not spellInfo:IsConsumableSpell() then
            local overrides = spellInfo:GetOverrides()
            local trackedAuraID = overrides[1]
            local isBuff = trackedAuraID ~= nil or spellInfo:IsHelpful()
            local isRelevant = isBuff or spellInfo:IsHarmful()

            if not isRelevant and spellID and bookEntry.isLegacy then
                isRelevant = true
            end

            if isRelevant and (not buffsOnly or isBuff)
                and Core.Spells:IsAvailable(spellID or spellName) then
                seen[spellName] = true
                table.insert(entries, {
                    name = spellName,
                    iconID = bookEntry.iconID or spellInfo.iconID or spellInfo.icon,
                    category = bookEntry.category,
                    isBuff = isBuff,
                    spellID = spellID,
                    trackedAuraID = trackedAuraID,
                    isRecommended = trackedAuraID ~= nil,
                    isHelpfulSpell = spellInfo:IsHelpful(),
                })
            end
        end
    end

    if addon.Database.RecommendedSpells then
        for _, id in ipairs(addon.Database.RecommendedSpells) do
            local info = Core.Spells:GetInfo(id)
            local name = info and info.name
            if seen[name] then
                for _, existing in ipairs(entries) do
                    if existing.name == name then
                        existing.isRecommended = true
                        break
                    end
                end
            end
        end
    end

    if GetCooldownViewerBuffEntries then
        for _, entry in ipairs(GetCooldownViewerBuffEntries()) do
            if seen[entry.name] then
                for _, existing in ipairs(entries) do
                    if existing.name == entry.name then
                        existing.isRecommended = true
                        break
                    end
                end
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.isRecommended ~= b.isRecommended then
            return a.isRecommended
        end
        return a.name < b.name
    end)
    return entries
end
addon.GetSpellbookEntries = GetSpellbookEntries

local pickerFrame

local function CreatePickerFrame(parent)
    local frame = CreateFrame("Frame", "SelfBuffTrackerSpellPicker", parent or UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(380, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetTextColor(1, 0.82, 0, 1)
    frame.title:SetPoint("TOPLEFT", frame.TitleBg, "LEFT", 6, 5)
    frame.title:SetText(addon.L.PICKER_TITLE)

    local searchBox = CreateFrame("EditBox", "SelfBuffTrackerSpellPickerSearch", frame, "SearchBoxTemplate")
    searchBox:SetSize(200, 20)
    searchBox:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 20, -10)
    searchBox:SetPoint("LEFT", frame.InsetBg, "LEFT", 10, 5)

    local buffsOnlyCheck = UI.Widgets:CreateCheckboxButton("SelfBuffTrackerSpellPickerBuffsOnly", frame, addon.L.PICKER_BUFFS_ONLY, true)
    buffsOnlyCheck:SetPoint("LEFT", searchBox, "RIGHT", 4, 0)

    local hintText = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    hintText:SetPoint("TOP", searchBox, "BOTTOM", 20, -4)
    hintText:SetText(addon.L.PICKER_HINT_SPEC)
    addon.ApplyFont(hintText, "disableSmall")

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerSpellPickerScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame.InsetBg, "BOTTOMRIGHT", -28, 6)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(300, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local ROW_HEIGHT = 36
    local rows = {}

    local function RefreshList()
        for _, row in ipairs(rows) do row:Hide() end
        local yOffset = 0

        local filter = searchBox:GetText():lower()
        local entries = GetSpellbookEntries(buffsOnlyCheck.checkBox:GetChecked())

        local shown = {}
        for _, entry in ipairs(entries) do
            if filter == "" or entry.name:lower():find(filter, 1, true) then
                table.insert(shown, entry)
            end
        end

        if #entries == 0 then
            hintText:SetText(addon.L.PICKER_HINT_FAIL)
        else
            hintText:SetText(addon.L.PICKER_HINT_SPEC)
        end


        for i, entry in ipairs(shown) do
            local row = rows[i]
            if not row then
                row = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")

                row:SetHeight(ROW_HEIGHT)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Buttons\\WHITE8X8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(1, 1, 1, 0.05)
                row:SetBackdropBorderColor(1, 1, 1, 0.08)
                row:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.15) end)
                row:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(26, 26)
                row.icon:SetPoint("LEFT", 6, 0)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")

                row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.name:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                row.name:SetJustifyH("LEFT")
                rows[i] = row
            end

            local displayName, iconTexture = addon.GetSpellDisplayNameAndIcon(entry.spellID)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yOffset)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(iconTexture)
            row.name:SetText(entry.isRecommended and ("|cff00ccff" .. entry.name .. "|r") or displayName)

            row:SetScript("OnEnter", function()
                GameTooltip:SetOwner(row, "ANCHOR_TOPRIGHT")
                GameTooltip:SetSpellByID(entry.spellID)
                GameTooltip:Show()
            end)

            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row:SetScript("OnClick", function()
                local idToSave = entry.trackedAuraID or entry.spellID

                if not entry.trackedAuraID and idToSave then
                    local overrideID = Core.Spells:GetOverrideSpell(idToSave)
                    if overrideID and overrideID > 0 then
                        idToSave = overrideID
                    end
                end
                local keyToSave = idToSave and tostring(idToSave) or entry.name

                if SelfBuffTrackerDB.isDebug then
                    print("keyToSave: ", keyToSave, ", spellID: ", entry.spellID, ", spell.name: ", entry.name)
                end
                SelfBuffTrackerDB.trackedSpells[keyToSave] = true

                if addon.CheckBuffs then
                    addon.CheckBuffs(false)
                end

                if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
                print("|cff00ff00[SBT]|r " .. string.format(addon.L.PICKER_ADDED, entry.name .. " (ID: " .. (entry.spellID or "Neznámé") .. ")"))
            end)

            row:Show()
            yOffset = yOffset - ROW_HEIGHT
        end
        scrollChild:SetSize(scrollFrame:GetWidth(), math.abs(yOffset))
    end

    searchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        RefreshList()
    end)

    buffsOnlyCheck:SetCallback(RefreshList)
    frame:SetScript("OnShow", RefreshList)
    frame.RefreshList = RefreshList
    frame:Hide()
    return frame
end

---@param parent? Frame
function addon.ToggleSpellPicker(parent)
    if not pickerFrame then
        pickerFrame = CreatePickerFrame(parent)
    end

    if pickerFrame:IsShown() then
        pickerFrame:Hide()
    else
        pickerFrame:Show()
        pickerFrame.RefreshList()
    end
end
