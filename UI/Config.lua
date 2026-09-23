-------------------------------------------------
-- ZaiiaPawn UI/Config.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

-------------------------------------------------
-- File-scope locals
-------------------------------------------------
local configFrame, title
local weightsFrame, weightsTitle
local setListScroll, setListChild
local setListRows = {}
local cmpCheckbox
local minimapBtn
local pendingDeleteSet = nil
local lastOpenedSet = nil

local scrollFrame, scrollChild
local editBoxes, orderedBoxes, createdFrames = {}, {}, {}

local ShowSetFilterDialog
local OpenWeightsWindow
local SyncCompareCheckbox

-------------------------------------------------
-- Semantic ordering for the Weights panel
-------------------------------------------------
local STAT_GROUP_ORDER = {
    STRENGTH = 1, AGILITY = 1, STAMINA = 1, INTELLECT = 1, SPIRIT = 1,
    HEALTH = 2, MANA = 2, ["HEALTH PER 5"] = 2, ["MANA PER 5"] = 2,
    ["CASTING REGEN"] = 2,
    ["ATTACK POWER"] = 3, ["RANGED ATTACK POWER"] = 3,
    ["FERAL ATTACK POWER"] = 3,
    ["SPELL POWER"] = 4, ["SPELL DAMAGE"] = 4, HEALING = 4,
    ["SHADOW DAMAGE"] = 5, ["FIRE DAMAGE"] = 5, ["FROST DAMAGE"] = 5,
    ["NATURE DAMAGE"] = 5, ["ARCANE DAMAGE"] = 5, ["HOLY DAMAGE"] = 5,
    HIT = 6, CRIT = 6, HASTE = 6,
    ["RANGED CRIT"] = 6, ["RANGED HASTE"] = 6,
    ["SPELL HIT"] = 6, ["SPELL CRIT"] = 6, ["HOLY CRIT"] = 6,
    ["SPELL PENETRATION"] = 6, ["ARMOR PENETRATION"] = 6,
    ARMOR = 7, DEFENSE = 7, DODGE = 7, PARRY = 7,
    BLOCK = 7, ["BLOCK VALUE"] = 7,
    ["ALL RESISTANCES"] = 8,
    ["FIRE RESISTANCE"] = 8, ["FROST RESISTANCE"] = 8,
    ["SHADOW RESISTANCE"] = 8, ["NATURE RESISTANCE"] = 8,
    ["ARCANE RESISTANCE"] = 8,
    ["EXTRA ATTACK"] = 9, LIFESTEAL = 9, FORTUNE = 9, AVOIDANCE = 9,
    ["MOVEMENT SPEED"] = 10, ["MOUNT SPEED"] = 10,
    ["ATTACK POWER UNDEAD"] = 11, ["SPELL DAMAGE UNDEAD"] = 11,
    ["WEAPON DAMAGE"] = 12, ["WEAPON SPEED"] = 12, DPS = 12,
    PROCS = 13, ["PROC DAMAGE"] = 13, ["PROC AOE"] = 13, ["PROC HEAL"] = 13,
    SWORDS = 14, AXES = 14, MACES = 14, DAGGERS = 14,
    ["FIST WEAPONS"] = 14, POLEARMS = 14, STAVES = 14,
    BOWS = 14, GUNS = 14, CROSSBOWS = 14, THROWN = 14, WANDS = 14,
    ["WEAPON TYPE 1H"] = 15, ["WEAPON TYPE 2H"] = 15,
    ["WEAPON TYPE SHIELD"] = 15, ["WEAPON TYPE OFFHAND"] = 15,
    ["WEAPON TYPE RANGED"] = 15,
}

local STAT_GROUP_HEADERS = {
    [2]  = "Resources",
    [3]  = "Attack Power",
    [4]  = "Spell Power & Healing",
    [5]  = "Spell Schools",
    [6]  = "Hit / Crit / Haste",
    [7]  = "Defense",
    [8]  = "Resistances",
    [9]  = "Special Effects",
    [10] = "Movement",
    [11] = "vs Undead",
    [12] = "Weapon Stats",
    [13] = "Procs",
    [14] = "Weapon Proficiency",
    [15] = "Weapon Type Preference",
}

local STAT_GROUP_HINTS = {
    [14] = "Flat weapon-skill bonus (\"+5 to Swords\"); weight only weapons you use.",
    [15] = "Score added to matching items (0 = ignore, + favours, - avoids).",
}

local function EstimateWrappedHeight(text, charsPerLine, lineHeight)
    if not text or text == "" then return 0 end
    charsPerLine = charsPerLine or 70
    lineHeight = lineHeight or 12
    local lines = math.ceil(string.len(text) / charsPerLine)
    return lines * lineHeight
end

local WEIGHT_HINTS = {
    ["WEAPON DAMAGE"]       = "per-hit damage (5..200); 2..5 is typical.",
    ["WEAPON SPEED"]        = "swing seconds (1.3..4.0); ~30..50x of WEAPON DAMAGE balances.",
    ["DPS"]                 = "tooltip DPS (0..100); melee 1..2, casters 0.",
    ["WEAPON TYPE 1H"]      = "matches 1H axes, swords, maces, daggers, fist weapons.",
    ["WEAPON TYPE 2H"]      = "matches 2H axes, swords, maces, polearms, staves.",
    ["WEAPON TYPE SHIELD"]  = "matches shields.",
    ["WEAPON TYPE OFFHAND"] = "matches off-hand weapons and Holdables.",
    ["WEAPON TYPE RANGED"]  = "matches bows, guns, crossbows, wands, thrown.",
    ["PROCS"]               = "proc count (0..3); +5..+15 is typical.",
    ["PROC DAMAGE"]         = "sum of avg proc damage; 0.3..0.5.",
    ["PROC AOE"]            = "area proc count; tanks +20..+40.",
    ["PROC HEAL"]           = "healing proc count; healers +10..+20.",
    ["ATTACK POWER UNDEAD"] = "bonus vs Undead; default 0.",
    ["SPELL DAMAGE UNDEAD"] = "spell bonus vs Undead; default 0.",
}

