---@class dialog : Frame
local dialog = CreateFrame("Frame", "SelfBuffTrackerEditDialog", UIParent, "DialogBorderTranslucentTemplate")
dialog:SetSize(380, 260)
dialog:SetFrameStrata("FULLSCREEN_DIALOG")
dialog:SetFrameLevel(100)
dialog:SetMovable(true)
dialog:EnableMouse(true)
dialog:RegisterForDrag("LeftButton")
dialog:SetClampedToScreen(true)
dialog:Hide()

dialog:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

dialog:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

function dialog:CreateCheckbox(name, parent, labelText, defaultVal, callback)
    local checkBox = CreateFrame("CheckButton", name, parent, "OptionsBaseCheckButtonTemplate")
    checkBox:SetChecked(defaultVal)

    checkBox.Label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    checkBox.Label:SetJustifyH("LEFT")
    checkBox.Label:SetWidth(120)
    checkBox.Label:SetText(labelText)
    checkBox.Label:SetFontHeight(14)

    checkBox:SetPoint("LEFT", checkBox.Label, "RIGHT", 15, 0)
    checkBox.Label:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -215)

    checkBox:HookScript("OnClick", function()
        if not checkBox:IsVisible() then return end
        callback(checkBox:GetChecked())
    end)

    return checkBox
end

dialog:SetScript("OnShow", function()
    local children = {dialog:GetChildren()}
    local fullHeight = 0
    for _, child in ipairs(children) do
        local height = child:GetHeight(false)
        fullHeight = fullHeight + height
    end

    dialog:SetHeight(fullHeight + 15)
end)
