local addonName, addon = ...

local PROFILE_FIELDS = { "trackedSpells", "iconSize", "spacing", "soundEnabled", "soundFile", "soundKit", "soundReminderInterval" }

local function GetCharacterKey()
    return GetRealmName() .. "-" .. UnitName("player")
end

function addon.SaveCharacterSnapshot()
    if not SelfBuffTrackerDB then return end

    SelfBuffTrackerAccountDB = SelfBuffTrackerAccountDB or {}

    local _, class = UnitClass("player")
    local snapshot = { class = class, name = UnitName("player"), realm = GetRealmName() }

    for _, field in ipairs(PROFILE_FIELDS) do
        local value = SelfBuffTrackerDB[field]
        snapshot[field] = type(value) == "table" and CopyTable(value) or value
    end

    SelfBuffTrackerAccountDB[GetCharacterKey()] = snapshot
end

function addon.GetOtherClassProfiles()
    local results = {}
    if not SelfBuffTrackerAccountDB then return results end

    local _, myClass = UnitClass("player")
    local myKey = GetCharacterKey()

    for key, profile in pairs(SelfBuffTrackerAccountDB) do
        if key ~= myKey and profile.class == myClass then
            table.insert(results, { key = key, name = profile.name, realm = profile.realm })
        end
    end

    table.sort(results, function(a, b) return a.name < b.name end)
    return results
end

function addon.CopyProfileFrom(key)
    if not (SelfBuffTrackerAccountDB and SelfBuffTrackerAccountDB[key]) then return false end

    local profile = SelfBuffTrackerAccountDB[key]
    for _, field in ipairs(PROFILE_FIELDS) do
        local value = profile[field]
        if value ~= nil then
            SelfBuffTrackerDB[field] = type(value) == "table" and CopyTable(value) or value
        end
    end

    addon.CheckBuffs()
    if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
    return true
end
