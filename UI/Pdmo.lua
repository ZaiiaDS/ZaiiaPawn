-------------------------------------------------
-- ZaiiaPawn UI/Pdmo.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local function ResolveTooltipUnit()
    if ZaiiaPawn.API and ZaiiaPawn.API.GetMouseoverPlayer then
        return ZaiiaPawn.API.GetMouseoverPlayer()
    end
    return nil
end

local function AddUnitOPScoreFromShow()
    if GameTooltip.zpUnitScored then return end
    if GameTooltip.zpScored then return end  -- item tooltip already handled

    local unit = ResolveTooltipUnit()
    if not unit or not UnitIsPlayer(unit) then return end

    -- collect sets to display
    local entries = {}
    local active = ZaiiaPawn.GetActiveSets()
    for _, name in ipairs(active) do
        if ZaiiaPawn.GetSet(name) then
            local w = ZaiiaPawn.GetSetWeights(name)
            if next(w) ~= nil then
                table.insert(entries, {
                    name = name,
                    weights = w,
                    notUsable = ZaiiaPawn.GetSetNotUsable(name),
                })
            end
        end
    end
    if table.getn(entries) == 0 then
        local cur = ZaiiaPawn.GetCurrentSet()
        if cur and ZaiiaPawn.GetSet(cur) then
            local w = ZaiiaPawn.GetSetWeights(cur)
            if next(w) ~= nil then
                entries = { {
                    name = cur,
                    weights = w,
                    notUsable = ZaiiaPawn.GetSetNotUsable(cur),
                } }
            end
        end
    end
    if table.getn(entries) == 0 then return end

    GameTooltip.zpUnitScored = true
    GameTooltip:AddLine(" ")
    for _, e in ipairs(entries) do
        local total
        if UnitIsUnit(unit, "player") then
            total = ZaiiaPawn.ScoreUnitEquipped(
                "player", e.weights, e.name, e.notUsable) or 0
        else
            total = ZaiiaPawn.ScoreUnitEquipped(
                unit, e.weights, e.name, e.notUsable) or 0
        end
        GameTooltip:AddLine(string.format("%s: %.1f", e.name, total))
    end
    GameTooltip:Show()
end

-- Chain onto GameTooltip's existing OnShow (may already be hooked
-- by Tooltip/Handler.lua and/or UI/Paperdoll.lua).
local oldShow = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function()
    if oldShow then oldShow() end
    pcall(AddUnitOPScoreFromShow)
end)

-- Ensure zpUnitScored is reset on hide (chain with existing OnHide).
local oldHide = GameTooltip:GetScript("OnHide")
GameTooltip:SetScript("OnHide", function()
    this.zpUnitScored = nil
    if oldHide then oldHide() end
end)