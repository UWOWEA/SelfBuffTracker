local addonName, addon = ...

local iconPool = {}

---@param spellId number
---@return Button
local function CreateBuffIcon(spellId)
    local btn = CreateFrame("Button", nil, addon.container, "SecureActionButtonTemplate,BackdropTemplate")
    btn:SetSize(SelfBuffTrackerDB.iconSize, SelfBuffTrackerDB.iconSize)

    if addon.isEditMode() and addon.container.IsInEditMode then
        btn:SetFrameLevel(addon.container:GetFrameLevel() - 1)
    end
    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(btn)
    btn.texture = tex

    btn:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    btn:SetBackdropBorderColor(1, 0, 0, 1)

    if addon.isEditMode() and addon.container.IsInEditMode then
    else
        btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
        btn:SetAttribute("type1", "spell")
    end

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
end

addon.UnLockContainer = function ()
    SelfBuffTrackerDB.isLocked = false
    addon.container:SetBackdropColor(0, 0, 0, 0.6)
    addon.container:SetBackdropBorderColor(1, 1, 1, 1)
end

local function CheckBuffs(isTimeIgnored, muteSound)
    if not muteSound then
        muteSound = false
    end

    if not SelfBuffTrackerDB then return end

    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
        addon.container:Hide()
        return
    end

    local missingSpells = {}
    if addon.isEditMode() and addon.container.IsInEditMode then
        missingSpells = addon.Mocks.missingSpells
    else
        missingSpells = addon.getMissingSpells()
    end

    if SelfBuffTrackerDB.isDebug then
        print("[Debug] missing spells amount:", missingSpells)
    end

    -- Secure buttons cannot be changed, moved or hidden during combat
    local inCombat = InCombatLockdown()

    -- Alpha is the only visibility control allowed on protected frames in combat
    for _, icon in ipairs(iconPool) do
        icon:SetAlpha(0)
        if not inCombat then
            icon:Hide()
        end
    end

    local numMissing = #missingSpells

    if SelfBuffTrackerDB.isDebug then
        print("[Debug] missing spells amount:", numMissing)
    end

    if numMissing > 0 then
        if not addon.isEditMode() and not addon.container.IsInEditMode then
            addon.container:Show()
        end

        local iconSize = SelfBuffTrackerDB.iconSize
        local spacing = SelfBuffTrackerDB.spacing
        local cols = SelfBuffTrackerDB.columns or 3
        local rows = SelfBuffTrackerDB.rows or 5

        addon.container.ChangeSize(iconSize, cols, spacing, rows)
        local max = cols * rows

        for i, spellId in ipairs(missingSpells) do
            if i > max then
                return
            end
            if not iconPool[i] and not inCombat then
                iconPool[i] = CreateBuffIcon(spellId)
            end

            local icon = iconPool[i]
            if icon then
                icon:SetAlpha(1)
                icon.texture:SetTexture(GetSpellTexture(spellId))
            end
            if icon and not inCombat then
                if not (addon.isEditMode() and addon.container.IsInEditMode) then
                    icon:SetAttribute("spell1", tonumber(spellId) or spellId)
                end
                icon:SetSize(iconSize, iconSize)
                icon:ClearAllPoints()

                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)

                local xOffset = col * (iconSize + spacing)
                local yOffset = -row * (iconSize + spacing)

                icon:SetPoint("TOPLEFT", addon.container, "TOPLEFT", xOffset, yOffset)
                icon:Show()
            end
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
