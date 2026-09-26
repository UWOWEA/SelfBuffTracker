local addonName, addon = ...
local L = addon.L

local container = CreateFrame("Button", "SelfBuffTrackerContainer", UIParent, "BackdropTemplate")
addon.container = container
container:SetSize(200, 60)
container:SetMovable(true)
container:EnableMouse(true)
container:RegisterForDrag("LeftButton")
container:RegisterForClicks("LeftButtonUp", "RightButtonUp")
container:SetClampedToScreen(true)

local containerTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
addon.containerTitle = containerTitle
containerTitle:SetPoint("BOTTOM", container, "TOP", 0, 4)
containerTitle:SetText(addon.L.MOVE_HINT)
containerTitle:Hide()
addon.ApplyFont(containerTitle, "normalSmall")

local editOverlay = CreateFrame("Frame", nil, container, "BackdropTemplate")
editOverlay:SetAllPoints(container)
editOverlay:SetFrameLevel(container:GetFrameLevel() + 10)
editOverlay:Hide()

addon.editOverlay = editOverlay

local function ApplyEditModeStyle()
    addon.container:Show()
    editOverlay:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    editOverlay:SetBackdropColor(0.12, 0.35, 0.45)
    editOverlay:SetBackdropBorderColor(0.2, 0.8, 1.0, 0.9)

    editOverlay:SetBackdropColor(0.12, 0.35, 0.45, 0.6)
    editOverlay:SetBackdropBorderColor(0.2, 0.8, 1.0, 0.9)
    editOverlay:Show()
    if addon.containerTitle then addon.containerTitle:Show() end
end

addon.ApplyEditModeStyle = ApplyEditModeStyle

local function ClearEditModeStyle()
    editOverlay:Hide()
    containerTitle:Hide()
end

addon.ClearEditModeStyle = ClearEditModeStyle

container:SetScript("OnClick", function(self, button)
    if addon.isEditMode() then
        if addon.editDialog:IsShown() then
            addon.editDialog:Hide()
        else
            local currentSize = SelfBuffTrackerDB.iconSize or 50
            local currentCols = SelfBuffTrackerDB.columns or 3

            addon.editDialogSizeSlider:SetValue(currentSize)
            addon.editDialogSizeText:SetText(L.ICON_SIZE)
            addon.editDialogSizeValueText:SetText(tostring(currentSize))

            addon.editDialogColSlider:SetValue(currentCols)
            addon.editDialogColText:SetText(L.COLUMS_AMOUNT)
            addon.editDialogColValueText:SetText(tostring(currentCols))

            addon.editDialog:ClearAllPoints()
            addon.editDialog:SetPoint("LEFT", container, "RIGHT", 20, 0)
            addon.editDialog:Show()

            self:Show()
            ApplyEditModeStyle()
            if containerTitle then
                containerTitle:Show()
            end
        end
    end
end)

container:SetScript("OnDragStart", function(self)
    if addon.isEditMode() then
        if addon.editDialog then
            addon.editDialog:Hide()
        end
        self:StartMoving()
    end
end)

container:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    SelfBuffTrackerDB.anchorPosition = { point, nil, relPoint, x, y }
    if addon.isEditMode() then
        ApplyEditModeStyle()
    end
end)

if EditModeManagerFrame then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        ApplyEditModeStyle()
        if containerTitle then
            containerTitle:SetText(L.MOVE_HINT)
            containerTitle:Show()
        end
        container:Show()
    end)

    EventRegistry:RegisterCallback("EditMode.Exit", function() 
        ClearEditModeStyle()
        if addon.CheckBuffs then
            addon.CheckBuffs()
        end
    end)
end