-------------------------------------------------
-- Minimap button
-------------------------------------------------
local function UpdateMinimapButtonPosition()
    if not minimapBtn then return end
    local pos = 200
    if ZaiiaPawnDB and ZaiiaPawnDB.minimapPos then
        pos = ZaiiaPawnDB.minimapPos
    end
    local rad = math.rad(pos)
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(rad) * 80, math.sin(rad) * 80)
end

local function CreateMinimapButton()
    if minimapBtn or not Minimap then return end

    local btn = CreateFrame("Button", "ZaiiaPawnMinimapBtn", Minimap)
    btn:SetWidth(31); btn:SetHeight(31)
    btn:SetFrameStrata("MEDIUM"); btn:SetFrameLevel(8)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(20); icon:SetHeight(20); icon:SetPoint("TOPLEFT", 6, -6)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_03")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53); overlay:SetHeight(53)
    overlay:SetPoint("TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn:SetScript("OnDragStart", function()
        this:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            mx, my = mx / scale, my / scale
            local angle = math.deg(math.atan2(my - cy, mx - cx))
            if angle < 0 then angle = angle + 360 end
            if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
            ZaiiaPawnDB.minimapPos = angle
            UpdateMinimapButtonPosition()
        end)
    end)
    btn:SetScript("OnDragStop", function()
        this:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            if ToggleConfigFrame then ToggleConfigFrame() end
        end
    end)
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:AddLine("ZaiiaPawn", 0, 1, 0)
        local cur = "none"
        if ZaiiaPawn.GetCurrentSet then
            cur = ZaiiaPawn.GetCurrentSet() or "none"
        end
        GameTooltip:AddLine("Editing: " .. cur, 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Left-click: Config", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    minimapBtn = btn
    UpdateMinimapButtonPosition()
end

CreateMinimapButton()

local mmDelay = CreateFrame("Frame")
mmDelay:RegisterEvent("PLAYER_ENTERING_WORLD")
mmDelay:SetScript("OnEvent", function()
    this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    CreateMinimapButton()
    UpdateMinimapButtonPosition()
end)

-------------------------------------------------
-- Main frame
-------------------------------------------------
configFrame = CreateFrame("Frame", "ZaiiaPawnConfigFrame", UIParent)
configFrame:SetWidth(500); configFrame:SetHeight(455)
configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
configFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
})
configFrame:SetFrameStrata("DIALOG")
configFrame:Hide()
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", function() this:StartMoving() end)
configFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
configFrame:SetScript("OnHide", function()
    if weightsFrame then weightsFrame:Hide() end
end)

title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", configFrame, "TOP", 0, -14)
title:SetText("ZaiiaPawn")

local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -4, -4)

tinsert(UISpecialFrames, "ZaiiaPawnConfigFrame")

local hint = configFrame:CreateFontString(nil, "OVERLAY",
    "GameFontHighlightLarge")
hint:SetPoint("TOP", title, "BOTTOM", 0, -2)
hint:SetWidth(460)
hint:SetJustifyH("LEFT")
hint:SetText("|cFFAAAAAA"
    .. "Left-click: edit weights.  Right-click: mark active (*).\n"
    .. "Checkbox: show in tooltips.  ^ / v: reorder sets."
    .. "|r")

-------------------------------------------------
-- Set list (left column, no scrollbar, mouse wheel)
--
-- Row geometry (shared with the right column):
--   CHECKBOX  24x24
--   NAME BUTTON 185x26
--   UP/DOWN BUTTONS 26x26
--   ROW STEP 30 (26 + 4 gap)
-------------------------------------------------
setListScroll = CreateFrame("ScrollFrame", "ZaiiaPawnSetListScroll", configFrame)
setListScroll:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 18, -83)
setListScroll:SetWidth(272); setListScroll:SetHeight(357)
setListScroll:EnableMouseWheel(true)
setListScroll:SetScript("OnMouseWheel", function()
    local cur = this:GetVerticalScroll() or 0
    local range = this:GetVerticalScrollRange() or 0
    if arg1 > 0 then
        this:SetVerticalScroll(math.max(0, cur - 30))
    else
        this:SetVerticalScroll(math.min(range, cur + 30))
    end
end)

setListChild = CreateFrame("Frame", nil, setListScroll)
setListChild:SetWidth(272); setListChild:SetHeight(600)
setListScroll:SetScrollChild(setListChild)

-------------------------------------------------
-- Command buttons (right column, grouped)
-------------------------------------------------
local rightX = 296
local rightW = 185
local rowStep = 30

local function MakeSetCmdButton(label, yOffset, onClick)
    local b = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    b:SetWidth(rightW); b:SetHeight(26)
    b:SetPoint("TOPLEFT", configFrame, "TOPLEFT", rightX, yOffset)
    b:SetText(label)
    b:SetScript("OnClick", onClick)
    return b
end

local function MakeGroupHeader(text, yOffset)
    local h = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Headers offset a bit right relative to the buttons.
    h:SetPoint("TOPLEFT", configFrame, "TOPLEFT", rightX + 12, yOffset)
    h:SetText("|cFFFFD700" .. text .. "|r")
    return h
