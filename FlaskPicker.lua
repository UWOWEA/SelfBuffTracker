local addonName, addon = ...
local L = addon.L or {}

-- Seznam známých Flasků a Phials pro The War Within (Spell ID aur)
addon.TWW_FLASKS = {
    { spellID = 431971, name = "Flask of Alchemical Chaos" },
    { spellID = 431972, name = "Flask of Tempered Aggression" },
    { spellID = 431973, name = "Flask of Tempered Swiftness" },
    { spellID = 431974, name = "Flask of Tempered Mastery" },
    { spellID = 431975, name = "Flask of Tempered Versatility" },
    { spellID = 431976, name = "Flask of Saving Graces" },
    { spellID = 431977, name = "Flask of the Surge" },
}

local flaskPickerFrame = nil

local function CreateFlaskPickerFrame()
    if flaskPickerFrame then return flaskPickerFrame end

    local frame = CreateFrame("Frame", "SelfBuffTrackerFlaskPickerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(360, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 6, 1)
    frame.title:SetText(L.FLASK_PICKER_TITLE or "Select Flask / Phial")

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerFlaskPickerScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 6, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame.InsetBg, "BOTTOMRIGHT", -28, 6)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(300, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local ROW_HEIGHT = 36
    local rows = {}

    local function RefreshFlaskPickerList()
        for _, row in ipairs(rows) do row:Hide() end

        local yOffset = 0
        for i, entry in ipairs(addon.TWW_FLASKS) do
            local row = rows[i]
            if not row then
                row = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
                row:SetHeight(ROW_HEIGHT)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Buttons\\WHITE8X8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(1, 1, 1, 0.05)
                row:SetBackdropBorderColor(1, 1, 1, 0.08)

                row:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.15) end)
                row:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(26, 26)
                row.icon:SetPoint("LEFT", 6, 0)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.name:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                row.name:SetJustifyH("LEFT")

                rows[i] = row
            end

            local displayName, iconTexture = addon.GetSpellDisplayNameAndIcon(entry.spellID)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yOffset)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(iconTexture)
            row.name:SetText(displayName or entry.name)

            row:SetScript("OnClick", function()
                SelfBuffTrackerDB.trackedFlasks = SelfBuffTrackerDB.trackedFlasks or {}
                SelfBuffTrackerDB.trackedFlasks[tostring(entry.spellID)] = true

                if addon.CheckBuffs then addon.CheckBuffs(false) end
                if addon.RefreshFlaskOptionsPanel then addon.RefreshFlaskOptionsPanel() end

                print("|cff00ff00[SBT]|r Added flask: " .. (displayName or entry.name))
            end)

            row:Show()
            yOffset = yOffset - ROW_HEIGHT
        end

        scrollChild:SetSize(scrollFrame:GetWidth(), math.abs(yOffset))
    end

    frame:SetScript("OnShow", RefreshFlaskPickerList)
    flaskPickerFrame = frame
    return flaskPickerFrame
end

function addon.ToggleFlaskPicker()
    local picker = CreateFlaskPickerFrame()
    if picker:IsShown() then
        picker:Hide()
    else
        picker:Show()
    end
end