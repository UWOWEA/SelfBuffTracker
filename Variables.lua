local addonName, addon = ...

addon.defaultConfig = {
    trackedSpells = {},
    trackedFlasks = {},
    iconSize = 50,
    spacing = 10,
    columns = 3,
    rows = 5,
    limitRows = false,
    soundEnabled = true,
    soundFile = 567400,
    soundKit = "RAID_WARNING",
    soundReminderInterval = 10,
    locale = "auto",
    anchorPosition = { "CENTER", nil, "CENTER", 0, 150 },
    isLocked = true,
    isFlasksAllowed = false,
    isDebug = false,
    advancedEnabled = false,
}

addon.activeBuffTimers = addon.activeBuffTimers or {}

local events = {
 { name = "ADDON_LOADED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ENTERING_WORLD", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "UNIT_AURA", ignoreTime = false, needPlayer = true, muteSound = false, },
 { name = "PLAYER_REGEN_DISABLED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_REGEN_ENABLED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ALIVE", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_UNGHOST", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ENTER_COMBAT", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_LEAVE_COMBAT", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_IN_COMBAT_CHANGED", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_CONTROL_GAINED", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_LOGOUT", ignoreTime = false, needPlayer = false, muteSound = true, },
 { name = "UNIT_SPELLCAST_SUCCEEDED", ignoreTime = true, needPlayer = true, muteSound = true, },
}

addon.events = events


addon.InitConfig = function ()
    if not SelfBuffTrackerDB then
        SelfBuffTrackerDB = CopyTable(addon.defaultConfig)
    else
        for k, v in pairs(addon.defaultConfig) do
            if SelfBuffTrackerDB[k] == nil then
                SelfBuffTrackerDB[k] = v
            end
        end
    end
end
