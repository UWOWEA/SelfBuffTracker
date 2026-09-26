local addonName, addon = ...

local category
local spellRows = {}

local function CreateTrackedBuffsSubcategory(parentCategory)
    local L = addon.L

    local panel = CreateFrame("Frame", "SelfBuffTrackerBuffsPanel", UIParent)
    panel.name = L.TRACKED_BUFFS

    local copyLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    copyLabel:SetPoint("TOPLEFT", 16, -16)
    copyLabel:SetText(L.COPY_LABEL)
    addon.ApplyFont(copyLabel, "normal")

    local copyDropdown = CreateFrame("Frame", "SelfBuffTrackerOptionsCopyDropdown", panel, "UIDropDownMenuTemplate")
    copyDropdown:SetPoint("TOPLEFT", copyLabel, "BOTTOMLEFT", -16, -4)
    UIDropDownMenu_SetWidth(copyDropdown, 160)

    local selectedProfileKey

    local function RefreshCopyDropdown()
        selectedProfileKey = nil
        UIDropDownMenu_SetText(copyDropdown, L.COPY_SELECT_CHARACTER)

        UIDropDownMenu_Initialize(copyDropdown, function(dropdown, level)
            for _, profile in ipairs(addon.GetOtherClassProfiles and addon.GetOtherClassProfiles() or {}) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = profile.name .. " - " .. profile.realm
                info.func = function()
                    selectedProfileKey = profile.key
                    UIDropDownMenu_SetText(copyDropdown, info.text)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
    end

    local copyButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyButton:SetSize(100, 22)
    copyButton:SetText(L.COPY_BUTTON)
    copyButton:SetPoint("LEFT", copyDropdown, "RIGHT", 8, 2)
    addon.ApplyFont(copyButton, "highlight")
    copyButton:SetScript("OnClick", function()
        if selectedProfileKey and addon.CopyProfileFrom then
            addon.CopyProfileFrom(selectedProfileKey)
            print("|cff00ff00[SBT]|r " .. L.COPY_DONE)
        end
    end)

    local spellsLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    spellsLabel:SetPoint("TOPLEFT", copyDropdown, "BOTTOMLEFT", 16, -20)
    spellsLabel:SetText(L.TRACKED_BUFFS)
    addon.ApplyFont(spellsLabel, "normalLarge")

    local spellEditBox = CreateFrame("EditBox", "SelfBuffTrackerOptionsSpellEditBox", panel, "InputBoxTemplate")
    spellEditBox:SetAutoFocus(false)
    spellEditBox:SetSize(200, 20)
    spellEditBox:SetPoint("TOPLEFT", spellsLabel, "BOTTOMLEFT", 8, -12)

    local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(80, 22)
    addButton:SetText(L.ADD_BUTTON)
    addButton:SetPoint("LEFT", spellEditBox, "RIGHT", 8, 0)
    addon.ApplyFont(addButton, "highlight")

    local spellbookButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    spellbookButton:SetSize(150, 22)
    spellbookButton:SetText(L.SPELLBOOK_BUTTON)
    spellbookButton:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
    addon.ApplyFont(spellbookButton, "highlight")
    spellbookButton:SetScript("OnClick", function()
        if addon.ToggleSpellPicker then
            addon.ToggleSpellPicker()
        end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", spellEditBox, "BOTTOMLEFT", -4, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 16)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local ROW_HEIGHT = 30

    local function GetSpellIcon(spellName)
        local info = C_Spell.GetSpellInfo(spellName)
        if info and info.iconID then
            return info.iconID
        end
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end

    local function RefreshSpellList()
        for _, row in ipairs(spellRows) do row:Hide() end

        local spells = {}
        for spell, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
            if enabled then table.insert(spells, spell) end
        end
        table.sort(spells)

        scrollChild:SetSize(scrollFrame:GetWidth(), math.max(#spells * ROW_HEIGHT, 1))

        for i, spell in ipairs(spells) do
            local row = spellRows[i]
            if not row then
                row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
                row:SetHeight(ROW_HEIGHT)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Buttons\\WHITE8X8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(1, 1, 1, 0.05)
                row:SetBackdropBorderColor(1, 1, 1, 0.08)
                row:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.12) end)
                row:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(22, 22)
                row.icon:SetPoint("LEFT", 6, 0)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                row.removeButton = CreateFrame("Button", nil, row)
                row.removeButton:SetSize(18, 18)
                row.removeButton:SetPoint("RIGHT", -8, 0)
                row.removeButton:SetNormalAtlas("common-icon-redx")
                row.removeButton:SetPushedAtlas("common-icon-redx")
                row.removeButton:SetHighlightAtlas("common-icon-redx", "ADD")

                row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.text:SetPoint("RIGHT", row.removeButton, "LEFT", -8, 0)
                row.text:SetJustifyH("LEFT")
                addon.ApplyFont(row.text, "highlight")

                spellRows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(GetSpellIcon(spell))
            row.text:SetText(spell)
            row.removeButton:SetScript("OnClick", function()
                SelfBuffTrackerDB.trackedSpells[spell] = nil
                addon.CheckBuffs(false)
                RefreshSpellList()
            end)
            row:Show()
        end
    end

    addButton:SetScript("OnClick", function()
        local text = strtrim(spellEditBox:GetText() or "")
        if text ~= "" then
            SelfBuffTrackerDB.trackedSpells[text] = true
            spellEditBox:SetText("")
            addon.CheckBuffs(false)
            RefreshSpellList()
        end
    end)
    spellEditBox:SetScript("OnEnterPressed", function(self)
        addButton:Click()
        self:ClearFocus()
    end)

    local function RefreshValues()
        RefreshCopyDropdown()
        RefreshSpellList()
    end

    panel:SetScript("OnShow", RefreshValues)
    addon.RefreshOptionsPanel = RefreshValues

    Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, panel.name)
    RefreshValues()
end

local function AddCheckbox(cat, variableKey, name, defaultValue, getValue, setValue)
    local setting = Settings.RegisterProxySetting(cat, variableKey, Settings.VarType.Boolean, name, defaultValue, getValue, setValue)
    Settings.CreateCheckbox(cat, setting)
    return setting
end

local function AddSlider(cat, variableKey, name, minValue, maxValue, step, defaultValue, getValue, setValue)
    local setting = Settings.RegisterProxySetting(cat, variableKey, Settings.VarType.Number, name, defaultValue, getValue, setValue)
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return tostring(math.floor(value + 0.5))
    end)
    Settings.CreateSlider(cat, setting, options)
    return setting
