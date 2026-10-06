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
    { label = "Bell", id = 316773, kit = "CDMSND_WAR3_BELL", key = "CDMSND_WAR3_BELL" }, -- Bell
    { label = "Crunchy Bell", id = 316774, kit = "CDMSND_WAR3_CRUNCHY_BELL" }, -- Crunchy Bell
    { label = "Drum Splash", id = 316768, kit = "CDMSND_WAR3_DRUM_SPLASH" }, -- Drum Splash
    { label = "Error", id = 316775, kit = "CDMSND_WAR3_ERROR" }, -- Error
    { label = "Fanfare", id = 316769, kit = "CDMSND_WAR3_FANFARE" }, -- Fanfare
    { label = "Gate Open", id = 316776, kit = "CDMSND_WAR3_GATE_OPEN" }, -- Gate Open
    { label = "Gold", id = 316770, kit = "CDMSND_WAR3_GOLD" }, -- Gold
    { label = "Magic Shimmer", id = 316778, kit = "CDMSND_WAR3_MAGIC_SHIMMER" }, -- Magic Shimmer
    { label = "Ringout", id = 316771, kit = "CDMSND_WAR3_RINGOUT" }, -- Ringout
    { label = "Rooster", id = 316765, kit = "CDMSND_WAR3_ROOSTER" }, -- Rooster
    { label = "Shimmer Bell", id = 316779, kit = "CDMSND_WAR3_SHIMMER_BELL" }, -- Shimmer Bell
    { label = "Wolf Howl", id = 316766, kit = "CDMSND_WAR3_WOLF_HOWL" }, -- Wolf Howl
    { label = "Abstract Whoosh", id = 316731, kit = "CDMSND_WAR2_ABSTRACT_WHOOSH" }, -- Abstract Whoosh
    { label = "Choir", id = 316733, kit = "CDMSND_WAR2_CHOIR" }, -- Choir
    { label = "Construction", id = 316735, kit = "CDMSND_WAR2_CONSTRUCTION" }, -- Construction
    { label = "Magic Chimes", id = 316736, kit = "CDMSND_WAR2_MAGIC_CHIMES" }, -- Magic Chimes
    { label = "Pig Squeal", id = 316745, kit = "CDMSND_WAR2_PIG_SQUEAL" }, -- Pig Squeal
    { label = "Saws", id = 316738, kit = "CDMSND_WAR2_SAWS" }, -- Saws
    { label = "Seal", id = 316746, kit = "CDMSND_WAR2_SEAL" }, -- Seal
    { label = "Slow", id = 316748, kit = "CDMSND_WAR2_SLOW" }, -- Slow
    { label = "Smith", id = 316749, kit = "CDMSND_WAR2_SMITH" }, -- Smith
    { label = "Synth Stinger", id = 316739, kit = "CDMSND_WAR2_SYNTH_STINGER" }, -- Synth Stinger
    { label = "Trumpet Rally", id = 316740, kit = "CDMSND_WAR2_TRUMPET_RALLY" }, -- Trumpet Rally
    { label = "Zippy Magic", id = 316737, kit = "CDMSND_WAR2_ZIPPY_MAGIC" }, -- Zippy Magic
}

for i = #addon.SoundPresets, 1, -1 do
    if not type(addon.SoundPresets[i].kit) =="number" then
        if not addon.SOUNDKIT[addon.SoundPresets[i].kit] then
            table.remove(addon.SoundPresets, i)
        end
    end
end

function addon.PlayWarningSound()
    local db = SelfBuffTrackerDB
    local kitID = db.soundKit and addon.SOUNDKIT[db.soundKit]

    if kitID then
        PlaySound(kitID, "Master")
    else
        PlaySoundFile(db.soundFile, "Master")
    end
end