end

-- ===== Set =====
MakeGroupHeader("Set", -66)

MakeSetCmdButton("New set (from current)", -85, function()
    local cur = ZaiiaPawn.GetCurrentSet()
    local base = cur and ZaiiaPawn.GetSetWeights(cur) or {}
    ZaiiaPawn.ShowTextPrompt("New set name:", "", function(name)
        if not name or name == "" then return end
        local ok, err = ZaiiaPawn.CreateSet(name, base)
        if ok then
            ZaiiaPawn.SetCurrentSet(name)
            ZaiiaPawn.RefreshSetList()
            if OpenWeightsWindow then OpenWeightsWindow() end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ZaiiaPawn: "
                .. tostring(err) .. "|r")
        end
    end)
end)

MakeSetCmdButton("New set (from preset)", -115, function()
    ZaiiaPawn.ShowSetTemplatePicker(function(displayName, weights, roleName, notUsable)
        if not displayName or displayName == "" then return end
        ZaiiaPawn.ShowTextPrompt("New set name:", displayName,
            function(name)
                if not name or name == "" then return end
                local ok, err
                if weights then
                    ok, err = ZaiiaPawn.CreateSet(name, weights, nil, notUsable)
                elseif roleName then
                    local class = ZaiiaPawn.GetClass()
                    local base = ZaiiaPawn.GetBaseWeights(class, roleName)
                    ok, err = ZaiiaPawn.CreateSet(name, base, class, notUsable)
                else
                    ok, err = false, "No weights source"
                end
                if ok then
                    ZaiiaPawn.SetCurrentSet(name)
                    ZaiiaPawn.RefreshSetList()
                    if OpenWeightsWindow then OpenWeightsWindow() end
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "|cFF00FF00ZaiiaPawn: created set '" .. name .. "'.|r")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ZaiiaPawn: "
                        .. tostring(err) .. "|r")
                end
            end)
    end)
end)

MakeSetCmdButton("Rename current set", -145, function()
    local cur = ZaiiaPawn.GetCurrentSet()
    if not cur then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: click a set name first.|r")
        return
    end
    ZaiiaPawn.ShowTextPrompt("Rename '" .. cur .. "' to:", cur, function(newName)
        if not newName or newName == "" or newName == cur then return end
        local ok, err = ZaiiaPawn.RenameSet(cur, newName)
        if not ok then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ZaiiaPawn: "
                .. tostring(err) .. "|r")
        else
            if weightsFrame and weightsFrame:IsShown() then
                weightsTitle:SetText("Weights - " .. newName)
                lastOpenedSet = newName
            end
        end
        ZaiiaPawn.RefreshSetList()
    end)
end)

MakeSetCmdButton("Duplicate current set", -175, function()
    local cur = ZaiiaPawn.GetCurrentSet()
    if not cur then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: click a set name first.|r")
        return
    end
    ZaiiaPawn.ShowTextPrompt("Duplicate '" .. cur .. "' as:", cur .. " copy",
        function(newName)
            if not newName or newName == "" then return end
            local set = ZaiiaPawn.GetSet(cur)
            local notUsable = set and set.notUsable or nil
            local ok, err = ZaiiaPawn.CreateSet(newName,
                ZaiiaPawn.GetSetWeights(cur), nil, notUsable)
            if ok then
                ZaiiaPawn.SetCurrentSet(newName)
                ZaiiaPawn.RefreshSetList()
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ZaiiaPawn: "
                    .. tostring(err) .. "|r")
            end
        end)
end)

MakeSetCmdButton("Delete current set", -205, function()
    local cur = ZaiiaPawn.GetCurrentSet()
    if not cur then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: click a set name first.|r")
        return
    end

    pendingDeleteSet = cur
    StaticPopupDialogs["ZAIIAPAWN_DELETE_CONFIRM"] =
        StaticPopupDialogs["ZAIIAPAWN_DELETE_CONFIRM"] or {
        text = "Delete set '%s'?\nThis cannot be undone.",
        button1 = "Delete",
        button2 = "Cancel",
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        OnAccept = function()
            local name = pendingDeleteSet
            pendingDeleteSet = nil
            if not name then return end
            if not ZaiiaPawn.GetSet(name) then return end

            ZaiiaPawn.DeleteSet(name)

            local nextSet = nil
            local active = ZaiiaPawn.GetActiveSets()
            if table.getn(active) > 0 then
                nextSet = active[1]
            else
                local names = ZaiiaPawn.GetAllSetNames()
                if table.getn(names) > 0 then nextSet = names[1] end
            end
            ZaiiaPawn.SetCurrentSet(nextSet)

            if nextSet then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cFF00FF00ZaiiaPawn: deleted '" .. name
                    .. "'. Current is now '" .. nextSet .. "'.|r")
            else
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cFF00FF00ZaiiaPawn: deleted '" .. name
                    .. "'. No sets remaining.|r")
                if weightsFrame then weightsFrame:Hide() end
            end

            ZaiiaPawn.RefreshSetList()
        end,
        OnCancel = function()
            pendingDeleteSet = nil
        end,
    }
    StaticPopup_Show("ZAIIAPAWN_DELETE_CONFIRM", cur)
end)

MakeSetCmdButton("Edit equipment filter", -235, function()
    local cur = ZaiiaPawn.GetCurrentSet()
    if not cur then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: click a set name first.|r")
        return
    end
    ShowSetFilterDialog(cur)
end)

-- ===== Global =====
MakeGroupHeader("Global", -269)

