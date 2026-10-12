local addonName, addon = ...
local Core = _G["Core"]

local PROFILE_FIELDS = {
    "trackedSpells",
    "trackedFlasks",
    "iconSize",
    "spacing",
    "soundEnabled",
    "soundFile",
    "soundKit",
    "soundReminderInterval",
    "locale",
    "anchorPosition",
    "isFlasksAllowed",
    "advancedEnabled",
    "rows",
    "columns",
    "advancedEnabled"
}

local function GetCharacterKey()
    return GetRealmName() .. "-" .. Core.Unit.Player:Name()
end

function addon.SaveCharacterSnapshot()
    if not SelfBuffTrackerDB then return end

    SelfBuffTrackerAccountDB = SelfBuffTrackerAccountDB or {}

    local player = Core.Unit.Player
    local _, class = player:Class()
    local snapshot = { class = class, name = player:Name(), realm = GetRealmName() }

    for _, field in ipairs(PROFILE_FIELDS) do
        local value = SelfBuffTrackerDB[field]
        snapshot[field] = type(value) == "table" and CopyTable(value) or value
    end

    SelfBuffTrackerAccountDB[GetCharacterKey()] = snapshot
end

function addon.GetOtherClassProfiles()
    local results = {}
    if not SelfBuffTrackerAccountDB then return results end

    local _, myClass = Core.Unit.Player:Class()
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

    addon.CheckBuffs(false)
    if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
    return true
end
