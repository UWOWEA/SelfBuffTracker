local addonName, addon = ...

local spellRows = {}

local function CreateTrackedBuffsSubcategory(parentCategory)
    local L = addon.L

    local panel = CreateFrame("Frame", "SelfBuffTrackerBuffsPanel", UIParent)
    panel.name = L.TRACKED_BUFFS

    local copyLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    copyLabel:SetPoint("TOPLEFT", 16, -16)
    copyLabel:SetText(L.COPY_LABEL)

    local copyDropdown = CreateFrame("Frame", "SelfBuffTrackerOptionsCopyDropdown", panel, "UIDropDownMenuTemplate")
    copyDropdown:SetPoint("TOPLEFT", copyLabel, "BOTTOMLEFT", -16, -4)
    UIDropDownMenu_SetWidth(copyDropdown, 160)

    local selectedProfileKey

    local function RefreshCopyDropdown()
        selectedProfileKey = nil
        UIDropDownMenu_SetText(copyDropdown, L.COPY_SELECT_CHARACTER)

        UIDropDownMenu_Initialize(copyDropdown, function(dropdown, level)
            for _, profile in ipairs(addon.GetOtherClassProfiles and addon.GetOtherClassProfiles() or {}) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = profile.name .. " - " .. profile.realm
                info.func = function()
                    selectedProfileKey = profile.key
                    UIDropDownMenu_SetText(copyDropdown, info.text)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
    end

    local copyButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyButton:SetSize(100, 22)
    copyButton:SetText(L.COPY_BUTTON)
    copyButton:SetPoint("LEFT", copyDropdown, "RIGHT", 8, 2)
    copyButton:SetScript("OnClick", function()
        if selectedProfileKey and addon.CopyProfileFrom then
            addon.CopyProfileFrom(selectedProfileKey)
            print("|cff00ff00[SBT]|r " .. L.COPY_DONE)
        end
    end)

    local spellsLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    spellsLabel:SetPoint("TOPLEFT", copyDropdown, "BOTTOMLEFT", 16, -20)
    spellsLabel:SetText(L.TRACKED_BUFFS)

    local spellEditBox = CreateFrame("EditBox", "SelfBuffTrackerOptionsSpellEditBox", panel, "InputBoxTemplate")
    spellEditBox:SetAutoFocus(false)
    spellEditBox:SetSize(200, 20)
    spellEditBox:SetPoint("TOPLEFT", spellsLabel, "BOTTOMLEFT", 8, -12)

    local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(80, 22)
    addButton:SetText(L.ADD_BUTTON)
    addButton:SetPoint("LEFT", spellEditBox, "RIGHT", 8, 0)

    local spellbookButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    spellbookButton:SetSize(170, 22)
    spellbookButton:SetText(L.SPELLBOOK_BUTTON)
    spellbookButton:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
    spellbookButton:SetScript("OnClick", function()
        if addon.ToggleSpellPicker then
            addon.ToggleSpellPicker()
        end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "SelfBuffTrackerOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", spellEditBox, "BOTTOMLEFT", -4, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 16)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local ROW_HEIGHT = 30

    local function RefreshSpellList()
        for _, row in ipairs(spellRows) do row:Hide() end

        local spells = {}
        for spell, enabled in pairs(SelfBuffTrackerDB.trackedSpells) do
            if enabled then table.insert(spells, spell) end
        end
        table.sort(spells)

        scrollChild:SetSize(scrollFrame:GetWidth(), math.max(#spells * ROW_HEIGHT, 1))

        for i, spell in ipairs(spells) do
            local displayName, iconTexture = addon.GetSpellDisplayNameAndIcon(spell)
            local row = spellRows[i]
            if not row then
                row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
                row:SetHeight(ROW_HEIGHT)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Buttons\\WHITE8X8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(1, 1, 1, 0.05)
                row:SetBackdropBorderColor(1, 1, 1, 0.08)
                row:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.12) end)
                row:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)

                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(22, 22)
                row.icon:SetPoint("LEFT", 6, 0)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                row.removeButton = CreateFrame("Button", nil, row)
                row.removeButton:SetSize(18, 18)
                row.removeButton:SetPoint("RIGHT", -8, 0)
                row.removeButton:SetNormalAtlas("common-icon-redx")
                row.removeButton:SetPushedAtlas("common-icon-redx")
                row.removeButton:SetHighlightAtlas("common-icon-redx", "ADD")

                row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.text:SetPoint("RIGHT", row.removeButton, "LEFT", -8, 0)
                row.text:SetJustifyH("LEFT")
                addon.ApplyFont(row.text, "highlight")

                spellRows[i] = row
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
            row:SetWidth(scrollFrame:GetWidth())
            row.icon:SetTexture(iconTexture)
            row.text:SetText(displayName)
            row.removeButton:SetScript("OnClick", function()
                SelfBuffTrackerDB.trackedSpells[spell] = nil
                addon.MigrateTrackedSpellsToIDs()
                addon.CheckBuffs(false)
                RefreshSpellList()
            end)
            row:Show()
        end
    end

    addButton:SetScript("OnClick", function()
        local text = strtrim(spellEditBox:GetText() or "")
        if text ~= "" then
            SelfBuffTrackerDB.trackedSpells[text] = true
            spellEditBox:SetText("")
            addon.MigrateTrackedSpellsToIDs()
            addon.CheckBuffs(false)
            RefreshSpellList()
        end
    end)
    spellEditBox:SetScript("OnEnterPressed", function(self)
        addButton:Click()
        self:ClearFocus()
    end)

    local function RefreshValues()
        RefreshCopyDropdown()
        RefreshSpellList()
    end

    panel:SetScript("OnShow", RefreshValues)
    addon.RefreshOptionsPanel = RefreshValues

    Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, panel.name)
    RefreshValues()
end

addon.CreateTrackedBuffsSubcategory = CreateTrackedBuffsSubcategory
