local addonName, addon = ...

local function IsBuffSpell(spellID)
    if not spellID then return false end

    -- Retail
    if C_Spell and C_Spell.IsSpellHelpful then
        local ok, result = pcall(C_Spell.IsSpellHelpful, spellID)
        if ok then return result end
    end

    -- Cata / Wrath
    if IsHelpfulSpell then
        local ok, result = pcall(IsHelpfulSpell, spellID)
        if ok then return result end
    end

    return false
end

local function IsHarmfulSpellSafe(spellID)
    if not spellID then return false end

    if C_Spell and C_Spell.IsSpellHarmful then
        local ok, result = pcall(C_Spell.IsSpellHarmful, spellID)
        if ok then return result end
    end

    if IsHarmfulSpell then
        local ok, result = pcall(IsHarmfulSpell, spellID)
        if ok then return result end
    end

    return false
end

local function IsSpellKnownSafe(spellID)
    if not spellID then return true end

    if C_SpellBook and C_SpellBook.IsSpellKnown then
        local ok, result = pcall(C_SpellBook.IsSpellKnown, spellID)
        if ok then return result end
    end

    if C_SpellBook and C_SpellBook.IsSpellKnownOrOverridesKnown then
        local ok, result = pcall(C_SpellBook.IsSpellKnownOrOverridesKnown, spellID)
        if ok then return result end
    end

    if IsSpellKnownOrOverridesKnown then
        local ok, result = pcall(IsSpellKnownOrOverridesKnown, spellID)
        if ok then return result end
    end

    if IsPlayerSpell then
        local ok, result = pcall(IsPlayerSpell, spellID)
        if ok then return result end
    end

    return true
end

local function IsSpellCurrentlyAvailable(spellID)
    if not spellID then return true end

    if not IsSpellKnownSafe(spellID) then return false end

    if C_Spell and C_Spell.IsSpellDisabled then
        local ok, isDisabled = pcall(C_Spell.IsSpellDisabled, spellID)
        if ok and isDisabled then return false end
    elseif IsSpellDisabled then
        local ok, isDisabled = pcall(IsSpellDisabled, spellID)
        if ok and isDisabled then return false end
    end

    if C_Spell and C_Spell.IsSpellUsable then
        local ok, isUsable, insufficientResources = pcall(C_Spell.IsSpellUsable, spellID)
        if ok then return isUsable or insufficientResources end
    end

    if IsUsableSpell then
        local ok, isUsable, insufficientResources = pcall(IsUsableSpell, spellID)
        if ok then return isUsable or insufficientResources end
    end

    return true
end

local function GetSpellNameAndIcon(spellID)
    if not spellID or not C_Spell or not C_Spell.GetSpellInfo then return nil, nil end

    local ok, a, _, c = pcall(C_Spell.GetSpellInfo, spellID)
    if not ok or not a then return nil, nil end

    if type(a) == "table" then
        return a.name, a.iconID
    end

    return a, c
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

local function GetShapeshiftFormSpellIDs()
    local ids = {}

    if not GetNumShapeshiftForms then return ids end

    local ok, numForms = pcall(GetNumShapeshiftForms)
    if not ok or not numForms then return ids end

    for i = 1, numForms do
        local formOk, _, _, _, spellID = pcall(GetShapeshiftFormInfo, i)
        if formOk and spellID then
            ids[spellID] = true
        end
    end

    return ids
end

local ExcludedUtilitySpellNames = {
    ["Rootwalking"] = true,
    ["Mobile Banking"] = true,
    ["Revive Battle Pets"] = true,
    ["Prowl"] = true,
    ["Anomaly Detection Mark I"] = true,
    ["Recuperate"] = true,
    ["Dreamwalk"] = true,
    ["Bull Rush"] = true,
    ["Remove Corruption"] = true,
    ["Stampeding Roar"] = true,
}

local ExcludedSkillLineNames = {
    ["Battle Pets"] = true,
}

