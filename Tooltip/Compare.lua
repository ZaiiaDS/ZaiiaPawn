-------------------------------------------------
-- ZaiiaPawn Tooltip/Compare.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local INV_SLOT_MAP = {}
local function AddSlot(key, slots)
    if key then INV_SLOT_MAP[key] = slots end
end
AddSlot(INVTYPE_HEAD, {1}); AddSlot(INVTYPE_NECK, {2})
AddSlot(INVTYPE_SHOULDER, {3}); AddSlot(INVTYPE_BODY, {4})
AddSlot(INVTYPE_CHEST, {5}); AddSlot(INVTYPE_ROBE, {5})
AddSlot(INVTYPE_WAIST, {6}); AddSlot(INVTYPE_LEGS, {7})
AddSlot(INVTYPE_FEET, {8}); AddSlot(INVTYPE_WRIST, {9})
AddSlot(INVTYPE_HAND, {10}); AddSlot(INVTYPE_FINGER, {11, 12})
AddSlot(INVTYPE_TRINKET, {13, 14}); AddSlot(INVTYPE_CLOAK, {15})
AddSlot(INVTYPE_WEAPON, {16, 17}); AddSlot(INVTYPE_WEAPONMAINHAND, {16})
AddSlot(INVTYPE_WEAPONOFFHAND, {17}); AddSlot(INVTYPE_2HWEAPON, {16, 17})
AddSlot(INVTYPE_SHIELD, {17}); AddSlot(INVTYPE_HOLDABLE, {17})
AddSlot(INVTYPE_RANGED, {18}); AddSlot(INVTYPE_RANGEDRIGHT, {18})
AddSlot(INVTYPE_THROWN, {18}); AddSlot(INVTYPE_RELIC, {18})
AddSlot(INVTYPE_TABARD, {19})

local ENGLISH_FALLBACK = {
    ["Head"]={1},["Neck"]={2},["Shoulder"]={3},["Shirt"]={4},["Chest"]={5},
    ["Waist"]={6},["Legs"]={7},["Feet"]={8},["Wrist"]={9},["Hands"]={10},
    ["Finger"]={11,12},["Trinket"]={13,14},["Back"]={15},["One-Hand"]={16,17},
    ["Main Hand"]={16},["Off Hand"]={17},["Two-Hand"]={16,17},
    ["Held In Off-hand"]={17},["Ranged"]={18},["Wand"]={18},["Thrown"]={18},
    ["Gun"]={18},["Bow"]={18},["Crossbow"]={18},["Relic"]={18},["Tabard"]={19},
}
for k, v in pairs(ENGLISH_FALLBACK) do
    if not INV_SLOT_MAP[k] then INV_SLOT_MAP[k] = v end
end

local SHORT_SLOT_LABEL = {
    [11]="1",[12]="2",[13]="1",[14]="2",[16]="MH",[17]="OH",
}

function ZaiiaPawn.GetCompareSlotsFromTooltip(tooltip)
    local num = tooltip:NumLines()
    local i
    for i = 1, num do
        local fs = getglobal(tooltip:GetName() .. "TextLeft" .. i)
        if fs then
            local t = fs:GetText()
            if t and INV_SLOT_MAP[t] then return INV_SLOT_MAP[t], t end
        end
    end
    return nil, nil
end

-- Formats a diff between two scores.  When `baseline` (the
-- equipped item's score) is provided and non-trivial, appends
-- a percentage: "(+2.1/+1.5%)".  Otherwise just "(+2.1)".
-- A baseline below 0.5 is treated as "no baseline" to avoid
-- runaway percentages on very low-level items.
--
-- Note on the percent formula: pct = (new - baseline) / baseline.
-- So +100% means the new item is twice as good as the equipped
-- one, +200% means three times as good, and so on.  This is the
-- standard "improvement relative to baseline" metric, not a
-- multiplier -- "x3" would correspond to "+200%".
function ZaiiaPawn.FormatDiff(diff, baseline)
    local color, numStr
    if diff > 0.05 then
        color = "|cFF00FF00"
        numStr = string.format("+%.1f", diff)
    elseif diff < -0.05 then
        color = "|cFFFF0000"
        numStr = string.format("%.1f", diff)
    else
        color = "|cFFAAAAAA"
        numStr = "+0.0"
    end

    if baseline and baseline > 0.5 then
        local pct = diff / baseline * 100
        local pctStr
        if pct > 0.05 then
            pctStr = string.format("+%.1f%%", pct)
        elseif pct < -0.05 then
            pctStr = string.format("%.1f%%", pct)
        else
            pctStr = "+0.0%"
        end
        return color .. "(" .. numStr .. "/" .. pctStr .. ")|r"
    end

    return color .. "(" .. numStr .. ")|r"
end

-- Returns list of { score, label, slot } for equipped items
-- in `slots`.  `notUsable` (optional) skips slots whose item
-- type is blocked by the set.
function ZaiiaPawn.EquippedScoresForSlots(slots, weights, roleName, notUsable)
    if not slots then return nil end
    local tip = ZaiiaPawn.GetScanTooltip()
    local list = {}
    local s
    for _, s in ipairs(slots) do
        local link = GetInventoryItemLink("player", s)
        if link then
            if not ZaiiaPawn.IsEquipLocBlocked(link, notUsable) then
                tip:SetOwner(UIParent, "ANCHOR_NONE")
                tip:ClearLines()
                tip.zpTotals = nil
                tip.zpScored = nil
                tip:SetInventoryItem("player", s)
                tip:Show()
                tip.itemLink = link
                local eqScore = ZaiiaPawn.ScoreTooltip(tip, weights, roleName)
                tip:Hide()
                local label = SHORT_SLOT_LABEL[s]
                table.insert(list, { score = eqScore or 0, label = label, slot = s })
            end
        end
    end
    if table.getn(list) == 0 then return nil end
    return list
end