MakeSetCmdButton("Reset all sets to defaults", -288, function()
    StaticPopupDialogs["ZAIIAPAWN_RESET_CONFIRM"] =
        StaticPopupDialogs["ZAIIAPAWN_RESET_CONFIRM"] or {
        text = "Reset ALL ZaiiaPawn sets to class defaults?\nThis will delete every custom set.",
        button1 = "Reset",
        button2 = "Cancel",
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        OnAccept = function()
            if not ZaiiaPawnDB then return end
            ZaiiaPawnDB.sets = {}
            ZaiiaPawnDB.activeSets = {}
            ZaiiaPawnDB.currentSet = nil
            ZaiiaPawnDB.setOrder = {}
            ZaiiaPawnDB.seeded = false
            local class = ZaiiaPawn.GetClass()
            if class then ZaiiaPawn.SeedSetsFromDefaults(class) end
            ZaiiaPawnDB.seeded = true
            if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
            ZaiiaPawn.RefreshSetList()
            if weightsFrame then weightsFrame:Hide() end
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cFF00FF00ZaiiaPawn: all sets reset to defaults.|r")
        end,
    }
    StaticPopup_Show("ZAIIAPAWN_RESET_CONFIRM")
end)

MakeSetCmdButton("Share / Import weights", -318, function()
    if ToggleShareFrame then ToggleShareFrame() end
end)

-- ===== Options =====
MakeGroupHeader("Options", -352)

cmpCheckbox = CreateFrame("CheckButton", nil, configFrame,
    "UICheckButtonTemplate")
cmpCheckbox:SetWidth(24); cmpCheckbox:SetHeight(24)
cmpCheckbox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", rightX, -371)
cmpCheckbox:SetScript("OnClick", function()
    if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
    ZaiiaPawnDB.compareEnabled = this:GetChecked() and true or false
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
end)

local cmpLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cmpLabel:SetPoint("LEFT", cmpCheckbox, "RIGHT", 4, 0)
cmpLabel:SetText("Enable item comparison")

local cmpHint = configFrame:CreateFontString(nil, "OVERLAY",
    "GameFontNormalSmall")
cmpHint:SetPoint("TOPLEFT", cmpLabel, "BOTTOMLEFT", 0, -1)
cmpHint:SetText("|cFF888888Show +N/-N diff vs equipped item.|r")

MakeSetCmdButton("Advanced (soft caps)", -403, function()
    if ToggleAdvancedFrame then ToggleAdvancedFrame() end
end)

-------------------------------------------------
-- Weights frame (separate window, to the left)
-------------------------------------------------
weightsFrame = CreateFrame("Frame", "ZaiiaPawnWeightsFrame", UIParent)
weightsFrame:SetWidth(440); weightsFrame:SetHeight(540)
weightsFrame:SetPoint("TOPRIGHT", configFrame, "TOPLEFT", -8, 0)
weightsFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
})
weightsFrame:SetFrameStrata("DIALOG")
weightsFrame:Hide()
weightsFrame:EnableMouse(true)
weightsFrame:SetMovable(true)
weightsFrame:RegisterForDrag("LeftButton")
weightsFrame:SetScript("OnDragStart", function() this:StartMoving() end)
weightsFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
weightsFrame:SetScript("OnHide", function()
    lastOpenedSet = nil
end)

tinsert(UISpecialFrames, "ZaiiaPawnWeightsFrame")

weightsTitle = weightsFrame:CreateFontString(nil, "OVERLAY",
    "GameFontHighlightLarge")
weightsTitle:SetPoint("TOP", weightsFrame, "TOP", 0, -14)
weightsTitle:SetText("Weights")

local closeW = CreateFrame("Button", nil, weightsFrame, "UIPanelCloseButton")
closeW:SetPoint("TOPRIGHT", weightsFrame, "TOPRIGHT", -4, -4)

scrollFrame = CreateFrame("ScrollFrame", "ZaiiaPawnScrollFrame",
    weightsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", weightsFrame, "TOPLEFT", 16, -44)
scrollFrame:SetPoint("BOTTOMRIGHT", weightsFrame, "BOTTOMRIGHT", -36, 50)

scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetWidth(370); scrollChild:SetHeight(1600)
scrollFrame:SetScrollChild(scrollChild)

local saveBtn = CreateFrame("Button", nil, weightsFrame, "UIPanelButtonTemplate")
saveBtn:SetPoint("BOTTOM", weightsFrame, "BOTTOM", 0, 14)
saveBtn:SetWidth(180); saveBtn:SetHeight(28)
saveBtn:SetText("Save weights")
saveBtn:SetScript("OnClick", function()
    local set = ZaiiaPawn.GetCurrentSet()
    if not set then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: click a set name first.|r")
        return
    end
    local weights = {}
    local stat, box
    for stat, box in pairs(editBoxes) do
        weights[stat] = tonumber(box:GetText()) or 0
    end
    ZaiiaPawn.UpdateSetWeights(set, weights)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ZaiiaPawn: weights saved to '"
        .. set .. "'.|r")
end)

