-------------------------------------------------
-- ZaiiaPawn Scoring/Engine.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local scoreCache = {}
local cacheSize = 0
local MAX_CACHE_ENTRIES = 500

function ZaiiaPawn_ClearScoreCache()
    scoreCache = {}
    cacheSize = 0
end

-------------------------------------------------
-- Equipment-type filter
--
-- `notUsable` may have:
--   byEquipLoc      -> { ["INVTYPE_X"] = true }
--   byClassSubclass -> { [classID] = { [subclassID] = true } }
--   byClassEquipLoc -> { [classID] = { ["INVTYPE_X"] = true } }
-- A legacy flat table { ["INVTYPE_X"] = true } is also honored.
--
-- equipLoc strings come from C_Item.GetItemInfo (9th return) or
-- from legacy GetItemInfo.  Both return INVTYPE_* tokens, so
-- plain string comparison is enough.
--
-- classID/subclassID come from C_Item.GetItemInfo (12th/13th).
-- Without ClassicAPI those are nil and only byEquipLoc works.
-------------------------------------------------
function ZaiiaPawn.IsEquipLocBlocked(link, notUsable)
    if not notUsable or not link then return false end
    local _, _, idStr = string.find(link, "item:(%d+)")
    if not idStr then return false end
    local id = tonumber(idStr)
    if not id then return false end

    local equipLoc, classID, subclassID

    -- Prefer ClassicAPI (full tuple, includes numeric IDs).
    if type(C_Item) == "table" and C_Item.GetItemInfo then
        local t = { C_Item.GetItemInfo(id) }
        equipLoc   = t[9]
        classID    = t[12]
        subclassID = t[13]
    end

    -- Fallback: legacy GetItemInfo.  The tuple layout varies
    -- between clients (some drop minLevel), so scan for the
    -- INVTYPE_* token instead of trusting a fixed position.
    if not equipLoc then
        local t = { GetItemInfo(id) }
        local i
        for i = 1, table.getn(t) do
            local v = t[i]
            if type(v) == "string" and string.find(v, "^INVTYPE_") then
                equipLoc = v
                break
            end
        end
    end
    if not equipLoc then return false end

    -- 1) equipLoc filter
    if type(notUsable.byEquipLoc) == "table"
        and notUsable.byEquipLoc[equipLoc] then
        return true
    end

    -- Legacy flat format (only when no new-format subtables exist).
    if not notUsable.byEquipLoc and not notUsable.byClassSubclass
        and not notUsable.byClassEquipLoc then
        if notUsable[equipLoc] then return true end
    end

    -- 2) class + subclass filter
    if classID and subclassID
        and type(notUsable.byClassSubclass) == "table" then
        local cs = notUsable.byClassSubclass[classID]
        if type(cs) == "table" and cs[subclassID] then
            return true
        end
    end

    -- 3) class + equipLoc filter
    if classID and type(notUsable.byClassEquipLoc) == "table" then
        local ce = notUsable.byClassEquipLoc[classID]
        if type(ce) == "table" and ce[equipLoc] then
            return true
        end
    end

    return false
end

-------------------------------------------------
-- Parsed totals are memoized per tooltip frame.
-------------------------------------------------
function ZaiiaPawn.GetTooltipTotals(tooltip)
    if tooltip.zpTotals == nil then
        tooltip.zpTotals = ZaiiaPawn.ParseTooltip(tooltip)
    end
    return tooltip.zpTotals
end

local function CacheKey(itemLink, roleName)
    return (itemLink or "?") .. "|" .. (roleName or "default")
end

function ZaiiaPawn.ScoreTooltip(tooltip, weights, roleName)
    if not weights then
        weights = ZaiiaPawn.GetDefaultWeights()
    end

    local itemLink = tooltip.itemLink
    local key
    if itemLink then
        key = CacheKey(itemLink, roleName)
        if scoreCache[key] then
            return scoreCache[key].score, scoreCache[key].results
        end
    end

    local totals = ZaiiaPawn.GetTooltipTotals(tooltip)

    local results = {}
    local totalScore = 0
    local stat, value
    for stat, value in pairs(totals) do
        local weight = weights[stat] or 0
        if weight ~= 0 then
            local effective = ZaiiaPawn.EffectiveValue(stat, value)
            local contribution = effective * weight
            totalScore = totalScore + contribution
            table.insert(results, {
                stat = stat, value = value, effective = effective,
                weight = weight, score = contribution,
            })
        end
    end

    if key then
        if scoreCache[key] == nil then
            if cacheSize >= MAX_CACHE_ENTRIES then
                ZaiiaPawn_ClearScoreCache()
            end
            cacheSize = cacheSize + 1
        end
        scoreCache[key] = { score = totalScore, results = results }
    end
    return totalScore, results
end

local scanTooltip
function ZaiiaPawn.GetScanTooltip()
    if not scanTooltip then
        scanTooltip = CreateFrame("GameTooltip", "ZaiiaPawnScanTooltip",
            nil, "GameTooltipTemplate")
        scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
    return scanTooltip
end

function ZaiiaPawn.ScoreUnitEquipped(unit, weights, roleName, notUsable)
    if not unit or not UnitExists(unit) then return 0 end
    local tip = ZaiiaPawn.GetScanTooltip()
    local total = 0
    local slot
    for slot = 1, 19 do
        local link = GetInventoryItemLink(unit, slot)
        if link then
            if not ZaiiaPawn.IsEquipLocBlocked(link, notUsable) then
                tip:SetOwner(UIParent, "ANCHOR_NONE")
                tip:ClearLines()
                tip.zpTotals = nil
                tip.zpScored = nil
                tip:SetInventoryItem(unit, slot)
                tip:Show()
                tip.itemLink = link
                local score = ZaiiaPawn.ScoreTooltip(tip, weights, roleName)
                tip:Hide()
                if score then total = total + score end
            end
        end
    end
    return total
end

local ef = CreateFrame("Frame")
ef:RegisterEvent("UNIT_INVENTORY_CHANGED")
ef:SetScript("OnEvent", function()
    if arg1 == "player" then ZaiiaPawn_ClearScoreCache() end
end)