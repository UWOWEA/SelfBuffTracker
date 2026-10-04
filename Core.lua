local addonName, addon = ...


local iconPool = {}

local function CreateBuffIcon()
    local btn = CreateFrame("Button", nil, addon.container, "BackdropTemplate")
    btn:SetSize(SelfBuffTrackerDB.iconSize, SelfBuffTrackerDB.iconSize)

    btn:SetFrameLevel(addon.container:GetFrameLevel() - 1)
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
    addon.container.title:Hide()
end

addon.UnLockContainer = function ()
    SelfBuffTrackerDB.isLocked = false
    addon.container:SetBackdropColor(0, 0, 0, 0.6)
    addon.container:SetBackdropBorderColor(1, 1, 1, 1)
    addon.container.title:Show()
end

local function CheckBuffs(isTimeIgnored, muteSound)
    if not muteSound then
        muteSound = false
    end

    if not SelfBuffTrackerDB then return end

    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
        addon.container:Hide()
        addon.container.title:Hide()
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

        addon.container.ChangeSize(iconSize, cols, spacing, numMissing)

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

        if addon.isEditMode() and addon.container.IsInEditMode then
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
            addon.container.title:Show()
            addon.container:SetSize(120, SelfBuffTrackerDB.iconSize + 10)
        else
            addon.container:Hide()
            addon.container.title:Hide()
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