end

local function AddDropdown(cat, variableKey, name, defaultValue, getValue, setValue, getOptionsList)
    local setting = Settings.RegisterProxySetting(cat, variableKey, Settings.VarType.String, name, defaultValue, getValue, setValue)
    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        for _, entry in ipairs(getOptionsList()) do
            container:Add(entry.value, entry.text)
        end
        return container:GetData()
    end
    Settings.CreateDropdown(cat, setting, GetOptions)
    return setting
end

local function BuildNativeSettingsPanel()
    local L = addon.L

    category = Settings.RegisterVerticalLayoutCategory(L.OPTIONS_TITLE)

    AddDropdown(category, "SBT_Language", L.LANGUAGE_LABEL, "auto",
        function() return SelfBuffTrackerDB.locale or "auto" end,
        function(value)
            SelfBuffTrackerDB.locale = value
            addon.RefreshLocale()
            print("|cff00ff00[SBT]|r " .. addon.L.RELOAD_HINT)
        end,
        function()
            local list = {}
            for _, entry in ipairs(addon.AvailableLocales) do
                table.insert(list, { value = entry.code, text = entry.name })
            end
            return list
        end)

    AddCheckbox(category, "SBT_SoundEnabled", L.SOUND_ENABLED, true,
        function() return SelfBuffTrackerDB.soundEnabled end,
        function(value) SelfBuffTrackerDB.soundEnabled = value end)

    AddCheckbox(category, "SBT_Locked", L.LOCKED_POSITION, false,
        function() return SelfBuffTrackerDB.isLocked end,
        function(value)
            SelfBuffTrackerDB.isLocked = value
            addon.CheckBuffs(false)
        end)

    AddSlider(category, "SBT_IconSize", L.ICON_SIZE, 20, 100, 1, 50,
        function() return SelfBuffTrackerDB.iconSize end,
        function(value)
            SelfBuffTrackerDB.iconSize = value
            addon.CheckBuffs(false)
        end)

    AddSlider(category, "SBT_Spacing", L.ICON_SPACING, 0, 30, 1, 10,
        function() return SelfBuffTrackerDB.spacing end,
        function(value)
            SelfBuffTrackerDB.spacing = value
            addon.CheckBuffs(false)
        end)

    AddSlider(category, "SBT_ReminderInterval", L.REMINDER_INTERVAL, 0.1, 180, 0.1, 0.5,
        function() return SelfBuffTrackerDB.soundReminderInterval end,
        function(value) SelfBuffTrackerDB.soundReminderInterval = value end)

    AddDropdown(category, "SBT_SoundKit", L.SOUND_LABEL, "RAID_WARNING",
        function() return SelfBuffTrackerDB.soundKit end,
        function(value)
            SelfBuffTrackerDB.soundKit = value
            local kitID = SOUNDKIT[value]
            if kitID then PlaySound(kitID, "Master") end
        end,
        function()
            local list = {}
            for _, preset in ipairs(addon.SoundPresets) do
                table.insert(list, { value = preset.kit, text = preset.label })
            end
            return list
        end)
    

    AddCheckbox(category, "SBT_Debug", L.DEBUG_ENABLED, true,
        function() return SelfBuffTrackerDB.isDebug end,
        function(value) SelfBuffTrackerDB.isDebug = value end)

    Settings.RegisterAddOnCategory(category)

    CreateTrackedBuffsSubcategory(category)

    addon.OpenOptionsPanel = function()
        Settings.OpenToCategory(category:GetID())
    end
end

function addon.InitOptionsPanel()
    if category then return end

    local ok, err = pcall(BuildNativeSettingsPanel)
    if not ok then
        category = nil
        print("|cffff0000[SBT]|r Initialization error: " .. tostring(err))
    end
end

