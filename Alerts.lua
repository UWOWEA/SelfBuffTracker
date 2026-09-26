local addonName, addon = ...

local lastSoundTime = 0

local function PlaySoundAlert(missingSpells, previouslyMissing)
    if SelfBuffTrackerDB.soundEnabled then
        local now = GetTime()
        local hasNewlyMissing = false
        for _, spellName in ipairs(missingSpells) do
            if not previouslyMissing[spellName] then
                hasNewlyMissing = true
                break
            end
        end

        if hasNewlyMissing or (now - lastSoundTime) > SelfBuffTrackerDB.soundReminderInterval then
            addon.PlayWarningSound()
            lastSoundTime = now
        end
    end
end

addon.PlaySoundAlert = PlaySoundAlert