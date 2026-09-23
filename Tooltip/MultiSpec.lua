-------------------------------------------------
-- ZaiiaPawn Tooltip/MultiSpec.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

-- Resolve the list of set names to show on an item tooltip.
-- Order follows setOrder (display order from config).
-- Only sets with the checkbox enabled (IsSetActive) appear.
local function ResolveActiveSets()
    local out = {}
    local order = ZaiiaPawn.GetAllSetNames()
    local i
    for i = 1, table.getn(order) do
        if ZaiiaPawn.IsSetActive(order[i]) then
            table.insert(out, order[i])
        end
    end
    return out
end

function ZaiiaPawn.AddMultiRoleLines(tooltip)
    if tooltip.zpScored then return false end
    local class = ZaiiaPawn.GetClass()
    if not class then return false end

    -- Only score actual item tooltips.
    --
    -- tooltip.itemLink is our cached hint set by the Set* hooks
    -- in Tooltip/Handler.lua.  Spell / ability tooltips are
    -- shown via SetAction / SetSpell (not hooked), so the cached
    -- link can hold a stale value from a previously-shown item.
    -- GetItem() reads the tooltip's own state and returns nil
    -- for anything that is not an item — it is the authoritative
    -- source.
    local itemLink
    if tooltip.GetItem then
        local _, link = tooltip:GetItem()
        itemLink = link
    end
    if not itemLink then return false end

    local totals = ZaiiaPawn.GetTooltipTotals(tooltip)
    if not next(totals) then return false end

    local sets = ResolveActiveSets()
    if table.getn(sets) == 0 then return false end

    local renderable = {}
    local i
    for i = 1, table.getn(sets) do
        local name = sets[i]
        local set = ZaiiaPawn.GetSet(name)
        if set and next(set.weights or {}) ~= nil then
            if not ZaiiaPawn.IsEquipLocBlocked(itemLink, set.notUsable) then
                table.insert(renderable, name)
            end
        end
    end
    if table.getn(renderable) == 0 then return false end

    local currentSet = ZaiiaPawn.GetCurrentSet()
    local slots = ZaiiaPawn.GetCompareSlotsFromTooltip
        and ZaiiaPawn.GetCompareSlotsFromTooltip(tooltip)
    local compareOn = not (ZaiiaPawnDB and ZaiiaPawnDB.compareEnabled == false)

    tooltip:AddLine(" ")

    for i = 1, table.getn(renderable) do
        local name = renderable[i]
        local set = ZaiiaPawn.GetSet(name)
        local weights = ZaiiaPawn.GetSetWeights(name)
        local score = ZaiiaPawn.ScoreTooltip(tooltip, weights, name) or 0
        local line = string.format("%s: |cFFFFFFFF%.1f|r", name, score)

        if compareOn and slots then
            local eqList = ZaiiaPawn.EquippedScoresForSlots(
                slots, weights, name, set and set.notUsable)
            if eqList then
                local j
                for j = 1, table.getn(eqList) do
                    local eq = eqList[j]
                    local diff = ZaiiaPawn.FormatDiff(
                        score - eq.score, eq.score)
                    line = line .. " " .. diff
                        .. (eq.label and eq.label or "")
                end
            end
        end

        if currentSet == name then
            line = line .. " |cFF00FF00*|r"
        end
        tooltip:AddLine(line)
    end

    return true
end