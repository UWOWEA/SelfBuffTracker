local addonName, addon = ...
local L = addon.L or {}

addon.ALL_GAME_FLASKS = {
-- ========================================================================
    -- 1. THE WAR WITHIN (11.x)
    -- ========================================================================
    -- Bojové Flasky (TWW)
    { spellID = 432021, name = "Flask of Alchemical Chaos", category = "TWW Combat" },
    { spellID = 431972, name = "Flask of Tempered Swiftness", category = "TWW Combat" },
    { spellID = 431973, name = "Flask of Tempered Versatility", category = "TWW Combat" },
    { spellID = 431974, name = "Flask of Tempered Mastery", category = "TWW Combat" },
    { spellID = 431971, name = "Flask of Tempered Aggression", category = "TWW Combat" },
    { spellID = 432473, name = "Flask of Saving Graces", category = "TWW Combat" },

    -- PvP Flasky (TWW)
    { spellID = 432430, name = "Vicious Flask of Honor", category = "TWW PvP" },
    { spellID = 432403, name = "Vicious Flask of Classical Spirits", category = "TWW PvP" },
    { spellID = 432497, name = "Vicious Flask of Manifested Fury", category = "TWW PvP" },
    { spellID = 432452, name = "Vicious Flask of the Wrecking Ball", category = "TWW PvP" },

    -- Profesní Phialy (TWW)
    { spellID = 432265, name = "Phial of Truesight", category = "TWW Crafting" },
    { spellID = 432306, name = "Phial of Concentrated Ingenuity", category = "TWW Crafting" },
    { spellID = 432304, name = "Phial of Enhanced Ambidexterity", category = "TWW Crafting" },
    { spellID = 432286, name = "Phial of Bountiful Seasons", category = "TWW Crafting" },

    -- ========================================================================
    -- 2. DRAGONFLIGHT (10.x)
    -- ========================================================================
    -- Bojové Phialy (DF)
    { spellID = 371339, name = "Phial of Elemental Chaos", category = "Dragonflight" },
    { spellID = 371320, name = "Phial of the Eye in the Storm", category = "Dragonflight" },
    { spellID = 371387, name = "Phial of Charged Isolation", category = "Dragonflight" },
    { spellID = 371334, name = "Phial of Static Empowerment", category = "Dragonflight" },
    { spellID = 371340, name = "Phial of Glacial Fury", category = "Dragonflight" },
    { spellID = 371350, name = "Phial of Tepid Versatility", category = "Dragonflight" },
    { spellID = 371338, name = "Charged Phial of Alacrity", category = "Dragonflight" },
    { spellID = 371204, name = "Iced Phial of Corrupting Rage", category = "Dragonflight" },

    -- Profesní Phialy (DF)
    { spellID = 371089, name = "Aerated Phial of Deftness", category = "DF Crafting" },
    { spellID = 371024, name = "Steaming Phial of Finesse", category = "DF Crafting" },
    { spellID = 371172, name = "Crystalline Phial of Perception", category = "DF Crafting" },

    -- ========================================================================
    -- 3. SHADOWLANDS (9.x)
    -- ========================================================================
    { spellID = 307185, name = "Flask of Spectral Power", category = "Shadowlands" },
    { spellID = 307187, name = "Flask of the Stilled Stamina", category = "Shadowlands" },
    { spellID = 307161, name = "Eternal Cauldron", category = "Shadowlands" },

    -- ========================================================================
    -- 4. BATTLE FOR AZEROTH (8.x)
    -- ========================================================================
    { spellID = 298836, name = "Greater Flask of the Currents", category = "BfA" },
    { spellID = 298837, name = "Greater Flask of Endless Fathoms", category = "BfA" },
    { spellID = 298839, name = "Greater Flask of the Vast Horizon", category = "BfA" },
    { spellID = 298841, name = "Greater Flask of the Undertow", category = "BfA" },
    { spellID = 251836, name = "Flask of the Currents", category = "BfA" },
    { spellID = 251837, name = "Flask of Endless Fathoms", category = "BfA" },
    { spellID = 251838, name = "Flask of the Vast Horizon", category = "BfA" },
    { spellID = 251839, name = "Flask of the Undertow", category = "BfA" },

    -- ========================================================================
    -- 5. LEGION (7.x)
    -- ========================================================================
    { spellID = 188017, name = "Flask of the Whispered Pact", category = "Legion" },
    { spellID = 188018, name = "Flask of the Seventh Demon", category = "Legion" },
    { spellID = 188034, name = "Flask of the Countless Armies", category = "Legion" },
    { spellID = 188035, name = "Flask of Ten Thousand Scars", category = "Legion" },

    -- ========================================================================
    -- 6. WARLORDS OF DRAENOR (6.x)
    -- ========================================================================
    { spellID = 156064, name = "Greater Draenic Agility Flask", category = "WoD" },
    { spellID = 156070, name = "Greater Draenic Intellect Flask", category = "WoD" },
    { spellID = 156071, name = "Greater Draenic Strength Flask", category = "WoD" },
    { spellID = 156077, name = "Greater Draenic Stamina Flask", category = "WoD" },

    -- ========================================================================
    -- 7. MISTS OF PANDARIA (5.x)
    -- ========================================================================
    { spellID = 105689, name = "Flask of Spring Blossoms", category = "MoP" },
    { spellID = 105691, name = "Flask of the Warm Sun", category = "MoP" },
    { spellID = 105693, name = "Flask of Winter's Bite", category = "MoP" },
    { spellID = 105694, name = "Flask of Earth", category = "MoP" },
    { spellID = 105696, name = "Flask of Falling Leaves", category = "MoP" },

    -- ========================================================================
    -- 8. CATACLYSM (4.x) & WRATH OF THE LICH KING (3.x)
    -- ========================================================================
    { spellID = 79469, name = "Flask of Steelskin", category = "Cata" },
    { spellID = 79470, name = "Flask of the Draconic Mind", category = "Cata" },
    { spellID = 79471, name = "Flask of the Winds", category = "Cata" },
    { spellID = 79472, name = "Flask of Titanic Strength", category = "Cata" },
    { spellID = 53755, name = "Flask of the Frost Wyrm", category = "WotLK" },
    { spellID = 53758, name = "Flask of Stoneblood", category = "WotLK" },
    { spellID = 53760, name = "Flask of Endless Rage", category = "WotLK" },
    { spellID = 53752, name = "Flask of Pure Mojo", category = "WotLK" },

    -- ========================================================================
    -- 9. CLASSIC & TBC (1.x - 2.x)
    -- ========================================================================
    { spellID = 17627, name = "Flask of Distilled Wisdom", category = "Classic/TBC" },
    { spellID = 17626, name = "Flask of Supreme Power", category = "Classic/TBC" },
    { spellID = 17628, name = "Flask of the Titans", category = "Classic/TBC" },
    { spellID = 17629, name = "Flask of Chromatic Resistance", category = "Classic/TBC" },
    { spellID = 28518, name = "Flask of Relentless Assault", category = "TBC" },
    { spellID = 28519, name = "Flask of Mighty Restoration", category = "TBC" },
    { spellID = 28520, name = "Flask of Blinding Light", category = "TBC" },
    { spellID = 28521, name = "Flask of Pure Death", category = "TBC" },
}

for i = #addon.ALL_GAME_FLASKS, 1, -1 do
    local entry = addon.ALL_GAME_FLASKS[i]
    local spellInfo = C_Spell.GetSpellInfo(entry.spellID)
    if not spellInfo then
        table.remove(addon.ALL_GAME_FLASKS, i)
    end
end
local flaskPickerFrame

local function CreateFlaskPickerFrame()
    local frame = CreateFrame("Frame", "SelfBuffTrackerFlaskPickerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(380, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 6, 1)
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
        for i, entry in ipairs(addon.ALL_GAME_FLASKS) do
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

function addon.ToggleFlaskPicker()
    if not flaskPickerFrame then
        flaskPickerFrame = CreateFlaskPickerFrame()
    end

    if flaskPickerFrame:IsShown() then
        flaskPickerFrame:Hide()
    else
        flaskPickerFrame:Show()
    end
end