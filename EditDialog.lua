local addonName, addon = ...
local L = addon.L
addon.editDialog = CreateFrame("Frame", "SelfBuffTrackerEditDialog", UIParent, "BackdropTemplate")
addon.editDialog:SetSize(300, 250)
addon.editDialog:SetFrameStrata("FULLSCREEN_DIALOG")
addon.editDialog:SetFrameLevel(100)
addon.editDialog:SetMovable(true)
addon.editDialog:EnableMouse(true)
addon.editDialog:RegisterForDrag("LeftButton")
addon.editDialog:SetClampedToScreen(true)
addon.editDialog:Hide()

addon.editDialog:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
addon.editDialog:SetBackdropColor(0.05, 0.05, 0.05, 1)

addon.editDialog:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

addon.editDialog:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

local title = addon.editDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", addon.editDialog, "TOP", 0, -10)
title:SetText(L.OPTIONS_TITLE)

local closeButton = CreateFrame("Button", nil, addon.editDialog, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", addon.editDialog, "TOPRIGHT", -2, -2)
closeButton:SetScript("OnClick", function()
    addon.editDialog:Hide()
end)

addon.editDialogSizeSlider = CreateFrame("Slider", "SBTSizeSlider", addon.editDialog, "OptionsSliderTemplate")
addon.editDialogSizeSlider:SetPoint("TOPLEFT", addon.editDialog, "TOPLEFT", 15, -45)
addon.editDialogSizeSlider:SetMinMaxValues(20, 100)
addon.editDialogSizeSlider:SetValueStep(2)

addon.editDialogSizeText = addon.editDialogSizeSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
addon.editDialogSizeText:SetPoint("BOTTOMLEFT", addon.editDialogSizeSlider, "TOPLEFT", 0, 3)

addon.editDialogSizeValueText = addon.editDialogSizeSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
addon.editDialogSizeValueText:SetPoint("BOTTOMRIGHT", addon.editDialogSizeSlider, "TOPRIGHT", 0, 3)

if _G[addon.editDialogSizeSlider:GetName() .. 'Text'] then _G[addon.editDialogSizeSlider:GetName() .. 'Text']:SetText("") end
if _G[addon.editDialogSizeSlider:GetName() .. 'Low'] then _G[addon.editDialogSizeSlider:GetName() .. 'Low']:SetText("") end
if _G[addon.editDialogSizeSlider:GetName() .. 'High'] then _G[addon.editDialogSizeSlider:GetName() .. 'High']:SetText("") end

addon.editDialogSizeSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    SelfBuffTrackerDB.iconSize = value
    addon.editDialogSizeText:SetText(L.ICON_SIZE)
    addon.editDialogSizeValueText:SetText(tostring(value))
    if addon.CheckBuffs then addon.CheckBuffs() end
end)

addon.editDialogColSlider = CreateFrame("Slider", "SBTColSlider", addon.editDialog, "OptionsSliderTemplate")
addon.editDialogColSlider:SetPoint("TOPLEFT", addon.editDialogSizeSlider, "BOTTOMLEFT", 0, -35)
addon.editDialogColSlider:SetMinMaxValues(1, 10)
addon.editDialogColSlider:SetValueStep(1)

addon.editDialogColText = addon.editDialogColSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
addon.editDialogColText:SetPoint("BOTTOMLEFT", addon.editDialogColSlider, "TOPLEFT", 0, 3)

addon.editDialogColValueText = addon.editDialogColSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
addon.editDialogColValueText:SetPoint("BOTTOMRIGHT", addon.editDialogColSlider, "TOPRIGHT", 0, 3)

if _G[addon.editDialogColSlider:GetName() .. 'Text'] then _G[addon.editDialogColSlider:GetName() .. 'Text']:SetText("") end
if _G[addon.editDialogColSlider:GetName() .. 'Low'] then _G[addon.editDialogColSlider:GetName() .. 'Low']:SetText("") end
if _G[addon.editDialogColSlider:GetName() .. 'High'] then _G[addon.editDialogColSlider:GetName() .. 'High']:SetText("") end

addon.editDialogColSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    SelfBuffTrackerDB.columns = value
    addon.editDialogColText:SetText(L.COLUMS_AMOUNT)
    addon.editDialogColValueText:SetText(tostring(value))
    if addon.CheckBuffs then addon.CheckBuffs() end
end)

if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        addon.editDialog:Hide()
    end)
end
