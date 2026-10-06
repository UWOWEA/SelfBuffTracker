local addonName, addon = ...

local category

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

addon.AddSlider = AddSlider

local function AddDropdown(cat, variableKey, name, defaultValue, getValue, setValue, optionsList)
    local setting = Settings.RegisterProxySetting(cat, variableKey, Settings.VarType.String, name, defaultValue, getValue, setValue)

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        for _, entry in ipairs(optionsList) do
            if not entry.subcategory then
                container:Add(entry.value, entry.text)
            end
        end
        return container:GetData()
    end

    local initializer = Settings.CreateDropdown(cat, setting, GetOptions)
    local hasSubcategories = false
    for _, entry in ipairs(optionsList) do
        if entry.subcategory then
            hasSubcategories = true
            break
        end
    end

    if hasSubcategories then
        initializer.customOptionHandler = function(rootDescription)
            for _, entry in ipairs(optionsList) do
                if entry.subcategory then
                    local categoryDescription = rootDescription:CreateButton(entry.text)
                    for _, option in ipairs(entry.subcategory) do
                        Settings.CreateDropdownButton(
                            categoryDescription,
                            option,
                            function(data) return setting:GetValue() == data.value end,
                            function(data) setting:SetValue(data.value) end)
                    end
                end
            end
        end
    end

    return setting
end

local function BuildNativeSettingsPanel()
    local L = addon.L

    category = Settings.RegisterVerticalLayoutCategory(L.OPTIONS_TITLE)

    local languageOptions = {}
    for _, entry in ipairs(addon.AvailableLocales) do
        table.insert(languageOptions, { value = entry.code, text = entry.name })
    end

    AddDropdown(category, "SBT_Language", L.LANGUAGE_LABEL, "auto",
        function() return SelfBuffTrackerDB.locale or "auto" end,
        function(value)
            SelfBuffTrackerDB.locale = value
            addon.RefreshLocale()
            print("|cff00ff00[SBT]|r " .. addon.L.RELOAD_HINT)
        end,
        languageOptions)

    AddCheckbox(category, "SBT_SoundEnabled", L.SOUND_ENABLED, true,
        function() return SelfBuffTrackerDB.soundEnabled end,
        function(value) SelfBuffTrackerDB.soundEnabled = value end)

    AddCheckbox(category, "SBT_Locked", L.LOCKED_POSITION, false,
        function() return SelfBuffTrackerDB.isLocked end,
        function(value)
            SelfBuffTrackerDB.isLocked = value
            addon.CheckBuffs(false)
        end)
    AddCheckbox(category, "SBT_AllowFlasks", L.ALLOW_FLASKS or "Enable Flask Tracking", false,
        function() return SelfBuffTrackerDB.isFlasksAllowed end,
        function(value)
            SelfBuffTrackerDB.isFlasksAllowed = value
            if addon.CheckBuffs then addon.CheckBuffs(false) end
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

    AddSlider(category, "SBT_ReminderInterval", L.REMINDER_INTERVAL, 1, 180, 1, 15,
        function() return SelfBuffTrackerDB.soundReminderInterval end,
        function(value) SelfBuffTrackerDB.soundReminderInterval = value end)

    local soundOptions = {}
    for _, soundCategory in ipairs(addon.SoundCategories) do
        local subcategory = {}
        for _, preset in ipairs(addon.SoundPresets[soundCategory.value] or {}) do
            table.insert(subcategory, {
                value = preset.kit,
                label = preset.label,
                text = preset.label,
            })
        end
        table.insert(soundOptions, {
            text = L[soundCategory.labelKey],
            subcategory = subcategory,
        })
    end

    AddDropdown(category, "SBT_SoundKit", L.SOUND_LABEL, "RAID_WARNING",
        function() return SelfBuffTrackerDB.soundKit end,
        function(value)
            SelfBuffTrackerDB.soundKit = value
            local kitID = addon.SOUNDKIT[value]
            if kitID then PlaySound(kitID, "Master") end
        end,
        soundOptions)

    AddCheckbox(category, "SBT_Debug", L.DEBUG_ENABLED, true,
        function() return SelfBuffTrackerDB.isDebug end,
        function(value) SelfBuffTrackerDB.isDebug = value end)

    Settings.RegisterAddOnCategory(category)

    addon.CreateTrackedBuffsSubcategory(category)
    addon.CreateTrackedFlasksSubcategory(category)

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
