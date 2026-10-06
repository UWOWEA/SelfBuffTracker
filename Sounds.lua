local addonName, addon = ...

addon.SoundCategories = {
    { value = "alerts", labelKey = "SOUND_CATEGORY_ALERTS" },
    { value = "warcraft3", labelKey = "SOUND_CATEGORY_WARCRAFT3" },
    { value = "warcraft2", labelKey = "SOUND_CATEGORY_WARCRAFT2" },
    { value = "animals", labelKey = "SOUND_CATEGORY_ANIMALS" },
    { value = "devices", labelKey = "SOUND_CATEGORY_DEVICES" },
    { value = "impacts", labelKey = "SOUND_CATEGORY_IMPACTS" },
    { value = "shorts", labelKey = "SOUND_CATEGORY_SHORTS" },
}

addon.SoundPresets = {
    alerts = {
        { key = "raidwarning", label = "Raid Warning", kit = "RAID_WARNING" },
        { key = "readycheck", label = "Ready Check", kit = "READY_CHECK" },
        { key = "readycheckfail", label = "Ready Check Fail", kit = "READY_CHECK_FAIL" },
        { key = "raidboss", label = "Raid Boss Warning", kit = "RAID_BOSS_EMOTE_WARNING" },
        { key = "alarmclock", label = "Alarm Clock", kit = "ALARM_CLOCK_WARNING_1" },
        { key = "alarmclockwarning2", label = "Alarm Clock 2", kit = "ALARM_CLOCK_WARNING_2" },
        { key = "alarmclockwarning3", label = "Alarm Clock 3", kit = "ALARM_CLOCK_WARNING_3" },
        { key = "worldquestadded", label = "Quest Added", kit = "UI_WORLDQUEST_START" },
        { key = "QUEST_SESSION_ACTIVATE", label = "Quest Session Activate", kit = "QUEST_SESSION_ACTIVATE" },
    },
    warcraft3 = {
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
    },
    warcraft2 = {
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
    },
    animals = {
        { key = "cat", label = "Cat", kit = "CDMSND_ANIMALS_CAT" },
        { key = "chicken", label = "Chicken", kit = "CDMSND_ANIMALS_CHICKEN" },
        { key = "cow", label = "Cow", kit = "CDMSND_ANIMALS_COW" },
        { key = "gnoll", label = "Gnoll", kit = "CDMSND_ANIMALS_GNOLL" },
        { key = "goat", label = "Goat", kit = "CDMSND_ANIMALS_GOAT" },
        { key = "lion", label = "Lion", kit = "CDMSND_ANIMALS_LION" },
        { key = "panther", label = "Panther", kit = "CDMSND_ANIMALS_PANTHER" },
        { key = "rattlesnake", label = "Rattlesnake", kit = "CDMSND_ANIMALS_RATTLESNAKE" },
        { key = "sheep", label = "Sheep", kit = "CDMSND_ANIMALS_SHEEP" },
        { key = "wolf", label = "Wolf", kit = "CDMSND_ANIMALS_WOLF" },
    },
    devices = {
        { key = "boat_horn", label = "Boat Horn", kit = "CDMSND_DEVICES_BOAT_HORN" },
        { key = "air_horn", label = "Air Horn", kit = "CDMSND_DEVICES_AIR_HORN" },
        { key = "bike_horn", label = "Bike Horn", kit = "CDMSND_DEVICES_BIKE_HORN" },
        { key = "cash_register", label = "Cash Register", kit = "CDMSND_DEVICES_CASH_REGISTER" },
        { key = "jackpot_bell", label = "Jackpot Bell", kit = "CDMSND_DEVICES_JACKPOT_BELL" },
        { key = "jackpot_coins", label = "Jackpot Coins", kit = "CDMSND_DEVICES_JACKPOT_COINS" },
        { key = "jackpot_fail", label = "Jackpot Fail", kit = "CDMSND_DEVICES_JACKPOT_FAIL" },
        { key = "rotary_phone_dial", label = "Rotary Phone Dial", kit = "CDMSND_DEVICES_ROTARY_PHONE_DIAL" },
        { key = "rotary_phone_ring", label = "Rotary Phone Ring", kit = "CDMSND_DEVICES_ROTARY_PHONE_RING" },
        { key = "stove_pipe", label = "Stove Pipe", kit = "CDMSND_DEVICES_STOVE_PIPE" },
        { key = "trashcan_lid", label = "Trashcan Lid", kit = "CDMSND_DEVICES_TRASHCAN_LID" },
    },
    impacts = {
        { key = "anvil_strike", label = "Anvil Strike", kit = "CDMSND_IMPACTS_ANVIL_STRIKE" },
        { key = "bubble_smash", label = "Bubble Smash", kit = "CDMSND_IMPACTS_BUBBLE_SMASH" },
        { key = "low_thud", label = "Low Thud", kit = "CDMSND_IMPACTS_LOW_THUD" },
        { key = "metal_clanks", label = "Metal Clanks", kit = "CDMSND_IMPACTS_METAL_CLANKS" },
        { key = "metal_rattle", label = "Metal Rattle", kit = "CDMSND_IMPACTS_METAL_RATTLE" },
        { key = "metal_scrape", label = "Metal Scrape", kit = "CDMSND_IMPACTS_METAL_SCRAPE" },
        { key = "metal_warble", label = "Metal Warble", kit = "CDMSND_IMPACTS_METAL_WARBLE" },
        { key = "pop_click", label = "Pop Click", kit = "CDMSND_IMPACTS_POP_CLICK" },
        { key = "strange_clang", label = "Strange Clang", kit = "CDMSND_IMPACTS_STRANGE_CLANG" },
        { key = "sword_scrape", label = "Sword Scrape", kit = "CDMSND_IMPACTS_SWORD_SCRAPE" },
    },
    shorts = {
        { key = "bell_strike", label = "Bell Strike", kit = "CDMSND_SHORT_BELL_STRIKE" },
        { key = "bell_tree", label = "Bell Tree", kit = "CDMSND_SHORT_BELL_TREE" },
        { key = "big_pot", label = "Big Pot", kit = "CDMSND_SHORT_BIG_POT" },
        { key = "blades", label = "Blades", kit = "CDMSND_SHORT_BLADES" },
        { key = "coffee_mug", label = "Coffee Mug", kit = "CDMSND_SHORT_COFFEE_MUG" },
        { key = "cow_bell", label = "Cow Bell", kit = "CDMSND_SHORT_COW_BELL" },
        { key = "finger_snap", label = "Finger Snap", kit = "CDMSND_SHORT_FINGER_SNAP" },
        { key = "guitar", label = "Guitar", kit = "CDMSND_SHORT_GUITAR" },
        { key = "kalimba", label = "Kalimba", kit = "CDMSND_SHORT_KALIMBA" },
        { key = "metal_blade_drop", label = "Metal Blade Drop", kit = "CDMSND_SHORT_METAL_BLADE_DROP" },
        { key = "metal_blade_on_rod", label = "Metal Blade on Rod", kit = "CDMSND_SHORT_METAL_BLADE_ON_ROD" },
        { key = "metal_impact", label = "Metal Impact", kit = "CDMSND_SHORT_METAL_IMPACT" },
        { key = "mini_wood_xylophone", label = "Mini Wood Xylophone", kit = "CDMSND_SHORT_MINI_WOOD_XYLOPHONE" },
        { key = "paper_cup", label = "Paper Cup", kit = "CDMSND_SHORT_PAPER_CUP" },
        { key = "sheet_metal", label = "Sheet Metal", kit = "CDMSND_SHORT_SHEET_METAL" },
        { key = "stove_pipe", label = "Stove Pipe", kit = "CDMSND_SHORT_STOVE_PIPE" },
        { key = "stove_pipe_blade", label = "Stove Pipe Blade", kit = "CDMSND_SHORT_STOVE_PIPE_BLADE" },
        { key = "sword_shing", label = "Sword Shing", kit = "CDMSND_SHORT_SWORD_SHING" },
        { key = "synth_bleep", label = "Synth Bleep", kit = "CDMSND_SHORT_SYNTH_BLEEP" },
        { key = "synth_blurp", label = "Synth Blurp", kit = "CDMSND_SHORT_SYNTH_BLURP" },
        { key = "synth_error", label = "Synth Error", kit = "CDMSND_SHORT_SYNTH_ERROR" },
        { key = "synth_high", label = "Synth High", kit = "CDMSND_SHORT_SYNTH_HIGH" },
        { key = "triangle", label = "Triangle", kit = "CDMSND_SHORT_TRIANGLE" },
        { key = "water_drop", label = "Water Drop", kit = "CDMSND_SHORT_WATER_DROP" },
        { key = "wine_bottle", label = "Wine Bottle", kit = "CDMSND_SHORT_WINE_BOTTLE" },
        { key = "wood_xylophone", label = "Wood Xylophone", kit = "CDMSND_SHORT_WOOD_XYLOPHONE" },
    },
}

for _, presets in pairs(addon.SoundPresets) do
    for i = #presets, 1, -1 do
        if not addon.SOUNDKIT[presets[i].kit] then
            table.remove(presets, i)
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
