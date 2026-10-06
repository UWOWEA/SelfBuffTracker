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

    local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    cd:SetAllPoints(btn)
    cd:SetDrawEdge(false)
    btn.cooldown = cd

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

-- Works in combat: the swipe is fed by a duration object, so no secret values are read
local function UpdateIconCooldown(icon, spellId)
    local cd = icon.cooldown
    local id = tonumber(spellId)
    if not (cd and id and C_Spell) then
        if cd then cd:Clear() end
        return
    end

    if C_Spell.GetSpellCooldownDuration and cd.SetCooldownFromDurationObject then
        local ok, duration = pcall(C_Spell.GetSpellCooldownDuration, id)
        if ok and duration then
            cd:SetCooldownFromDurationObject(duration)
            return
        end
    elseif C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(id)
        if info and info.duration and info.duration > 1.5 then
            cd:SetCooldown(info.startTime, info.duration)
            return
        end
    end
    cd:Clear()
end

-- Falls back to the cooldown swipe visibility when API values are secret in combat
local function IsSpellOnCooldown(icon, spellId)
    local id = tonumber(spellId)
    if id and C_Spell and C_Spell.GetSpellCooldown then
        local ok, info = pcall(C_Spell.GetSpellCooldown, id)
        if ok and info and not (issecretvalue and (issecretvalue(info.duration) or issecretvalue(info.startTime))) then
            return (info.duration or 0) > 1.5 and (info.startTime + info.duration) > GetTime()
        end
    end
    return icon and icon.cooldown and icon.cooldown:IsShown() or false
end

local function GetSpellTexture(spellName)
    local spellInfo = addon.GetSpellInfo(spellName)
    if spellInfo and spellInfo.iconID then
        return spellInfo.iconID
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function GetClickSpellID(trackedSpellID)
    local spellID = tonumber(trackedSpellID) or trackedSpellID
    local baseSpellID = addon.GetBaseSpell and addon.GetBaseSpell(spellID)
    spellID = baseSpellID or spellID

    local overrideID = C_Spell and C_Spell.GetOverrideSpell
        and C_Spell.GetOverrideSpell(spellID)
    return overrideID and overrideID > 0 and overrideID or spellID
end

local previouslyMissing = {}
local wasOnCooldown = {}

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

    -- Icons are never hidden, only made transparent: alpha is allowed on protected frames in combat
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

        if not inCombat then
            addon.container:Show()
        end

        local iconSize = SelfBuffTrackerDB.iconSize
        local spacing = SelfBuffTrackerDB.spacing
        local cols = SelfBuffTrackerDB.columns or 3
        local rows = SelfBuffTrackerDB.rows or 5

        addon.container.ChangeSize(iconSize, cols, spacing, rows)
        local max = cols * rows

        local alertSpells = {}
        local cooldownReady = false

        for i, spellId in ipairs(missingSpells) do
            if i > max then
                return
            end
            if not iconPool[i] and not inCombat then
                iconPool[i] = CreateBuffIcon(spellId)
            end

            local icon = iconPool[i]
            if icon then
                if not inCombat then
                    icon:Show()
                end
                icon:SetAlpha(1)
                icon.texture:SetTexture(GetSpellTexture(spellId))
                local clickSpellID = GetClickSpellID(spellId)
                UpdateIconCooldown(icon, clickSpellID)

                local onCooldown = IsSpellOnCooldown(icon, clickSpellID)
                if not onCooldown then
                    table.insert(alertSpells, spellId)
                    if wasOnCooldown[spellId] then
                        cooldownReady = true
                    end
                end
                wasOnCooldown[spellId] = onCooldown or nil
            end
            if icon and not inCombat then
                if not (addon.isEditMode() and addon.container.IsInEditMode) then
                    icon:SetAttribute("spell1", GetClickSpellID(spellId))
                end
                icon:SetSize(iconSize, iconSize)
                icon:ClearAllPoints()

                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)

                local xOffset = col * (iconSize + spacing)
                local yOffset = -row * (iconSize + spacing)

                icon:SetPoint("TOPLEFT", addon.container, "TOPLEFT", xOffset, yOffset)
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
        -- Spells on cooldown stay silent; the alert fires right after the cooldown expires
        if not muteSound and #alertSpells > 0 then
            addon.PlaySoundAlert(alertSpells, previouslyMissing, isTimeIgnored or cooldownReady)
        end
    else
        if not inCombat then
            addon.container:Hide()
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
