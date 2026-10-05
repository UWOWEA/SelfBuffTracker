local addonName, addon = ...
local L = addon.L

---@class SliderFrame : Frame, MinimalSliderWithSteppersTemplate
---@field Label FontString
local sliderMixin

local function isEditMode()
    return EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
end

addon.isEditMode = isEditMode

addon.editDialog = CreateFrame("Frame", "SelfBuffTrackerEditDialog", UIParent, "DialogBorderTranslucentTemplate")
addon.editDialog:SetSize(380, 260)
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
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
    addon.editDialog:Hide()
end)

---@param name string
---@param parent Frame
---@param labelText string
---@param minVal number
---@param maxVal number
---@param stepSize number
---@param defaultVal number
---@param callback function
---@return SliderFrame
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

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    label:SetJustifyH("LEFT")
    label:SetWidth(120)
    label:SetText(labelText)
    label:SetFontHeight(14)

    slider.Label = label
    return slider
end

---@param name string
---@param parent Frame
---@param labelText string
---@param callback function
---@return Button
local function CreateSubmitButton(name, parent, labelText, callback)
    local button = CreateFrame('Button', name, parent, "UIPanelButtonTemplate")
    button:SetSize(100, 30)
    button:SetText(labelText)
    button:SetPoint("RIGHT", parent, "BOTTOMRIGHT", -20, 30)
    button:HookScript("OnClick", function (self)
        if not button:IsVisible() then return end
        callback()
    end)

    return button
end

---@param name string
---@param parent Frame
---@param labelText string
---@param callback function
---@return Button
local function CreateRevertButton(name, parent, labelText, callback)
    local button = CreateFrame('Button', name, parent, "UIPanelButtonTemplate")
    button:SetSize(120, 30)
    button:SetText(labelText)
    button:SetPoint("LEFT", parent, "BOTTOMLEFT", 20, 30)
    button:HookScript("OnClick", function (self)
        if not button:IsVisible() then return end
        callback()
    end)

    return button
end

---@param name string
---@param parent Frame
---@param labelText string
---@param defaultVal boolean
---@param callback function
---@return CheckButton
local function CreateCheckbox(name, parent, labelText, defaultVal, callback)
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

---@param slider SliderFrame
---@param yOffset integer
local function AnchorSliderRow(slider, yOffset)
    slider.Label:SetPoint("TOPLEFT", addon.editDialog, "TOPLEFT", 15, yOffset)

    slider:SetPoint("LEFT", slider.Label, "RIGHT", 15, 0)
    slider:SetPoint("RIGHT", addon.editDialog, "RIGHT", -40, 0)
end

SelfBuffTrackerDB = SelfBuffTrackerDB or {}
local initSize = SelfBuffTrackerDB.iconSize or 50
local initCols = SelfBuffTrackerDB.columns or 3
local initRows = SelfBuffTrackerDB.rows or 5
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

addon.editDialogRowSlider = CreateEditModeSlider(
    "SBTRowSlider", addon.editDialog, L.ROWS_AMOUNT or "Rows amount",
    1, 10, 1, initRows,
    function(val)
        SelfBuffTrackerDB.rows = val
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)
AnchorSliderRow(addon.editDialogRowSlider, -135)

addon.editDialogSpacingSlider = CreateEditModeSlider(
    "SBTSpacingSlider", addon.editDialog, L.ICON_SPACING or "Spacing",
    1, 20, 1, initSpacing,
    function(val)
        SelfBuffTrackerDB.spacing = val
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)
AnchorSliderRow(addon.editDialogSpacingSlider, -175)

addon.editDialogRevert = CreateRevertButton(
    "SBTEditDialogRevert",
    addon.editDialog,
    "Revert Changes",
    function()
        addon.RevertBackupSetting()
        addon.editDialog:Hide()
        addon.editDialog:Show()
        if type(addon.CheckBuffs) == "function" then addon.CheckBuffs(false) end
    end
)

addon.editDialogSubmit = CreateSubmitButton(
    "SBTEditDialogSubmit",
    addon.editDialog,
    "Submit",
    function()
        addon.CreateBackupSetting()
        addon.editDialog:Hide()
    end
)

local children = {addon.editDialog:GetChildren()}

local fullHeight = 0
for _, child in ipairs(children) do
    local height = child:GetHeight(false)
    fullHeight = fullHeight + height
end

addon.editDialog:SetHeight(fullHeight + 15)

local function OnShow()
    addon.CreateBackupSetting()
    SelfBuffTrackerDB = SelfBuffTrackerDB or {}
    local size = SelfBuffTrackerDB.iconSize or 50
    local cols = SelfBuffTrackerDB.columns or 3
    local spacing = SelfBuffTrackerDB.spacing or 10
    local rows = SelfBuffTrackerDB.rows or 5

    addon.editDialogSizeSlider:SetValue(size)
    addon.editDialogColSlider:SetValue(cols)
    addon.editDialogSpacingSlider:SetValue(spacing)
    addon.editDialogRowSlider:SetValue(rows)
    addon.editDialogSubmit:Show()
end

addon.editDialog:SetScript("OnShow", function()
    OnShow()
end)

if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        addon.editDialog:Hide()
        if addon.LockContainer then addon.LockContainer() end
    end)
end
