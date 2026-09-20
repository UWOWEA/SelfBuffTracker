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
    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
        container:Hide()
        return
    end

    local activeBuffs = {}
    for i = 1, 40 do
        local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
        if not ok or not aura then break end
        if aura.name then
            activeBuffs[aura.name:lower()] = true
        end
    end

    local missingSpells = {}
    for spell, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
        if enabled and not activeBuffs[spell:lower()] then
            table.insert(missingSpells, spell)
        end
    end

    for _, icon in ipairs(iconPool) do
        icon:Hide()
    end

    local numMissing = #missingSpells
    if numMissing > 0 or not SelfBuffTrackerDB.isLocked then
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

        if numMissing > 0 and SelfBuffTrackerDB.soundEnabled then
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
        container:Hide()
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
        container:SetPoint(unpack(SelfBuffTrackerDB.anchorPosition))
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
        or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" or event == "PLAYER_ENTER_COMBAT" then
        CheckBuffs()
    end
end)