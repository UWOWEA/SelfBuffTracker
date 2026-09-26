local addonName, addon = ...

local flaskRows = {}

local function CreateTrackedFlasksSubcategory(parentCategory)
    local L = addon.L

    local panel = CreateFrame("Frame", "SelfBuffTrackerFlasksPanel", UIParent)
    panel.name = L.TRACKED_FLASKS

    local flasksLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    flasksLabel:SetPoint("TOPLEFT", 16, -16)
    flasksLabel:SetText(L.TRACKED_FLASKS or "Tracked Flasks & Phials")
    addon.ApplyFont(flasksLabel, "normalLarge")

    local flaskEditBox = CreateFrame("EditBox", "SelfBuffTrackerOptionsFlaskEditBox", panel, "InputBoxTemplate")
    flaskEditBox:SetAutoFocus(false)
    flaskEditBox:SetSize(200, 20)
    flaskEditBox:SetPoint("TOPLEFT", flasksLabel, "BOTTOMLEFT", 8, -12)

    local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(80, 22)
    addButton:SetText(L.ADD_BUTTON)
    addButton:SetPoint("LEFT", flaskEditBox, "RIGHT", 8, 0)
    addon.ApplyFont(addButton, "highlight")

    local flaskPickerButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    flaskPickerButton:SetSize(150, 22)
    flaskPickerButton:SetText(L.FLASK_PICKER_BUTTON or "Flask Picker")
    flaskPickerButton:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
    addon.ApplyFont(flaskPickerButton, "highlight")
    flaskPickerButton:SetScript("OnClick", function()
        if addon.ToggleFlaskPicker then
            addon.ToggleFlaskPicker()
        end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerOptionsFlaskScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", flaskEditBox, "BOTTOMLEFT", -4, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 16)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local ROW_HEIGHT = 30

    local function RefreshFlaskList()
        for _, row in ipairs(flaskRows) do row:Hide() end

        local flasks = {}
        if SelfBuffTrackerDB and SelfBuffTrackerDB.trackedFlasks then
            for flask, enabled in pairs(SelfBuffTrackerDB.trackedFlasks) do
                if enabled then table.insert(flasks, flask) end
            end
        end
        table.sort(flasks)

        scrollChild:SetSize(scrollFrame:GetWidth(), math.max(#flasks * ROW_HEIGHT, 1))

        for i, flask in ipairs(flasks) do
            local displayName, iconTexture = addon.GetSpellDisplayNameAndIcon(flask)
            local row = flaskRows[i]
            if not row then
                row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
                row:SetHeight(ROW_HEIGHT)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Buttons\\WHITE8X8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(1, 1, 1, 0.05)
                row:SetBackdropBorderColor(1, 1, 1, 0.08)
                row:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.12) end)
                row:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(22, 22)
                row.icon:SetPoint("LEFT", 6, 0)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                row.removeButton = CreateFrame("Button", nil, row)
                row.removeButton:SetSize(18, 18)
                row.removeButton:SetPoint("RIGHT", -8, 0)
                row.removeButton:SetNormalAtlas("common-icon-redx")
                row.removeButton:SetPushedAtlas("common-icon-redx")
                row.removeButton:SetHighlightAtlas("common-icon-redx", "ADD")

                row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.text:SetPoint("RIGHT", row.removeButton, "LEFT", -8, 0)
                row.text:SetJustifyH("LEFT")
                addon.ApplyFont(row.text, "highlight")

                flaskRows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(iconTexture)
            row.text:SetText(displayName)
            row.removeButton:SetScript("OnClick", function()
                SelfBuffTrackerDB.trackedFlasks[flask] = nil
                if addon.CheckBuffs then addon.CheckBuffs(false) end
                RefreshFlaskList()
            end)
            row:Show()
        end
    end

    addButton:SetScript("OnClick", function()
        local text = strtrim(flaskEditBox:GetText() or "")
        if text ~= "" then
            SelfBuffTrackerDB.trackedFlasks = SelfBuffTrackerDB.trackedFlasks or {}
            SelfBuffTrackerDB.trackedFlasks[text] = true
            flaskEditBox:SetText("")
            if addon.CheckBuffs then addon.CheckBuffs(false) end
            RefreshFlaskList()
        end
    end)
    flaskEditBox:SetScript("OnEnterPressed", function(self)
        addButton:Click()
        self:ClearFocus()
    end)

    panel:SetScript("OnShow", RefreshFlaskList)
    addon.RefreshFlaskOptionsPanel = RefreshFlaskList

    Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, panel.name)
    RefreshFlaskList()
end

addon.CreateTrackedFlasksSubcategory = CreateTrackedFlasksSubcategory
