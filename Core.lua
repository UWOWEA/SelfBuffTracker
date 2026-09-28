local addonName, addon = ...
local frame = CreateFrame("Frame", "SelfBuffTrackerFrame", UIParent)
local L = addon.L

addon.defaultConfig = {
    trackedSpells = {},
    trackedFlasks = {},
    iconSize = 50,
    spacing = 10,
    columns = 3,
    soundEnabled = true,
    soundFile = 567400,
    soundKit = "RAID_WARNING",
    soundReminderInterval = 10,
    locale = "auto",
    anchorPosition = { "CENTER", nil, "CENTER", 0, 150 },
    isLocked = true,
    isFlasksAllowed = false,
    isDebug = false,
    advancedEnabled = false,
}
local defaultConfig = addon.defaultConfig

addon.activeBuffTimers = addon.activeBuffTimers or {}

local events = {
 { name = "ADDON_LOADED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ENTERING_WORLD", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "UNIT_AURA", ignoreTime = false, needPlayer = true, muteSound = false, },
 { name = "PLAYER_REGEN_DISABLED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_REGEN_ENABLED", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ALIVE", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_UNGHOST", ignoreTime = false, needPlayer = false, muteSound = false, },
 { name = "PLAYER_ENTER_COMBAT", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_LEAVE_COMBAT", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_IN_COMBAT_CHANGED", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_CONTROL_GAINED", ignoreTime = true, needPlayer = false, muteSound = false, },
 { name = "PLAYER_LOGOUT", ignoreTime = false, needPlayer = false, muteSound = true, },
 { name = "UNIT_SPELLCAST_SUCCEEDED", ignoreTime = true, needPlayer = true, muteSound = true, },
}

for _, event in ipairs(events) do
    frame:RegisterEvent(event.name)
end

local iconPool = {}

local function CreateBuffIcon()
    local btn = CreateFrame("Button", nil, addon.container, "BackdropTemplate")
    btn:SetSize(SelfBuffTrackerDB.iconSize, SelfBuffTrackerDB.iconSize)

    btn:SetFrameLevel(addon.container:GetFrameLevel() + 1)
    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    btn.texture = tex

    btn:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    btn:SetBackdropBorderColor(1, 0, 0, 1)

    return btn
end

local function GetSpellTexture(spellName)
    local spellInfo = addon.GetSpellInfo(spellName)
    if spellInfo and spellInfo.iconID then
        return spellInfo.iconID
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local previouslyMissing = {}

addon.LockContainer = function ()
    SelfBuffTrackerDB.isLocked = true
    addon.container:SetBackdropColor(0, 0, 0, 0)
    addon.container:SetBackdropBorderColor(0, 0, 0, 0)
    addon.containerTitle:Hide()
end

addon.UnLockContainer = function ()
    SelfBuffTrackerDB.isLocked = false
    addon.container:SetBackdropColor(0, 0, 0, 0.6)
    addon.container:SetBackdropBorderColor(1, 1, 1, 1)
    addon.containerTitle:Show()
end

local function CheckBuffs(isTimeIgnored, muteSound)
    if not muteSound then
        muteSound = false
    end

    if not SelfBuffTrackerDB then return end

    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
        addon.container:Hide()
        addon.containerTitle:Hide()
        return
    end

    local missingSpells = addon.getMissingSpells()

    if SelfBuffTrackerDB.isDebug then
        print("[Debug] missing spells amount:", missingSpells)
    end

    for _, icon in ipairs(iconPool) do
        icon:Hide()
    end

    local numMissing = #missingSpells

    if SelfBuffTrackerDB.isDebug then
        print("[Debug] missing spells amount:", numMissing)
    end
    if numMissing > 0 then
        addon.container:Show()

        local iconSize = SelfBuffTrackerDB.iconSize
        local spacing = SelfBuffTrackerDB.spacing
        local cols = SelfBuffTrackerDB.columns or 3
        if cols <= 0 then cols = numMissing end
        local numRows = math.ceil(numMissing / cols)
        local numCols = math.min(numMissing, cols)

        local totalWidth = (numCols * iconSize) + ((numCols - 1) * spacing)
        local totalHeight = (numRows * iconSize) + ((numRows - 1) * spacing)

        addon.container:SetSize(math.max(totalWidth, 100), totalHeight + 10)

        for i, spellName in ipairs(missingSpells) do
            if not iconPool[i] then
                iconPool[i] = CreateBuffIcon()
            end

            local icon = iconPool[i]
            icon:SetSize(iconSize, iconSize)
            icon.texture:SetTexture(GetSpellTexture(spellName))
            icon:ClearAllPoints()

            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)

            local xOffset = col * (iconSize + spacing)
            local yOffset = -row * (iconSize + spacing)

            icon:SetPoint("TOPLEFT", addon.container, "TOPLEFT", xOffset, yOffset)
            icon:Show()
        end

        if addon.isEditMode() then
            addon.ApplyEditModeStyle()
            return
        end
        previouslyMissing = {}
        local missingCount = 0
        for _, spellName in ipairs(missingSpells) do
            previouslyMissing[spellName] = true
            missingCount = missingCount + 1
        end

        missingCount = missingCount + numMissing
        if not muteSound and (numMissing > 0 or missingCount > 0) then
            addon.PlaySoundAlert(missingSpells, previouslyMissing, isTimeIgnored)
        end
    else
        previouslyMissing = {}
        if not SelfBuffTrackerDB.isLocked then
            addon.container:Show()
            addon.container:SetBackdropColor(0, 0, 0, 0.6)
            addon.container:SetBackdropBorderColor(1, 1, 1, 1)
            addon.containerTitle:Show()
            addon.container:SetSize(120, SelfBuffTrackerDB.iconSize + 10)
        else
            addon.container:Hide()
            addon.containerTitle:Hide()
        end
    end
end
addon.CheckBuffs = CheckBuffs

C_Timer.NewTicker(1.0, function()
    if SelfBuffTrackerDB and SelfBuffTrackerDB.isDebug then
        print("|cffffff00[Debug] [Timer]: running CheckBuffs")
    end

    if addon.CheckBuffs then
        addon.CheckBuffs(false)
    end
end)

local function clearCache()
    addon.activeBuffTimers = {}
end

frame:SetScript("OnEvent", function(self, event, unit, lineID, spellID)
    if event == "ADDON_LOADED" and unit == addonName then
        if not SelfBuffTrackerDB then
            SelfBuffTrackerDB = CopyTable(defaultConfig)
        else
            for k, v in pairs(defaultConfig) do
                if SelfBuffTrackerDB[k] == nil then
                    SelfBuffTrackerDB[k] = v
                end
            end
        end

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
                addon.UpdateAuraCache()
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
        end
        for _, checkEvent in ipairs(events) do
            if event == checkEvent.name then
                if not checkEvent.needPlayer or (checkEvent.needPlayer and unit == "player") then
                    CheckBuffs(checkEvent.ignoreTime, checkEvent.muteSound)
                end
            end
        end
    end
end)
