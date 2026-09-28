local addonName, addon = ...

local spellcache = setmetatable({}, {__index=function(t,v) local a = {C_Spell.GetSpellInfo(v)} if C_Spell.GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
	return unpack(spellcache[a])
end

addon.GetSpellInfo = GetSpellInfo
