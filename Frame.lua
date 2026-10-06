local addonName, addon = ...
local frame = CreateFrame("Frame", "SelfBuffTrackerFrame", UIParent)

for _, event in ipairs(addon.events) do
    frame:RegisterEvent(event.name)
end

frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

local function clearCache()
    addon.activeBuffTimers = {}
end

frame:SetScript("OnEvent", function(self, event, unit, lineID, spellID)
    if event == "ADDON_LOADED" and unit == addonName then
        addon.InitConfig()

        addon.MigrateTrackedSpellsToIDs()

        addon.container:ClearAllPoints()
        if SelfBuffTrackerDB.anchorPosition and #SelfBuffTrackerDB.anchorPosition == 5 then
            addon.container:SetPoint(unpack(SelfBuffTrackerDB.anchorPosition))
        else
            addon.container:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        end
        self:UnregisterEvent("ADDON_LOADED")

        if addon.RefreshLocale then
            addon.RefreshLocale()
        end

        if addon.SaveCharacterSnapshot then
            addon.SaveCharacterSnapshot()
        end

        if addon.InitOptionsPanel then
            addon.InitOptionsPanel()
        end
    elseif event == "PLAYER_LOGOUT" then
        if addon.SaveCharacterSnapshot then
            addon.SaveCharacterSnapshot()
        end
    else
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
            if spellID then
                local expTime = GetTime() + 30
                addon.activeBuffTimers[tostring(spellID)] = expTime

                if addon.GetSpellInfo then
                    local info = addon.GetSpellInfo(spellID)
                    if info and info.name then
                        addon.activeBuffTimers[info.name:lower()] = expTime
                    end
                end
            end
        end
        if event == "PLAYER_REGEN_DISABLED" then
            if addon.UpdateAuraCache then
                addon.UpdateAuraCache(true)
            end
            if not InCombatLockdown() then
                addon.container:Show()
            end
        end
        if event == "PLAYER_ENTER_COMBAT" then
            if not InCombatLockdown() then
                addon.container:Show()
            end
        end
        if event == "PLAYER_REGEN_ENABLED" then
            local now = GetTime()
            for k, expTime in pairs(addon.activeBuffTimers) do
                if now > expTime then
                    addon.activeBuffTimers[k] = nil
                end
            end
            addon.UpdateAuraCache()
            clearCache()
        end
        if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" then
            addon.UpdateAuraCache()
            if event == "UNIT_AURA" and unit == "player" and InCombatLockdown() then
                addon.RefreshTrackedAurasInCombat()
            end
        end
        for _, checkEvent in ipairs(addon.events) do
            if event == checkEvent.name then
                if not checkEvent.needPlayer or (checkEvent.needPlayer and unit == "player") then
                    addon.CheckBuffs(checkEvent.ignoreTime, checkEvent.muteSound)
                end
            end
        end
    end
end)


addon.frame = frame
