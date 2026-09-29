local addonName, addon = ...
local L = addon.L

local function isEditMode()
    return EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
end

addon.isEditMode = isEditMode

addon.editDialog = CreateFrame("Frame", "SelfBuffTrackerEditDialog", UIParent, "DialogBorderTranslucentTemplate")
addon.editDialog:SetSize(380, 190)
addon.editDialog:SetFrameStrata("FULLSCREEN_DIALOG")
addon.editDialog:SetFrameLevel(100)
addon.editDialog:SetMovable(true)
addon.editDialog:EnableMouse(true)
addon.editDialog:RegisterForDrag("LeftButton")
addon.editDialog:SetClampedToScreen(true)
addon.editDialog:Hide()

addon.editDialog:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

addon.editDialog:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

local title = addon.editDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", addon.editDialog, "TOP", 0, -20)
title:SetText(L.OPTIONS_TITLE or "Settings")
title:SetFontHeight(16)
addon.editDialog.Title = title

local closeButton = CreateFrame("Button", nil, addon.editDialog, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", addon.editDialog, "TOPRIGHT", 0, 0)
closeButton:SetScript("OnClick", function()
    addon.editDialog:Hide()
end)

--- func desc
---@param name string
---@param parent Frame
---@param labelText string
---@param minVal number
---@param maxVal number
---@param stepSize number
---@param defaultVal number
---@param callback any
local function CreateEditModeSlider(name, parent, labelText, minVal, maxVal, stepSize, defaultVal, callback)
    local slider = CreateFrame("Frame", name, parent, "MinimalSliderWithSteppersTemplate")

    local formatters = {}
    formatters[MinimalSliderWithSteppersMixin.Label.Right] = function(value)
        return tostring(math.floor(value + 0.5))
    end

    local numSteps = (maxVal - minVal) / stepSize
    slider:Init(defaultVal, minVal, maxVal, numSteps, formatters)

    if slider.Slider then
        slider.Slider:HookScript("OnValueChanged", function(self, value)
            if not slider:IsVisible() then return end
            callback(math.floor(value + 0.5))
        end)
    end

    slider.Label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slider.Label:SetJustifyH("LEFT")
    slider.Label:SetWidth(120)
    slider.Label:SetText(labelText)
    slider.Label:SetFontHeight(14)

    return slider
end

local function AnchorSliderRow(slider, yOffset)
    slider.Label:SetPoint("TOPLEFT", addon.editDialog, "TOPLEFT", 15, yOffset)

    slider:SetPoint("LEFT", slider.Label, "RIGHT", 10, 0)
    slider:SetPoint("RIGHT", addon.editDialog, "RIGHT", -40, 0)
end

SelfBuffTrackerDB = SelfBuffTrackerDB or {}
local initSize = SelfBuffTrackerDB.iconSize or 50
local initCols = SelfBuffTrackerDB.columns or 3
local initSpacing = SelfBuffTrackerDB.spacing or 10

addon.editDialogSizeSlider = CreateEditModeSlider(
    "SBTSizeSlider", addon.editDialog, L.ICON_SIZE or "Icon size",
    26, 100, 2, initSize,
    function(val)
        SelfBuffTrackerDB.iconSize = val
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)
AnchorSliderRow(addon.editDialogSizeSlider, -55)

addon.editDialogColSlider = CreateEditModeSlider(
    "SBTColSlider", addon.editDialog, L.COLUMS_AMOUNT or "Columns amount",
    1, 10, 1, initCols,
    function(val)
        SelfBuffTrackerDB.columns = val
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)
AnchorSliderRow(addon.editDialogColSlider, -95)

addon.editDialogSpacingSlider = CreateEditModeSlider(
    "SBTSpacingSlider", addon.editDialog, L.ICON_SPACING or "Spacing",
    1, 20, 1, initSpacing,
    function(val)
        SelfBuffTrackerDB.spacing = val
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)
AnchorSliderRow(addon.editDialogSpacingSlider, -135)

addon.editDialog:SetScript("OnShow", function()
    SelfBuffTrackerDB = SelfBuffTrackerDB or {}
    local size = SelfBuffTrackerDB.iconSize or 50
    local cols = SelfBuffTrackerDB.columns or 3
    local spacing = SelfBuffTrackerDB.spacing or 10

    addon.editDialogSizeSlider:SetValue(size)
    addon.editDialogColSlider:SetValue(cols)
    addon.editDialogSpacingSlider:SetValue(spacing)
end)

if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        addon.editDialog:Hide()
        if addon.LockContainer then addon.LockContainer() end
    end)
end
