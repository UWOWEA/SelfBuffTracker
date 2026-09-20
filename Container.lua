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

container:SetScript("OnClick", function(self, button)
    local isEditMode = EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
    if isEditMode then
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
        end
    end
end)

local containerTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
addon.containerTitle = containerTitle
containerTitle:SetPoint("BOTTOM", container, "TOP", 0, 4)
containerTitle:SetText(addon.L.MOVE_HINT)
addon.ApplyFont(containerTitle, "normalSmall")


container:SetScript("OnDragStart", function(self)
    local isEditMode = EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
    if isEditMode or not SelfBuffTrackerDB.isLocked then
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
    local isEditMode = EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
    if isEditMode then
        container:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        container:SetBackdropColor(0, 0.4, 0.8, 0.6)
        container:SetBackdropBorderColor(0, 0.8, 1, 1)
        containerTitle:Show()
    end
end)

if EditModeManagerFrame then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        container:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3}
        })
        container:SetBackdropColor(0, 0.4, 0.8, 0.6)
        container:SetBackdropBorderColor(0, 0.8, 1, 1)
        containerTitle:SetText(L.MOVE_HINT)
        containerTitle:Show()
        container:Show()
    end)

    EventRegistry:RegisterCallback("EditMode.Exit", function() 
        if addon.CheckBuffs then
            addon.CheckBuffs()
        end
    end)
end