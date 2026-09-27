local addonName, addon = ...

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

function addon.BuildFlaskListFrame(parentFrame)
    if not SelfBuffTrackerDB or not SelfBuffTrackerDB.trackedFlasks then return end

    local container = parentFrame.flaskListContainer or CreateFrame("Frame", nil, parentFrame)
    parentFrame.flaskListContainer = container

    if container.rows then
        for _, row in ipairs(container.rows) do
            row:Hide()
        end
    end
    container.rows = {}

    local yOffset = 0
    for flaskInput, _ in pairs(SelfBuffTrackerDB.trackedFlasks) do
        local row = CreateFrame("Frame", nil, container)
        row:SetSize(340, 26)
        row:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)

        local name, icon = addon.GetSpellDisplayNameAndIcon(flaskInput)
        
        local tex = row:CreateTexture(nil, "ARTWORK")
        tex:SetSize(20, 20)
        tex:SetPoint("LEFT", row, "LEFT", 0, 0)
        tex:SetTexture(icon)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", tex, "RIGHT", 8, 0)
        label:SetText(name)

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