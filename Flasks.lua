local addonName, addon = ...

addon.TWW_FLASKS = {
    { spellID = 431971, name = "Flask of Alchemical Chaos" },
    { spellID = 431972, name = "Flask of Tempered Aggression" },
    { spellID = 431973, name = "Flask of Tempered Swiftness" },
    { spellID = 431974, name = "Flask of Tempered Mastery" },
    { spellID = 431975, name = "Flask of Tempered Versatility" },
    { spellID = 431976, name = "Flask of Saving Graces" },
}

-- Přidání / Odebrání Flasky z databáze
function addon.ToggleTrackedFlask(flaskID, state)
    if not SelfBuffTrackerDB then return end
    SelfBuffTrackerDB.trackedFlasks = SelfBuffTrackerDB.trackedFlasks or {}
    
    local key = tostring(flaskID)
    if state ~= nil then
        SelfBuffTrackerDB.trackedFlasks[key] = state
    else
        SelfBuffTrackerDB.trackedFlasks[key] = not SelfBuffTrackerDB.trackedFlasks[key]
    end

    if addon.CheckBuffs then addon.CheckBuffs() end
    if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
end

-- Vykreslení seznamu vybraných Flasků v GUI nastavení
function addon.BuildFlaskListFrame(parentFrame)
    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedFlasks then return end

    local container = parentFrame.flaskListContainer or CreateFrame("Frame", nil, parentFrame)
    parentFrame.flaskListContainer = container

    -- Vyčištění starých řádků
    if container.rows then
        for _, row in ipairs(container.rows) do
            row:Hide()
        end
    end
    container.rows = {}

    local yOffset = 0
    for flaskInput, enabled in pairs(SelfBuffTrackerDB.trackedFlasks) do
        local row = CreateFrame("Frame", nil, container)
        row:SetSize(340, 26)
        row:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

        -- Ikona + Název
        local name, icon = addon.GetSpellDisplayNameAndIcon(flaskInput)
        
        local tex = row:CreateTexture(nil, "ARTWORK")
        tex:SetSize(20, 20)
        tex:SetPoint("LEFT", row, "LEFT", 0, 0)
        tex:SetTexture(icon)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", tex, "RIGHT", 8, 0)
        label:SetText(name)

        -- Smazat tlačítko (Smazat ze seznamu sledovaných)
        local removeBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        removeBtn:SetSize(22, 22)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        removeBtn:SetScript("OnClick", function()
            SelfBuffTrackerDB.trackedFlasks[tostring(flaskInput)] = nil
            if addon.CheckBuffs then addon.CheckBuffs() end
            if addon.RefreshOptionsPanel then addon.RefreshOptionsPanel() end
        end)

        table.insert(container.rows, row)
        yOffset = yOffset - 28
    end

    container:SetSize(340, math.abs(yOffset))
end