-------------------------------------------------
-- Set list rendering
--
-- All rows use the same vertical step (30).  Name button is
-- 185x26, matching the right-column buttons exactly.
-------------------------------------------------
local function MakeSetRow(setName, yPos)
    local row = CreateFrame("Frame", nil, setListChild)
    row:SetWidth(268); row:SetHeight(30)
    row:SetPoint("TOPLEFT", setListChild, "TOPLEFT", 0, yPos)

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetWidth(24); cb:SetHeight(24); cb:SetPoint("LEFT", 0, 0)
    cb:SetChecked(ZaiiaPawn.IsSetActive(setName) and 1 or 0)
    cb:SetScript("OnClick", function()
        ZaiiaPawn.ToggleActiveSet(setName)
    end)
    cb:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Show in tooltip", 1, 0.82, 0)
        GameTooltip:AddLine("When checked, this set appears on item "
            .. "tooltips and is scored on the character sheet.",
            0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local isCurrent = (setName == ZaiiaPawn.GetCurrentSet())
    local suffix = isCurrent and "  *" or ""

    local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    btn:SetWidth(185); btn:SetHeight(26)
    btn:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    btn:SetText(setName .. suffix)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function()
        if arg1 == "RightButton" then
            ZaiiaPawn.SetCurrentSet(setName)
            ZaiiaPawn.RefreshSetList()
        else
            if weightsFrame:IsShown() and lastOpenedSet == setName then
                weightsFrame:Hide()
            else
                ZaiiaPawn.SetCurrentSet(setName)
                if OpenWeightsWindow then OpenWeightsWindow() end
            end
        end
    end)
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine(setName, 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: edit weights "
            .. "(click again to close)", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click: mark as active (*)",
            0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local upBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    upBtn:SetWidth(26); upBtn:SetHeight(26)
    upBtn:SetPoint("LEFT", btn, "RIGHT", 2, 0)
    upBtn:SetText("^")
    upBtn:SetScript("OnClick", function()
        if ZaiiaPawn.MoveSetInOrder(setName, -1) then
            ZaiiaPawn.RefreshSetList()
        end
    end)

    local dnBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    dnBtn:SetWidth(26); dnBtn:SetHeight(26)
    dnBtn:SetPoint("LEFT", upBtn, "RIGHT", 2, 0)
    dnBtn:SetText("v")
    dnBtn:SetScript("OnClick", function()
        if ZaiiaPawn.MoveSetInOrder(setName, 1) then
            ZaiiaPawn.RefreshSetList()
        end
    end)

    table.insert(setListRows, row)
    table.insert(setListRows, cb)
    table.insert(setListRows, btn)
    table.insert(setListRows, upBtn)
    table.insert(setListRows, dnBtn)
end

function ZaiiaPawn.RefreshSetList()
    local i
    for i = 1, table.getn(setListRows) do
        local r = setListRows[i]
        if r then r:Hide(); r:SetParent(nil) end
    end
    setListRows = {}

    if not setListChild then return end

    local names = ZaiiaPawn.GetAllSetNames()
    local y = -2
    for i = 1, table.getn(names) do
        MakeSetRow(names[i], y)
        y = y - rowStep
    end

    setListChild:SetHeight(math.max(200, -y + 4))
end

-------------------------------------------------
-- Weights panel building
-------------------------------------------------
function ZaiiaPawn_WipeConfigUI()
    local i
    for i = 1, table.getn(createdFrames) do
        local f = createdFrames[i]
        if f then f:Hide(); f:SetParent(nil) end
    end
    createdFrames = {}; editBoxes = {}; orderedBoxes = {}
    if scrollChild then
        scrollChild:Hide(); scrollChild:SetParent(nil)
    end
    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(370); scrollChild:SetHeight(1600)
    scrollFrame:SetScrollChild(scrollChild)
end

function BuildEditBoxes()
    local set = ZaiiaPawn.GetCurrentSet()
    if not set then return end

    local weights = ZaiiaPawn.GetSetWeights(set)

    local allStats = {}
    local stat
    for stat in pairs(weights) do allStats[stat] = true end
    if defaultWeights then
        local _, classTable
        for _, classTable in pairs(defaultWeights) do
            if type(classTable) == "table" then
                local _, roleTable
                for _, roleTable in pairs(classTable) do
                    if type(roleTable) == "table" then
                        for stat in pairs(roleTable) do
                            allStats[stat] = true
                        end
                    end
                end
            end
        end
    end
    allStats["WEAPON DAMAGE"]       = true
    allStats["WEAPON SPEED"]        = true
    allStats["WEAPON TYPE 1H"]      = true
    allStats["WEAPON TYPE 2H"]      = true
    allStats["WEAPON TYPE SHIELD"]  = true
    allStats["WEAPON TYPE OFFHAND"] = true
    allStats["WEAPON TYPE RANGED"]  = true
    allStats["PROCS"]               = true
    allStats["PROC DAMAGE"]         = true
    allStats["PROC AOE"]            = true
    allStats["PROC HEAL"]           = true

    local stats = {}
    for stat in pairs(allStats) do table.insert(stats, stat) end
    table.sort(stats, function(a, b)
        local ga = STAT_GROUP_ORDER[a] or 99
        local gb = STAT_GROUP_ORDER[b] or 99
        if ga ~= gb then return ga < gb end
        return a < b
    end)

    local y = -10
    local lastGroup = nil
    local i
    for i = 1, table.getn(stats) do
        local s = stats[i]
        local group = STAT_GROUP_ORDER[s] or 99

        if group ~= lastGroup then
            local headerText = STAT_GROUP_HEADERS[group]
            if headerText then
                if lastGroup ~= nil then y = y - 6 end

                local header = scrollChild:CreateFontString(nil, "OVERLAY",
                    "GameFontNormal")
                header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, y)
                header:SetText("|cFFFFD700" .. headerText .. "|r")
                table.insert(createdFrames, header)
                y = y - 14

                local blockHint = STAT_GROUP_HINTS[group]
                if blockHint then
                    local bh = scrollChild:CreateFontString(nil, "OVERLAY",
                        "GameFontNormalSmall")
                    bh:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, y)
                    bh:SetWidth(360)
                    bh:SetJustifyH("LEFT")
                    bh:SetText("|cFFAAAAAA" .. blockHint .. "|r")
                    table.insert(createdFrames, bh)
                    y = y - EstimateWrappedHeight(blockHint, 60, 12) - 2
                end

                y = y - 2
            end
            lastGroup = group
        end

        local v = weights[s] or 0
        local hint = WEIGHT_HINTS[s]
        local rowH = hint and 44 or 28

        local box = CreateFrame("EditBox", nil, scrollChild)
        box:SetWidth(60); box:SetHeight(20); box:SetAutoFocus(false)
        box:SetFontObject("GameFontHighlight")
        box:SetText(tostring(v)); box:SetJustifyH("CENTER")
        box:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, y)
        box:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 12,
        })
        box:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        box:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
        box:SetScript("OnTextChanged", function()
            local t = this:GetText() or ""
            local clean = string.gsub(t, "[^0-9%.%-]", "")
            if clean ~= t then this:SetText(clean) end
        end)

        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", box, "RIGHT", 10, 0)
        label:SetText(s)

        editBoxes[s] = box
        table.insert(orderedBoxes, box)
        table.insert(createdFrames, box)
        table.insert(createdFrames, label)

        if hint then
            local h = scrollChild:CreateFontString(nil, "OVERLAY",
                "GameFontNormalSmall")
            h:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -2)
            h:SetText("|cFF888888" .. hint .. "|r")
            table.insert(createdFrames, h)
        end

        y = y - rowH
    end
    scrollChild:SetHeight(math.max(400, -y + 40))
