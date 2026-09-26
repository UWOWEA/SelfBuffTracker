local addonName, addon = ...

local function GetAllPlayerAuras()
    local auras = {}
    local aurasBySpellID = {}
    local aurasByName = {}
    local inCombat = InCombatLockdown()

    if not inCombat and C_UnitAuras and C_UnitAuras.GetUnitAuras then
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
            return auras, aurasByName, aurasBySpellID
        end
    end

    if C_UnitAuras and C_UnitAuras.GetAuraSlots then
        local okSlots, slots = pcall(C_UnitAuras.GetAuraSlots, "player", "HELPFUL")
        if okSlots and type(slots) == "table" then
            for _, slot in ipairs(slots) do
                local okAura, aura = pcall(C_UnitAuras.GetAuraDataBySlot, "player", slot)
                if okAura and aura then
                    table.insert(auras, aura)
                    if aura.name then
                        local okName, nameLower = pcall(string.lower, aura.name)
                        if okName and nameLower then aurasByName[nameLower] = true end
                    end
                    if aura.spellId then aurasBySpellID[aura.spellId] = true end
                end
            end
        end
    end

    return auras, aurasByName, aurasBySpellID
end

addon.GetAllPlayerAuras = GetAllPlayerAuras