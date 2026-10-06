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

    AddDropdown(category, "SBT_SoundKit", L.SOUND_LABEL, "RAID_WARNING",
        function() return SelfBuffTrackerDB.soundKit end,
        function(value)
            SelfBuffTrackerDB.soundKit = value
            local kitID = addon.SOUNDKIT[value]
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