end

-------------------------------------------------
-- Open weights window
-------------------------------------------------
OpenWeightsWindow = function()
    local set = ZaiiaPawn.GetCurrentSet()
    if not set then return end
    lastOpenedSet = set
    weightsTitle:SetText("Weights - " .. set)
    ZaiiaPawn_WipeConfigUI()
    BuildEditBoxes()
    weightsFrame:Show()
end

-------------------------------------------------
-- Sync
-------------------------------------------------
SyncCompareCheckbox = function()
    if cmpCheckbox then
        local v = ZaiiaPawnDB and ZaiiaPawnDB.compareEnabled ~= false
        cmpCheckbox:SetChecked(v and 1 or 0)
    end
end

-------------------------------------------------
-- Equipment filter dialog
-------------------------------------------------
local filterFrame

ShowSetFilterDialog = function(setName)
    if not setName or not ZaiiaPawn.GetSet(setName) then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFFFF9900ZaiiaPawn: no such set: " .. tostring(setName) .. "|r")
        return
    end

    if not filterFrame then
        filterFrame = CreateFrame("Frame", "ZaiiaPawnFilterFrame", UIParent)
        filterFrame:SetWidth(420); filterFrame:SetHeight(520)
        filterFrame:SetPoint("CENTER", 0, 40)
        filterFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
        })
        filterFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        filterFrame:EnableMouse(true)
        filterFrame:SetMovable(true)
        filterFrame:RegisterForDrag("LeftButton")
        filterFrame:SetScript("OnDragStart", function() this:StartMoving() end)
        filterFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        filterFrame:Hide()

        local t = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        t:SetPoint("TOP", 0, -14)
        filterFrame.title = t

        local hint = filterFrame:CreateFontString(nil, "OVERLAY",
            "GameFontNormalSmall")
        hint:SetPoint("TOP", t, "BOTTOM", 0, -4)
        hint:SetText("Checked types are ignored by this set (no score, no compare).")

        filterFrame.scroll = CreateFrame("ScrollFrame", "ZaiiaPawnFilterScroll",
            filterFrame, "UIPanelScrollFrameTemplate")
        filterFrame.scroll:SetPoint("TOPLEFT", filterFrame, "TOPLEFT", 16, -50)
        filterFrame.scroll:SetPoint("BOTTOMRIGHT", filterFrame,
            "BOTTOMRIGHT", -36, 50)
        filterFrame.child = CreateFrame("Frame", nil, filterFrame.scroll)
        filterFrame.child:SetWidth(360); filterFrame.child:SetHeight(600)
        filterFrame.scroll:SetScrollChild(filterFrame.child)

        filterFrame.checks = {}
        local options = {
            { category = "equipLoc", key = "INVTYPE_2HWEAPON",
              label = "Two-Hand (any 2H weapon)" },
            { category = "equipLoc", key = "INVTYPE_RANGED",
              label = "Ranged (bow/gun/crossbow)" },
            { category = "equipLoc", key = "INVTYPE_RANGEDRIGHT",
              label = "Wands" },
            { category = "equipLoc", key = "INVTYPE_THROWN",
              label = "Thrown weapons" },
            { category = "equipLoc", key = "INVTYPE_HOLDABLE",
              label = "Holdable (off-hand items)" },
            { category = "equipLoc", key = "INVTYPE_WEAPONOFFHAND",
              label = "Off-hand weapons" },

            { category = "subclass", classID = 2, key = 13, label = "Daggers" },
            { category = "subclass", classID = 2, key = 11, label = "Fist weapons" },
            { category = "subclass", classID = 2, key = 10, label = "Staves" },
            { category = "subclass", classID = 2, key = 6,  label = "Polearms" },
            { category = "subclass", classID = 2, key = 0,  label = "One-handed axes" },
            { category = "subclass", classID = 2, key = 1,  label = "Two-handed axes" },
            { category = "subclass", classID = 2, key = 7,  label = "One-handed swords" },
            { category = "subclass", classID = 2, key = 8,  label = "Two-handed swords" },
            { category = "subclass", classID = 2, key = 4,  label = "One-handed maces" },
            { category = "subclass", classID = 2, key = 5,  label = "Two-handed maces" },

            { category = "subclass", classID = 4, key = 6, label = "Shields" },
            { category = "subclass", classID = 4, key = 7, label = "Librams" },
            { category = "subclass", classID = 4, key = 8, label = "Idols" },
            { category = "subclass", classID = 4, key = 9, label = "Totems" },
        }
        local y = -4
        local i
        for i = 1, table.getn(options) do
            local opt = options[i]
            local cb = CreateFrame("CheckButton", nil, filterFrame.child,
                "UICheckButtonTemplate")
            cb:SetWidth(20); cb:SetHeight(20)
            cb:SetPoint("TOPLEFT", 4, y)
            cb.opts = opt
            local lbl = filterFrame.child:CreateFontString(nil, "OVERLAY",
                "GameFontNormalSmall")
            lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            lbl:SetText(opt.label)
            table.insert(filterFrame.checks, cb)
            y = y - 22
        end
        filterFrame.child:SetHeight(math.max(400, -y + 20))

        local saveBtn = CreateFrame("Button", nil, filterFrame,
            "UIPanelButtonTemplate")
        saveBtn:SetWidth(100); saveBtn:SetHeight(24)
        saveBtn:SetPoint("BOTTOMLEFT", 30, 14)
        saveBtn:SetText("Save")
        saveBtn:SetScript("OnClick", function()
            local nu = {}
            local i
            for i = 1, table.getn(filterFrame.checks) do
                local cb = filterFrame.checks[i]
                if cb:GetChecked() then
                    local opt = cb.opts
                    if opt.category == "equipLoc" then
                        nu.byEquipLoc = nu.byEquipLoc or {}
                        nu.byEquipLoc[opt.key] = true
                    elseif opt.category == "subclass" then
                        nu.byClassSubclass = nu.byClassSubclass or {}
                        nu.byClassSubclass[opt.classID] =
                            nu.byClassSubclass[opt.classID] or {}
                        nu.byClassSubclass[opt.classID][opt.key] = true
                    elseif opt.category == "classEquipLoc" then
                        nu.byClassEquipLoc = nu.byClassEquipLoc or {}
                        nu.byClassEquipLoc[opt.classID] =
                            nu.byClassEquipLoc[opt.classID] or {}
                        nu.byClassEquipLoc[opt.classID][opt.key] = true
                    end
                end
            end
            ZaiiaPawn.SetSetNotUsable(filterFrame.setName, nu)
            ZaiiaPawn.RefreshSetList()
            filterFrame:Hide()
        end)

        local clearBtn = CreateFrame("Button", nil, filterFrame,
            "UIPanelButtonTemplate")
        clearBtn:SetWidth(100); clearBtn:SetHeight(24)
        clearBtn:SetPoint("BOTTOM", 0, 14)
        clearBtn:SetText("Clear")
        clearBtn:SetScript("OnClick", function()
            local i
            for i = 1, table.getn(filterFrame.checks) do
                filterFrame.checks[i]:SetChecked(0)
            end
        end)

        local cancelBtn = CreateFrame("Button", nil, filterFrame,
            "UIPanelButtonTemplate")
        cancelBtn:SetWidth(100); cancelBtn:SetHeight(24)
        cancelBtn:SetPoint("BOTTOMRIGHT", -30, 14)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetScript("OnClick", function() filterFrame:Hide() end)
    end

    filterFrame.setName = setName
    filterFrame.title:SetText("Equipment filter: " .. setName)

    local nu = ZaiiaPawn.GetSetNotUsable(setName) or {}
    local nuEquipLoc = nu.byEquipLoc or {}
    local nuClassSubclass = nu.byClassSubclass or {}
    local nuClassEquipLoc = nu.byClassEquipLoc or {}

    local i
    for i = 1, table.getn(filterFrame.checks) do
        local cb = filterFrame.checks[i]
        local opt = cb.opts
        local checked = false
        if opt.category == "equipLoc" then
            if nuEquipLoc[opt.key] or nu[opt.key] then
                checked = true
            end
        elseif opt.category == "subclass" then
            if nuClassSubclass[opt.classID]
                and nuClassSubclass[opt.classID][opt.key] then
                checked = true
            end
        elseif opt.category == "classEquipLoc" then
            if nuClassEquipLoc[opt.classID]
                and nuClassEquipLoc[opt.classID][opt.key] then
                checked = true
            end
        end
        cb:SetChecked(checked and 1 or 0)
    end
    filterFrame:Show()
