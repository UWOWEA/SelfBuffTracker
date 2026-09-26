local addonName, addon = ...

addon.auraIDCache = addon.auraIDCache or {}

local function UpdateAuraCache()
    if InCombatLockdown() then return end

    if C_UnitAuras and C_UnitAuras.GetUnitAuras then
        local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
        if ok and type(auras) == "table" then
            for _, aura in ipairs(auras) do
                if aura.name and aura.spellId then
                    local lowerName = aura.name:lower()
                    addon.auraIDCache[lowerName] = aura.spellId
                    if C_Spell and C_Spell.GetSpellInfo then
                        local info = C_Spell.GetSpellInfo(aura.name)
                        if info and info.spellID then
                            addon.auraIDCache[tostring(info.spellID)] = aura.spellId
                        end
                    end
                end
            end
        end
    end
end

addon.UpdateAuraCache = UpdateAuraCache

local function GetAllPlayerAuras()
    local auras = {}
    local aurasBySpellID = {}
    local aurasByName = {}

    if InCombatLockdown() then
        return auras, aurasByName, aurasBySpellID
    end

    if C_UnitAuras and C_UnitAuras.GetUnitAuras then
        local ok, rawAuras = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
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

    return auras, aurasByName, aurasBySpellID
end

addon.GetAllPlayerAuras = GetAllPlayerAuras