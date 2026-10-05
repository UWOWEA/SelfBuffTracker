local addonName, addon = ...

addon.auraIDCache = addon.auraIDCache or {}

-- duration == 0 means the aura has no expiration
-- Values can be secret in combat; those are stored as 0 (unknown / no expiration)
addon.MakeAuraCacheEntry = function(aura, fallbackSpellId)
    local function plain(value)
        if issecretvalue and issecretvalue(value) then return nil end
        return value
    end
    return {
        spellId = plain(aura.spellId) or fallbackSpellId,
        duration = plain(aura.duration) or 0,
        expirationTime = plain(aura.expirationTime) or 0,
    }
end

-- Returns remaining seconds, 0 when expired, or nil when unknown/permanent
addon.GetCachedAuraRemaining = function(key)
    local entry = addon.auraIDCache[key]
    if not entry or not entry.expirationTime or entry.expirationTime == 0 then
        return nil
    end
    return math.max(0, entry.expirationTime - GetTime())
end

local function ScanAurasByFilter(filter)
    if not (C_UnitAuras and C_UnitAuras.GetUnitAuras) then return end

    if C_UnitAuras and C_UnitAuras.GetUnitAuras then
        local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
        if ok and type(auras) == "table" then
            for _, aura in ipairs(auras) do
                if aura.name and aura.spellId then
                    local lowerName = aura.name:lower()
                    local entry = addon.MakeAuraCacheEntry(aura)
                    addon.auraIDCache[lowerName] = entry
                    if addon.GetSpellInfo then
                        local info = addon.GetSpellInfo(aura.name)
                        if info and info.spellID then
                            addon.auraIDCache[tostring(info.spellID)] = entry
                        end
                    end
                end
            end
        end
    end
end

-- force: take a snapshot on combat entry, when the lockdown flag may already be set
local function UpdateAuraCache(force)
    if InCombatLockdown() and not force then return end
    ScanAurasByFilter("HELPFUL")

    if SelfBuffTrackerDB and SelfBuffTrackerDB.isFlasksAllowed then
        ScanAurasByFilter("HELPFUL|CANCELABLE")
    end
end

addon.UpdateAuraCache = UpdateAuraCache

-- Combat-safe: asks for tracked spells directly, as UNIT_AURA payloads are secret in combat
addon.RefreshTrackedAurasInCombat = function()
    if not (SelfBuffTrackerDB and C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return end

    local function refresh(tracked)
        for key, enabled in pairs(tracked or {}) do
            local spellID = tonumber(key)
            if enabled and spellID then
                local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
                if ok and aura then
                    local entry = addon.MakeAuraCacheEntry(aura, spellID)
                    addon.auraIDCache[tostring(spellID)] = entry
                    local info = addon.GetSpellInfo and addon.GetSpellInfo(spellID)
                    if info and info.name then
                        addon.auraIDCache[info.name:lower()] = entry
                    end
                end
            end
        end
    end

    refresh(SelfBuffTrackerDB.trackedSpells)
    if SelfBuffTrackerDB.isFlasksAllowed then
        refresh(SelfBuffTrackerDB.trackedFlasks)
    end
end

local function GetAllPlayerAuras()
    local auras = {}
    local aurasBySpellID = {}
    local aurasByName = {}

    if InCombatLockdown() then
        return auras, aurasByName, aurasBySpellID
    end

    local filters = { "HELPFUL" }
    if SelfBuffTrackerDB and SelfBuffTrackerDB.isFlasksAllowed then
        table.insert(filters, "HELPFUL|CANCELABLE")
    end

    for _, filter in ipairs(filters) do
        if C_UnitAuras and C_UnitAuras.GetUnitAuras then
            local ok, rawAuras = pcall(C_UnitAuras.GetUnitAuras, "player", filter)
            if ok and type(rawAuras) == "table" then
                for _, aura in ipairs(rawAuras) do
                    table.insert(auras, aura)
                    if aura.name then
                        aurasByName[aura.name:lower()] = true
                    end
                    if aura.spellId then
                        aurasBySpellID[aura.spellId] = true
                    end
                end
            end
        end
    end

    return auras, aurasByName, aurasBySpellID
end

addon.GetAllPlayerAuras = GetAllPlayerAuras