end

-------------------------------------------------
-- Template picker
-------------------------------------------------
local templateFrame

local function MakeTemplateButton(displayName, yPos, isCancel,
                                 actualName, weights, roleName, notUsable)
    local btn = CreateFrame("Button", nil, templateFrame, "UIPanelButtonTemplate")
    btn:SetWidth(300); btn:SetHeight(26)
    btn:SetPoint("TOP", templateFrame, "TOP", 0, yPos)
    btn:SetText(displayName)
    btn:SetScript("OnClick", function()
        templateFrame:Hide()
        if isCancel then return end
        if templateFrame.callback then
            templateFrame.callback(actualName, weights, roleName, notUsable)
        end
    end)
    table.insert(templateFrame.buttons, btn)
end

function ZaiiaPawn.ShowSetTemplatePicker(callback)
    if not templateFrame then
        templateFrame = CreateFrame("Frame", "ZaiiaPawnTemplatePicker", UIParent)
        templateFrame:SetWidth(340); templateFrame:SetHeight(500)
        templateFrame:SetPoint("CENTER", 20, 40)
        templateFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
        })
        templateFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        templateFrame:EnableMouse(true)
        templateFrame:SetMovable(true)
        templateFrame:RegisterForDrag("LeftButton")
        templateFrame:SetScript("OnDragStart", function() this:StartMoving() end)
        templateFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        local t = templateFrame:CreateFontString(nil, "OVERLAY",
            "GameFontHighlightLarge")
        t:SetPoint("TOP", templateFrame, "TOP", 0, -14)
        t:SetText("Choose preset")
        templateFrame.title = t
        templateFrame.buttons = {}
    end

    local i
    for i = 1, table.getn(templateFrame.buttons) do
        local b = templateFrame.buttons[i]
        if b then b:Hide(); b:SetParent(nil) end
    end
    templateFrame.buttons = {}
    templateFrame.callback = callback

    local class = ZaiiaPawn.GetClass()
    local roles = ZaiiaPawn.GetRolesForClass(class)
    local y = -50

    for i = 1, table.getn(roles) do
        local role = roles[i]
        local displayName = role .. " [OctoPawn]"
        local nu = nil
        if OctoPawnNotUsable and OctoPawnNotUsable[class] then
            nu = OctoPawnNotUsable[class][role]
        end
        MakeTemplateButton(displayName, y, false, displayName, nil, role, nu)
        y = y - 30
    end

    local presets = ZaiiaPawnPresets and ZaiiaPawnPresets[class] or {}
    for i = 1, table.getn(presets) do
        local p = presets[i]
        MakeTemplateButton(p.name, y, false, p.name, p.weights, nil, p.notUsable)
        y = y - 30
    end

    y = y - 6
    MakeTemplateButton("Cancel", y, true)
    y = y - 30

    templateFrame:SetHeight(math.min(700, math.max(200, -y + 30)))
    templateFrame:Show()
