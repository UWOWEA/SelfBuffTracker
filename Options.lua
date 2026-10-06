local addonName, addon = ...
local UI = _G["UI"]

local category

local function BuildNativeSettingsPanel()
    local L = addon.L

    category = Settings.RegisterVerticalLayoutCategory(L.OPTIONS_TITLE)

    local languageOptions = {}
    for _, entry in ipairs(addon.AvailableLocales) do
        table.insert(languageOptions, { value = entry.code, text = entry.name })
    end

    UI.Widgets.Settings:CreateDropdown(category, "SBT_Language", L.LANGUAGE_LABEL, "auto",
        function() return SelfBuffTrackerDB.locale or "auto" end,
        function(value)
            SelfBuffTrackerDB.locale = value
            addon.RefreshLocale()
            print("|cff00ff00[SBT]|r " .. addon.L.RELOAD_HINT)
        end,
        languageOptions)

    UI.Widgets.Settings:CreateCheckbox(category, "SBT_SoundEnabled", L.SOUND_ENABLED, true,
        function() return SelfBuffTrackerDB.soundEnabled end,
        function(value) SelfBuffTrackerDB.soundEnabled = value end)

    UI.Widgets.Settings:CreateCheckbox(category, "SBT_Locked", L.LOCKED_POSITION, false,
        function() return SelfBuffTrackerDB.isLocked end,
        function(value)
            SelfBuffTrackerDB.isLocked = value
            addon.CheckBuffs(false)
        end)
    UI.Widgets.Settings:CreateCheckbox(category, "SBT_AllowFlasks", L.ALLOW_FLASKS or "Enable Flask Tracking", false,
        function() return SelfBuffTrackerDB.isFlasksAllowed end,
        function(value)
            SelfBuffTrackerDB.isFlasksAllowed = value
            if addon.CheckBuffs then addon.CheckBuffs(false) end
        end)
    UI.Widgets.Settings:CreateSlider(category, "SBT_IconSize", L.ICON_SIZE, 20, 100, 1, 50,
        function() return SelfBuffTrackerDB.iconSize end,
        function(value)
            SelfBuffTrackerDB.iconSize = value
            addon.CheckBuffs(false)
        end)

    UI.Widgets.Settings:CreateSlider(category, "SBT_Spacing", L.ICON_SPACING, 0, 30, 1, 10,
        function() return SelfBuffTrackerDB.spacing end,
        function(value)
            SelfBuffTrackerDB.spacing = value
            addon.CheckBuffs(false)
        end)

    UI.Widgets.Settings:CreateSlider(category, "SBT_ReminderInterval", L.REMINDER_INTERVAL, 1, 180, 1, 15,
        function() return SelfBuffTrackerDB.soundReminderInterval end,
        function(value) SelfBuffTrackerDB.soundReminderInterval = value end)

    local soundOptions = {}
    for _, soundCategory in ipairs(addon.SoundCategories) do
        local subcategory = {}
        for _, preset in ipairs(addon.SoundPresets[soundCategory.value] or {}) do
            table.insert(subcategory, {
                value = preset.kit or preset.file,
                label = preset.label,
                text = preset.label,
            })
        end
        if #subcategory > 0 then
            table.insert(soundOptions, {
                text = L[soundCategory.labelKey],
                subcategory = subcategory,
            })
        end
    end

    UI.Widgets.Settings:CreateDropdown(category, "SBT_SoundKit", L.SOUND_LABEL, "RAID_WARNING",
        function() return SelfBuffTrackerDB.soundKit or SelfBuffTrackerDB.soundFile end,
        function(value)
            for _, presets in pairs(addon.SoundPresets) do
                for _, preset in ipairs(presets) do
                    if (preset.kit or preset.file) == value then
                        if not addon.SelectSoundPreset(preset) and preset.file then
                            print("|cffff0000[SBT]|r " .. string.format(L.CMD_SOUND_FILE_NOT_FOUND, preset.file))
                        end
                        return
                    end
                end
            end
        end,
        soundOptions)

    UI.Widgets.Settings:CreateCheckbox(category, "SBT_Debug", L.DEBUG_ENABLED, true,
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