local function GetSpellbookEntries(buffsOnly)
    local entries = {}
    local seen = {}
    local shapeshiftFormIDs = GetShapeshiftFormSpellIDs()

    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and Enum and Enum.SpellBookSpellBank then
        local numSkillLines = C_SpellBook.GetNumSpellBookSkillLines()
        for skillLineIndex = 1, numSkillLines do
            local ok, skillLineInfo = pcall(C_SpellBook.GetSpellBookSkillLineInfo, skillLineIndex)
            if ok and skillLineInfo and not skillLineInfo.shouldHide and not skillLineInfo.isGuild
                and not ExcludedSkillLineNames[skillLineInfo.name] then
                local offset = skillLineInfo.itemIndexOffset
                for i = 1, skillLineInfo.numSpellBookItems do
                    local index = offset + i
                    local itemOk, itemInfo = pcall(C_SpellBook.GetSpellBookItemInfo, index, Enum.SpellBookSpellBank.Player)
                    if itemOk and itemInfo and itemInfo.name and not itemInfo.isPassive and itemInfo.itemType == Enum.SpellBookItemType.Spell
                        and not seen[itemInfo.name] and not ExcludedUtilitySpellNames[itemInfo.name] then
                        local spellID = itemInfo.spellID or itemInfo.actionID
                        if not shapeshiftFormIDs[spellID] then
                            local isBuff = IsBuffSpell(spellID)
                            local isRelevant = isBuff or IsHarmfulSpellSafe(spellID)
                            if isRelevant and (not buffsOnly or isBuff) and IsSpellCurrentlyAvailable(spellID) then
                                seen[itemInfo.name] = true
                                table.insert(entries, {
                                    name = itemInfo.name,
                                    iconID = itemInfo.iconID,
                                    category = skillLineInfo.name,
                                    isBuff = isBuff,
                                })
                            end
                        end
                    end
                end
            end
        end
    elseif GetNumSpellTabs then
        local numTabs = GetNumSpellTabs()
        local bookType = BOOKTYPE_SPELL or "spell"

        for tabIndex = 1, numTabs do
            local name, texture, offset, numSpells, isGuild, offSpecID = GetSpellTabInfo(tabIndex)
            if name and not ExcludedSkillLineNames[name] then
                for i = 1, numSpells do
                    local spellIndex = offset + i
                    local isPassive = false
                    
                    if IsPassiveSpell then
                        isPassive = IsPassiveSpell(spellIndex, bookType)
                    end
                    if not isPassive then
                        local spellName, spellSubName = GetSpellBookItemName(spellIndex, bookType)
                        local iconID = GetSpellBookItemTexture(spellIndex, bookType)
                        
                        if spellName and not seen[spellName] and not ExcludedUtilitySpellNames[spellName] then
                            local link = GetSpellBookItemLink and GetSpellBookItemLink(spellIndex, bookType)
                            local spellID = nil

                            if GetSpellBookItemInfo then
                                local itemType, id = GetSpellBookItemInfo(spellIndex, bookType)
                                if itemType == "SPELL" or itemType == "FUTURESPELL" then
                                    spellID = id
                                end
                            end

                            if not spellID and C_Spell and C_Spell.GetSpellInfo then
                                local info = C_Spell.GetSpellInfo(spellName)
                                if info and info.spellID then
                                    spellID = info.spellID
                                end
                            end

                            if not spellID and GetSpellBookItemLink then
                                local link = GetSpellBookItemLink(spellIndex, bookType)
                                spellID = link and tonumber(link:match("spell:(%d+)"))
                            end

                            if not (spellID and shapeshiftFormIDs[spellID]) then
                                local isBuff = IsBuffSpell(spellID)
                                local isRelevant = isBuff or IsHarmfulSpellSafe(spellID)

                                if not isRelevant and spellID then
                                    isBuff = false
                                    isRelevant = true
                                end

                                if isRelevant and (isBuff and buffsOnly) then
                                    seen[spellName] = true
                                    table.insert(entries, {
                                        name = spellName,
                                        iconID = iconID,
                                        category = name,
                                        isBuff = isBuff,
                                        isRecommended = true,
                                    })
                                elseif isRelevant and (not buffsOnly or isBuff) then
                                    seen[spellName] = true
                                    table.insert(entries, {
                                        name = spellName,
                                        iconID = iconID,
                                        category = name,
                                        isBuff = isBuff,
                                    })
                                end
                            end
                        end
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

