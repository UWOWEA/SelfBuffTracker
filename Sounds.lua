local addonName, addon = ...

addon.SoundPresets = {
    { key = "raidwarning", label = "Raid Warning", kit = "RAID_WARNING" },
    { key = "readycheck", label = "Ready Check", kit = "READY_CHECK" },
    { key = "readycheckfail", label = "Ready Check Fail", kit = "READY_CHECK_FAIL" },
    { key = "raidboss", label = "Raid Boss Warning", kit = "RAID_BOSS_EMOTE_WARNING" },
    { key = "alarmclock", label = "Alarm Clock", kit = "ALARM_CLOCK_WARNING_1" },
    { key = "alarmclockwarning2", label = "Alarm Clock 2", kit = "ALARM_CLOCK_WARNING_2" },
    { key = "alarmclockwarning3", label = "Alarm Clock 3", kit = "ALARM_CLOCK_WARNING_3" },
    { key = "worldquestadded", label = "Quest Added", kit = "UI_WORLDQUEST_START" },
    { key = "QUEST_SESSION_ACTIVATE", label = "Quest Session Activate", kit = "QUEST_SESSION_ACTIVATE" },
}

for i = #addon.SoundPresets, 1, -1 do
    if not SOUNDKIT[addon.SoundPresets[i].kit] then
        table.remove(addon.SoundPresets, i)
    end
end

function addon.PlayWarningSound()
    local db = SelfBuffTrackerDB
    local kitID = db.soundKit and SOUNDKIT[db.soundKit]
    if kitID then
        PlaySound(kitID, "Master")
    else
        PlaySoundFile(db.soundFile, "Master")
    end
end
