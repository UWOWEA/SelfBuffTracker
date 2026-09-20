local addonName, addon = ...
local frame = CreateFrame("Frame", "SelfBuffTrackerFrame", UIParent)

addon.defaultConfig = {
    trackedSpells = {
    },
    iconSize = 50,
    spacing = 10,
    soundEnabled = true,
    soundFile = 567400,
    soundKit = "RAID_WARNING",
    soundReminderInterval = 10,
    locale = "auto",
    anchorPosition = { "CENTER", nil, "CENTER", 0, 150 },
    isLocked = false,
}
local defaultConfig = addon.defaultConfig

local container = CreateFrame("Frame", "SelfBuffTrackerContainer", UIParent, "BackdropTemplate")
addon.container = container
container:SetSize(200, 60)
container:SetMovable(true)
container:EnableMouse(true)
container:RegisterForDrag("LeftButton")
container:SetClampedToScreen(true)

container:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
container:SetBackdropColor(0, 0, 0, 0.6)

container:SetScript("OnDragStart", function(self)
    if not SelfBuffTrackerDB.isLocked then
        self:StartMoving()
    end
end)

container:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    SelfBuffTrackerDB.anchorPosition = { point, nil, relPoint, x, y }
end)

local containerTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
containerTitle:SetPoint("BOTTOM", container, "TOP", 0, 4)
containerTitle:SetText(addon.L.MOVE_HINT)
addon.ApplyFont(containerTitle, "normalSmall")

local iconPool = {}

local function CreateBuffIcon()
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetSize(SelfBuffTrackerDB.iconSize, SelfBuffTrackerDB.iconSize)
    
    local tex = btn:CreateTexture(nil, "BACKGROUND")
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
    local spellInfo = C_Spell.GetSpellInfo(spellName)
    if spellInfo and spellInfo.iconID then
        return spellInfo.iconID
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local lastSoundTime = 0
local previouslyMissing = {}

local function CheckBuffs()
    if not SelfBuffTrackerDB then return end

    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
        container:Hide()
        return
    end

    local missingSpells = {}

    for spellInput, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled then
            local isPresent = false
            local targetName = spellInput:lower()
            local spellID = tonumber(spellInput)

            if spellID and C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                isPresent = true
            end

            if not isPresent and C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellInput)
                if info and info.spellID and C_UnitAuras.GetPlayerAuraBySpellID(info.spellID) then
                    isPresent = true
                end
            end

            if not isPresent then
                for i = 1, 255 do
                    local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
                    if not aura then break end
                    if aura.name and aura.name:lower() == targetName then
                        isPresent = true
                        break
                    end
                end
            end

            if not isPresent then
                table.insert(missingSpells, spellInput)
            end
        end
    end

    for _, icon in ipairs(iconPool) do
        icon:Hide()
    end

    local numMissing = #missingSpells
    if numMissing > 0 then
        container:Show()

        if SelfBuffTrackerDB.isLocked then
            container:SetBackdropColor(0, 0, 0, 0)
            container:SetBackdropBorderColor(0, 0, 0, 0)
            containerTitle:Hide()
        else
            container:SetBackdropColor(0, 0, 0, 0.6)
            container:SetBackdropBorderColor(1, 1, 1, 1)
            containerTitle:Show()
        end

        local iconSize = SelfBuffTrackerDB.iconSize
        local spacing = SelfBuffTrackerDB.spacing
        local totalWidth = math.max((numMissing * iconSize) + ((numMissing - 1) * spacing), 100)
        container:SetSize(totalWidth, iconSize + 10)

        for i, spellName in ipairs(missingSpells) do
            if not iconPool[i] then
                iconPool[i] = CreateBuffIcon()
            end
            
            local icon = iconPool[i]
            icon:SetSize(iconSize, iconSize)
            icon.texture:SetTexture(GetSpellTexture(spellName))
            icon:ClearAllPoints()
            
            local xOffset = (i - 1) * (iconSize + spacing)
            icon:SetPoint("LEFT", container, "LEFT", xOffset, 0)
            icon:Show()
        end

        if SelfBuffTrackerDB.soundEnabled then
            local now = GetTime()
            local hasNewlyMissing = false
            for _, spellName in ipairs(missingSpells) do
                if not previouslyMissing[spellName] then
                    hasNewlyMissing = true
                    break
                end
            end

            if hasNewlyMissing or (now - lastSoundTime) > SelfBuffTrackerDB.soundReminderInterval then
                addon.PlayWarningSound()
                lastSoundTime = now
            end
        end

        previouslyMissing = {}
        for _, spellName in ipairs(missingSpells) do
            previouslyMissing[spellName] = true
        end
    else
        previouslyMissing = {}
        if not SelfBuffTrackerDB.isLocked then
            container:Show()
            container:SetBackdropColor(0, 0, 0, 0.6)
            container:SetBackdropBorderColor(1, 1, 1, 1)
            containerTitle:Show()
            container:SetSize(120, SelfBuffTrackerDB.iconSize + 10)
        else
            container:Hide()
        end
    end
end
addon.CheckBuffs = CheckBuffs

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("PLAYER_ENTER_COMBAT")
frame:RegisterEvent("PLAYER_CONTROL_GAINED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, unit, ...)
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

        container:ClearAllPoints()
        if SelfBuffTrackerDB.anchorPosition and #SelfBuffTrackerDB.anchorPosition == 5 then
            container:SetPoint(unpack(SelfBuffTrackerDB.anchorPosition))
        else
            container:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
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
    elseif event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_AURA" and unit == "player") or event == "PLAYER_REGEN_DISABLED"
        or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" or event == "PLAYER_ENTER_COMBAT"
        or event == "PLAYER_CONTROL_GAINED" then
        CheckBuffs()
    end
end)