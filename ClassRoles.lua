-------------------------------------------------
-- ZaiiaPawn Core/ClassRoles.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}
defaultWeights = defaultWeights or {}

-- Returns the player's class token (WARRIOR, MAGE, ...).
function ZaiiaPawn.GetClass()
    local _, class = UnitClass("player")
    return class
end

-- Returns list of role names available for the given class.
function ZaiiaPawn.GetRolesForClass(class)
    local classTable = defaultWeights and defaultWeights[class]
    if not classTable then return { "Default" } end
    local roles = {}
    for role in pairs(classTable) do table.insert(roles, role) end
    if table.getn(roles) == 0 then return { "Default" } end
    table.sort(roles)
    return roles
end

-- Returns base weights for a class+role, without overrides.
function ZaiiaPawn.GetBaseWeights(class, role)
    local classTable = defaultWeights and defaultWeights[class]
    if not classTable then return {} end
    local base = classTable[role] or classTable.Default
    if not base then
        for _, w in pairs(classTable) do base = w; break end
    end
    return base or {}
end

-- Returns default weights based on the current set, falling back to
-- the first default role of the player's class.
-- Used by ScoreTooltip when no explicit weights are passed.
function ZaiiaPawn.GetDefaultWeights()
    local cur = ZaiiaPawn.GetCurrentSet and ZaiiaPawn.GetCurrentSet()
    if cur then
        local w = ZaiiaPawn.GetSetWeights and ZaiiaPawn.GetSetWeights(cur)
        if w and next(w) ~= nil then return w end
    end
    local class = ZaiiaPawn.GetClass()
    local roles = ZaiiaPawn.GetRolesForClass(class)
    if table.getn(roles) > 0 then
        return ZaiiaPawn.GetBaseWeights(class, roles[1])
    end
    return {}
end