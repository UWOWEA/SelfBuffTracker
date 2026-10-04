local addonName, addon = ...
local L = addon.L

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

    container.ChangeSize = function (iconSize, cols, spacing, itemAmount)
        if cols <= 0 then cols = itemAmount end
        local numRows = math.ceil(itemAmount / cols)
        local numCols = math.min(itemAmount, cols)

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

        local totalWidth = (cols * iconSize) + ((cols - 1) * spacing)
        local totalHeight = (cols * iconSize) + ((cols - 1) * spacing)

        return totalWidth, totalHeight
    end

    container.GetWidth = function ()
        local width, _ = container.GetSizes()
        return width
    end

    container.GetHeight = function ()
        local _, height = container.GetSizes()
        return height
    end

    local containerTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

    container.title = containerTitle
    container.title:SetPoint("BOTTOM", container, "TOP", 0, 4)
    container.title:SetText(addon.L.MOVE_HINT)
    container.title:Hide()
    addon.ApplyFont(container.title, "normalSmall")

    container:SetScript("OnClick", function(self, button)
        if addon.isEditMode() then
            if addon.editDialog:IsShown() then
                addon.editDialog:Hide()
            else
                addon.editDialog:ClearAllPoints()
                addon.editDialog:SetPoint("LEFT", container, "RIGHT", 20, 0)
                addon.editDialog:Show()

                self:Show()
                addon.ApplyEditModeStyle()
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

            container.ChangeSize(iconSize, cols, spacing, cols)
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
    if addon.containerTitle then addon.containerTitle:Show() end
    addon.container.IsInEditMode = true

    addon.CreateBackupSetting()
end

addon.ApplyEditModeStyle = ApplyEditModeStyle

local function ClearEditModeStyle()
    editOverlay:Hide()
    container.title:Hide()

    addon.container.IsInEditMode = false
end

addon.ClearEditModeStyle = ClearEditModeStyle

if EditModeManagerFrame then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        ApplyEditModeStyle()
        if container.title then
            container.title:SetText(L.MOVE_HINT)
            container.title:Show()
        end
        container:Show()
    end)

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        ClearEditModeStyle()
        if addon.CheckBuffs then
            addon.CheckBuffs(false)
        end
    end)
end