end

-------------------------------------------------
-- Text prompt
-------------------------------------------------
local promptFrame

function ZaiiaPawn.ShowTextPrompt(promptTitle, initial, onAccept)
    if not promptFrame then
        promptFrame = CreateFrame("Frame", "ZaiiaPawnPrompt", UIParent)
        promptFrame:SetWidth(360); promptFrame:SetHeight(150)
        promptFrame:SetPoint("CENTER", 0, 100)
        promptFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
        })
        promptFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        promptFrame:EnableMouse(true)
        promptFrame:SetMovable(true)
        promptFrame:RegisterForDrag("LeftButton")
        promptFrame:SetScript("OnDragStart", function() this:StartMoving() end)
        promptFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

        promptFrame.title = promptFrame:CreateFontString(nil, "OVERLAY",
            "GameFontNormal")
        promptFrame.title:SetPoint("TOP", 0, -16)

        promptFrame.edit = CreateFrame("EditBox", nil, promptFrame)
        promptFrame.edit:SetWidth(300); promptFrame.edit:SetHeight(24)
        promptFrame.edit:SetPoint("TOP", 0, -50)
        promptFrame.edit:SetAutoFocus(false)
        promptFrame.edit:SetFontObject("GameFontHighlight")
        promptFrame.edit:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 12,
        })
        promptFrame.edit:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        promptFrame.edit:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
        promptFrame.edit:SetTextInsets(6, 6, 6, 6)
        promptFrame.edit:SetScript("OnEscapePressed",
            function() promptFrame:Hide() end)
        promptFrame.edit:SetScript("OnEnterPressed", function()
            local cb = promptFrame.onAccept
            local text = promptFrame.edit:GetText()
            promptFrame:Hide()
            if cb then cb(text) end
        end)

        local okBtn = CreateFrame("Button", nil, promptFrame,
            "UIPanelButtonTemplate")
        okBtn:SetWidth(100); okBtn:SetHeight(24)
        okBtn:SetPoint("BOTTOMLEFT", 40, 16)
        okBtn:SetText("OK")
        okBtn:SetScript("OnClick", function()
            local cb = promptFrame.onAccept
            local text = promptFrame.edit:GetText()
            promptFrame:Hide()
            if cb then cb(text) end
        end)

        local cancelBtn = CreateFrame("Button", nil, promptFrame,
            "UIPanelButtonTemplate")
        cancelBtn:SetWidth(100); cancelBtn:SetHeight(24)
        cancelBtn:SetPoint("BOTTOMRIGHT", -40, 16)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetScript("OnClick", function() promptFrame:Hide() end)
    end

    promptFrame.title:SetText(promptTitle or "")
    promptFrame.edit:SetText(initial or "")
    promptFrame.onAccept = onAccept
    promptFrame:Show()
    promptFrame.edit:SetFocus()
    promptFrame.edit:HighlightText()
end

-------------------------------------------------
-- Toggle config
-------------------------------------------------
function ToggleConfigFrame()
    if not configFrame then return end
    if configFrame:IsShown() then
        configFrame:Hide()
        return
    end

    if not ZaiiaPawn.GetCurrentSet() then
        local names = ZaiiaPawn.GetAllSetNames()
        if table.getn(names) > 0 then
            ZaiiaPawn.SetCurrentSet(names[1])
        end
    end

    if ZaiiaPawn.RefreshSetList then ZaiiaPawn.RefreshSetList() end
    if SyncCompareCheckbox then SyncCompareCheckbox() end
    configFrame:Show()
end

function ZaiiaPawn_OnDBReady()
    if ZaiiaPawn.RefreshSetList then
        pcall(ZaiiaPawn.RefreshSetList)
    end
    if SyncCompareCheckbox then SyncCompareCheckbox() end
end