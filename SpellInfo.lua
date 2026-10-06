local addonName, addon = ...

local spellcache = setmetatable({}, {__index=function(t,v) local a = {C_Spell.GetSpellInfo(v)} if C_Spell.GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
	return unpack(spellcache[a])
end

addon.GetSpellInfo = GetSpellInfo

addon.GetSpellOverrides = function(spellID)
	local overrides = {}
	local seen = {}
	local auraOverride
	if spellID then
		auraOverride = addon.Database.SpellAuraOverrides
			and addon.Database.SpellAuraOverrides[spellID]
	end

	if auraOverride then
		table.insert(overrides, auraOverride)
		seen[auraOverride] = true
	end

	if spellID and C_Spell and C_Spell.GetOverrideSpell then
		local ok, overrideID = pcall(C_Spell.GetOverrideSpell, spellID)
		if ok and overrideID and overrideID > 0 and overrideID ~= spellID and not seen[overrideID] then
			table.insert(overrides, overrideID)
		end
	end

	return overrides
end

addon.GetBaseSpell = function(spellID)
	if not spellID then return end

	for baseSpellID, auraSpellID in pairs(addon.Database.SpellAuraOverrides or {}) do
		if auraSpellID == spellID then
			return baseSpellID
		end
	end

	if C_Spell and C_Spell.GetBaseSpell then
		local ok, baseSpellID = pcall(C_Spell.GetBaseSpell, spellID)
		if ok and baseSpellID and baseSpellID > 0 and baseSpellID ~= spellID then
			return baseSpellID
		end
	end
end