local function CreatePickerFrame()
    local f = CreateFrame("Frame", "SelfBuffTrackerSpellPicker", UIParent, "BackdropTemplate")
    f:SetSize(340, 420)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText(addon.L.PICKER_TITLE)
    addon.ApplyFont(title, "normalLarge")

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() f:Hide() end)

    local searchBox = CreateFrame("EditBox", "SelfBuffTrackerSpellPickerSearch", f, "SearchBoxTemplate")
    searchBox:SetSize(200, 20)
    searchBox:SetPoint("TOP", title, "BOTTOM", -20, -12)

    local buffsOnlyCheck = CreateFrame("CheckButton", "SelfBuffTrackerSpellPickerBuffsOnly", f, "UICheckButtonTemplate")
    buffsOnlyCheck:SetPoint("LEFT", searchBox, "RIGHT", 4, 0)
    buffsOnlyCheck:SetSize(22, 22)
    buffsOnlyCheck:SetChecked(true)
    local buffsOnlyLabel = buffsOnlyCheck:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    buffsOnlyLabel:SetPoint("LEFT", buffsOnlyCheck, "RIGHT", 2, 1)
    buffsOnlyLabel:SetText(addon.L.PICKER_BUFFS_ONLY)
    addon.ApplyFont(buffsOnlyLabel, "highlightSmall")

    local hintText = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    hintText:SetPoint("TOP", searchBox, "BOTTOM", 20, -4)
    hintText:SetText(addon.L.PICKER_HINT_SPEC)
    addon.ApplyFont(hintText, "disableSmall")

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerSpellPickerScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -84)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 16)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local rows = {}

    local function RefreshList()
        local filter = searchBox:GetText():lower()
        local entries = GetSpellbookEntries(buffsOnlyCheck:GetChecked())

        local shown = {}
        for _, entry in ipairs(entries) do
            if filter == "" or entry.name:lower():find(filter, 1, true) then
                table.insert(shown, entry)
            end
        end

        for _, row in ipairs(rows) do row:Hide() end
        scrollChild:SetSize(scrollFrame:GetWidth(), math.max(#shown * 24, 1))

        if #entries == 0 then
            hintText:SetText(addon.L.PICKER_HINT_FAIL)
        else
            hintText:SetText(addon.L.PICKER_HINT_SPEC)
        end

        for i, entry in ipairs(shown) do
            local row = rows[i]
            if not row then
                row = CreateFrame("Button", nil, scrollChild)
                row:SetHeight(22)
                row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(18, 18)
                row.icon:SetPoint("LEFT", 2, 0)

                row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
                row.text:SetPoint("RIGHT", -2, 0)
                row.text:SetJustifyH("LEFT")
                addon.ApplyFont(row.text, "highlight")

                rows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * 24)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(entry.iconID)
            row.text:SetText(entry.isRecommended and ("|cff00ccff" .. entry.name .. "|r") or entry.name)
            row:SetScript("OnClick", function()
                SelfBuffTrackerDB.trackedSpells[entry.name] = true
                addon.CheckBuffs()
                if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
                print("|cff00ff00[SBT]|r " .. string.format(addon.L.PICKER_ADDED, entry.name))
            end)
            row:Show()
        end
    end

    searchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        RefreshList()
    end)

    buffsOnlyCheck:SetScript("OnClick", RefreshList)

    f.RefreshList = RefreshList
    f:Hide()
    return f
end

function addon.ToggleSpellPicker()
    if not pickerFrame then
        pickerFrame = CreatePickerFrame()
    end

    if pickerFrame:IsShown() then
        pickerFrame:Hide()
    else
        pickerFrame:Show()
        pickerFrame.RefreshList()
    end
end
