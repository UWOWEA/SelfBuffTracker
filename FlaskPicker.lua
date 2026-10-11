local _, addon = ...
local L = addon.L or {}

local flaskPickerFrame

local function CreateFlaskPickerFrame(parent)
    local frame = CreateFrame("Frame", "SelfBuffTrackerFlaskPickerFrame", parent or UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(380, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetTextColor(1, 0.82, 0, 1)
    frame.title:SetPoint("TOPLEFT", frame.TitleBg, "LEFT", 6, 5)
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
        for i, entry in ipairs(addon.Database.Flasks) do
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

            displayName = displayName .. " [" .. entry.category .. "]"

            if SelfBuffTrackerDB.isDebug then
                displayName = displayName .. " - ID: " .. entry.spellID
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yOffset)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(iconTexture)
            row.name:SetText(displayName or entry.name)

            row:SetScript("OnEnter", function()
                GameTooltip:SetOwner(row, "ANCHOR_TOPRIGHT")
                GameTooltip:SetSpellByID(entry.spellID)
                GameTooltip:Show()
            end)

            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

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
    frame:Hide()
    return frame
end

---@param parent? Frame
function addon.ToggleFlaskPicker(parent)
    if not flaskPickerFrame then
        flaskPickerFrame = CreateFlaskPickerFrame(parent)
    end

    if flaskPickerFrame:IsShown() then
        flaskPickerFrame:Hide()
    else
        flaskPickerFrame:Show()
    end
end
