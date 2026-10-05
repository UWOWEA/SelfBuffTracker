local addonName, addon = ...
local L = addon.L

local EDIT_DIALOG_GAP = 10

---@class ContainerButton : Button
---@field items table
---@field IsInEditMode boolean
local containerMixin

---@param container Frame
local function PositionEditDialog(container)
    ---@type Frame
    local dialog = addon.editDialog
    local uiScale = UIParent:GetEffectiveScale()
    local ratio = container:GetEffectiveScale() / uiScale
    local left, bottom, width, height = container:GetRect()
    if not left then return end

    left, bottom, width, height = left * ratio, bottom * ratio, width * ratio, height * ratio
    local dialogScale = dialog:GetEffectiveScale() / uiScale
    local dialogW = dialog:GetWidth() * dialogScale
    local dialogH = dialog:GetHeight() * dialogScale
    local screenW, screenH = UIParent:GetSize()

    local x = left + (width - dialogW) / 2
    local y = bottom - EDIT_DIALOG_GAP - dialogH
    if y < 0 then
        y = bottom + height + EDIT_DIALOG_GAP
    end

    x = math.max(0, math.min(x, screenW - dialogW))
    y = math.max(0, math.min(y, screenH - dialogH))

    dialog:ClearAllPoints()
    dialog:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / dialogScale, y / dialogScale)
end

addon.PositionEditDialog = PositionEditDialog

--- func desc
---@param name string
---@param parent Frame
---@return ContainerButton
local function CreateBuffTracker(name, parent)

    local container = CreateFrame("Button", name, parent, "BackdropTemplate")
    container:SetSize(200, 60)
    container:SetMovable(true)
    container:EnableMouse(true)
    container:RegisterForDrag("LeftButton")
    container:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    container:SetClampedToScreen(true)
    container.items = {}
    container.IsInEditMode = false

    container.AddItem = function (name, icon)

    end

    container.ChangeSize = function (iconSize, cols, spacing, rows)
        local amount = cols * rows
        local numRows = math.ceil(amount / cols)
        local numCols = math.min(amount, cols)

        local totalWidth = (numCols * iconSize) + ((numCols - 1) * spacing)
        local totalHeight = (numRows * iconSize) + ((numRows - 1) * spacing)

        container.width = math.max(totalWidth, 100)
        container.height = totalHeight + 10
        container:SetSize(container.width, totalHeight + 10)
    end

    container.GetSizes = function ()
        local iconSize = SelfBuffTrackerDB.iconSize
        local spacing = SelfBuffTrackerDB.spacing
        local cols = SelfBuffTrackerDB.columns
        local rows = SelfBuffTrackerDB.rows

        local totalWidth = (cols * iconSize) + ((cols - 1) * spacing)
        local totalHeight = (rows * iconSize) + ((rows - 1) * spacing)

        return totalWidth, totalHeight
    end

    container.GetSizeWidth = function ()
        local width, _ = container.GetSizes()
        return width
    end

    container.GetSizeHeight = function ()
        local _, height = container.GetSizes()
        return height
    end


    container:SetScript("OnClick", function(self, button)
        if addon.isEditMode() then
            if addon.editDialog:IsShown() then
                addon.editDialog:Hide()
            else
                addon.PositionEditDialog(container)
                addon.editDialog:Show()

                self:Show()
                addon.ApplyEditModeStyle()
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
            addon.ApplyEditModeStyle()
        end
    end)

    container:SetScript("OnEvent", function(self, event, unit, lineID, spellID)
        if event == "ADDON_LOADED" and unit == addonName then
            if not SelfBuffTrackerDB then
                SelfBuffTrackerDB = CopyTable(addon.defaultConfig)
            else
                for k, v in pairs(addon.defaultConfig) do
                    if SelfBuffTrackerDB[k] == nil then
                        SelfBuffTrackerDB[k] = v
                    end
                end
            end
            local iconSize = SelfBuffTrackerDB.iconSize
            local spacing = SelfBuffTrackerDB.spacing
            local cols = SelfBuffTrackerDB.columns
            local rows = SelfBuffTrackerDB.rows

            container.ChangeSize(iconSize, cols, spacing, rows)
        end
    end)

    return container
end

addon.CreateBuffTracker = CreateBuffTracker

local container = CreateBuffTracker("SelfBuffTrackerContainer", UIParent)
addon.container = container

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
    addon.container.IsInEditMode = true

    addon.CreateBackupSetting()
end

addon.ApplyEditModeStyle = ApplyEditModeStyle

local function ClearEditModeStyle()
    editOverlay:Hide()

    addon.container.IsInEditMode = false
end

addon.ClearEditModeStyle = ClearEditModeStyle

if EditModeManagerFrame then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        ApplyEditModeStyle()
        container:Show()
    end)

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        ClearEditModeStyle()
        if addon.CheckBuffs then
            addon.CheckBuffs(false)
        end
    end)
end
