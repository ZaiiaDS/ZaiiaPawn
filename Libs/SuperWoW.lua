-------------------------------------------------
-- ZaiiaPawn Libs/SuperWoW.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}
ZaiiaPawn.API = ZaiiaPawn.API or {}

-- SuperWoW detection — SuperWoW sets the global `SuperWoW` table.
ZaiiaPawn.API.hasSuperWoW = (type(SuperWoW) == "table")

-- Whether we can rely on mouseover token resolution.
ZaiiaPawn.API.hasMouseoverSupport = false
if ZaiiaPawn.API.hasSuperWoW then
    if SuperWoW.HasMouseoverSupport ~= nil then
        ZaiiaPawn.API.hasMouseoverSupport = SuperWoW.HasMouseoverSupport
    else
        -- Fallback: SuperWoW always provides mouseover to unit frames.
        ZaiiaPawn.API.hasMouseoverSupport = true
    end
end

-- Resolve current mouseover player unit (with fallback).
function ZaiiaPawn.API.GetMouseoverPlayer()
    if ZaiiaPawn.API.hasMouseoverSupport then
        if UnitExists("mouseover") and UnitIsPlayer("mouseover") then
            return "mouseover"
        end
        return nil
    end
    -- Legacy fallback: match tooltip name to known units.
    if not GameTooltipTextLeft1 then return nil end
    local tipName = GameTooltipTextLeft1:GetText()
    if not tipName then return nil end
    local function nameMatch(unit)
        if not UnitExists(unit) then return false end
        local n = UnitName(unit)
        local p = UnitPVPName and UnitPVPName(unit)
        return (n and n == tipName) or (p and p == tipName)
    end
    if nameMatch("player") then return "player" end
    if nameMatch("target") then return "target" end
    for i = 1, 4 do
        if nameMatch("party" .. i) then return "party" .. i end
    end
    return nil
end