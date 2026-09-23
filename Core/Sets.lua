-------------------------------------------------
-- ZaiiaPawn Core/Sets.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

-- CloneWeights is defined in Core/Utils.lua.
local CloneWeights = ZaiiaPawn.CloneWeights or function(src)
    local t = {}
    for k, v in pairs(src or {}) do t[k] = v end
    return t
end

local function EnsureSetsTable()
    if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
    if type(ZaiiaPawnDB.sets) ~= "table" then ZaiiaPawnDB.sets = {} end
    if type(ZaiiaPawnDB.activeSets) ~= "table" then ZaiiaPawnDB.activeSets = {} end
    if type(ZaiiaPawnDB.inspectSet) ~= "table" then ZaiiaPawnDB.inspectSet = {} end
    if type(ZaiiaPawnDB.setOrder) ~= "table" then ZaiiaPawnDB.setOrder = {} end
end

-- Reconcile ZaiiaPawnDB.setOrder with the actual set of keys:
-- keep existing order, drop names no longer present, append missing
-- in alphabetical order.
local function EnsureOrder()
    if not ZaiiaPawnDB then return end
    local order = ZaiiaPawnDB.setOrder or {}
    local seen = {}
    local cleaned = {}
    local i, n
    for i = 1, table.getn(order) do
        n = order[i]
        if ZaiiaPawnDB.sets[n] and not seen[n] then
            table.insert(cleaned, n)
            seen[n] = true
        end
    end
    local extra = {}
    for name in pairs(ZaiiaPawnDB.sets) do
        if not seen[name] then
            table.insert(extra, name)
        end
    end
    table.sort(extra)
    for i = 1, table.getn(extra) do
        table.insert(cleaned, extra[i])
    end
    ZaiiaPawnDB.setOrder = cleaned
end

-------------------------------------------------
-- Queries
-------------------------------------------------
function ZaiiaPawn.GetAllSetNames()
    EnsureSetsTable()
    EnsureOrder()
    return ZaiiaPawnDB.setOrder
end

function ZaiiaPawn.GetSet(name)
    if not name then return nil end
    EnsureSetsTable()
    return ZaiiaPawnDB.sets[name]
end

function ZaiiaPawn.GetSetWeights(name)
    local s = ZaiiaPawn.GetSet(name)
    return s and s.weights or {}
end

function ZaiiaPawn.GetCurrentSet()
    EnsureSetsTable()
    return ZaiiaPawnDB.currentSet
end

function ZaiiaPawn.GetActiveSets()
    EnsureSetsTable()
    return ZaiiaPawnDB.activeSets
end

function ZaiiaPawn.IsSetActive(name)
    local active = ZaiiaPawn.GetActiveSets()
    local i
    for i = 1, table.getn(active) do
        if active[i] == name then return true end
    end
    return false
end

-------------------------------------------------
-- Equipment compatibility filter
-------------------------------------------------
function ZaiiaPawn.GetSetNotUsable(name)
    local s = ZaiiaPawn.GetSet(name)
    return s and s.notUsable or nil
end

function ZaiiaPawn.SetSetNotUsable(name, notUsable)
    local s = ZaiiaPawn.GetSet(name)
    if not s then return false end
    if notUsable and next(notUsable) == nil then
        s.notUsable = nil
    else
        s.notUsable = notUsable
    end
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true
end

-------------------------------------------------
-- Order manipulation
-------------------------------------------------
function ZaiiaPawn.MoveSetInOrder(name, delta)
    if not name or not delta or delta == 0 then return false end
    EnsureSetsTable()
    EnsureOrder()
    local order = ZaiiaPawnDB.setOrder
    local idx
    local i
    for i = 1, table.getn(order) do
        if order[i] == name then idx = i; break end
    end
    if not idx then return false end
    local newIdx = idx + delta
    if newIdx < 1 or newIdx > table.getn(order) then return false end
    order[idx], order[newIdx] = order[newIdx], order[idx]
    return true
end

-------------------------------------------------
-- Mutations
-------------------------------------------------
function ZaiiaPawn.CreateSet(newName, baseRoleOrWeights, class, notUsable)
    if not newName or newName == "" then return false, "Empty name" end
    EnsureSetsTable()
    if ZaiiaPawnDB.sets[newName] then return false, "Name exists" end

    class = class or ZaiiaPawn.GetClass()
    local weights, baseRole
    if type(baseRoleOrWeights) == "table" then
        weights = CloneWeights(baseRoleOrWeights)
    elseif type(baseRoleOrWeights) == "string" then
        baseRole = baseRoleOrWeights
        weights = CloneWeights(ZaiiaPawn.GetBaseWeights(class, baseRole))
    else
        weights = CloneWeights(ZaiiaPawn.GetBaseWeights(class, nil))
    end

    ZaiiaPawnDB.sets[newName] = {
        name = newName,
        baseRole = baseRole,
        weights = weights,
        notUsable = notUsable,
    }

    EnsureOrder()
    local order = ZaiiaPawnDB.setOrder
    local exists = false
    local i
    for i = 1, table.getn(order) do
        if order[i] == newName then exists = true; break end
    end
    if not exists then table.insert(order, newName) end

    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true, newName
end

function ZaiiaPawn.DeleteSet(name)
    EnsureSetsTable()
    if not name or not ZaiiaPawnDB.sets[name] then return false end
    ZaiiaPawnDB.sets[name] = nil

    local i
    for i = 1, table.getn(ZaiiaPawnDB.activeSets) do
        if ZaiiaPawnDB.activeSets[i] == name then
            table.remove(ZaiiaPawnDB.activeSets, i)
            break
        end
    end
    if ZaiiaPawnDB.currentSet == name then ZaiiaPawnDB.currentSet = nil end

    -- Remove from order
    local order = ZaiiaPawnDB.setOrder or {}
    for i = 1, table.getn(order) do
        if order[i] == name then
            table.remove(order, i)
            break
        end
    end

    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true
end

function ZaiiaPawn.RenameSet(oldName, newName)
    if not oldName or not newName or newName == "" then
        return false, "Bad args"
    end
    EnsureSetsTable()
    if not ZaiiaPawnDB.sets[oldName] then return false, "No such set" end
    if ZaiiaPawnDB.sets[newName] then return false, "Name exists" end

    local s = ZaiiaPawnDB.sets[oldName]
    s.name = newName
    ZaiiaPawnDB.sets[newName] = s
    ZaiiaPawnDB.sets[oldName] = nil

    local i
    for i = 1, table.getn(ZaiiaPawnDB.activeSets) do
        if ZaiiaPawnDB.activeSets[i] == oldName then
            ZaiiaPawnDB.activeSets[i] = newName
        end
    end
    if ZaiiaPawnDB.currentSet == oldName then
        ZaiiaPawnDB.currentSet = newName
    end

    -- Keep position in order (replace in place)
    local order = ZaiiaPawnDB.setOrder or {}
    for i = 1, table.getn(order) do
        if order[i] == oldName then order[i] = newName; break end
    end

    -- Update any per-class inspect set that pointed to oldName.
    if type(ZaiiaPawnDB.inspectSet) == "table" then
        local cls
        for cls, setName in pairs(ZaiiaPawnDB.inspectSet) do
            if setName == oldName then
                ZaiiaPawnDB.inspectSet[cls] = newName
            end
        end
    end

    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true
end

function ZaiiaPawn.UpdateSetWeights(name, weights)
    local s = ZaiiaPawn.GetSet(name)
    if not s then return false end
    s.weights = CloneWeights(weights)
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true
end

function ZaiiaPawn.SetCurrentSet(name)
    EnsureSetsTable()
    ZaiiaPawnDB.currentSet = name
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
end

function ZaiiaPawn.ToggleActiveSet(name)
    EnsureSetsTable()
    local active = ZaiiaPawnDB.activeSets
    local i
    for i = 1, table.getn(active) do
        if active[i] == name then
            table.remove(active, i)
            if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
            return false
        end
    end
    table.insert(active, name)
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
    return true
end

function ZaiiaPawn.SetActiveSets(names)
    if type(names) ~= "table" then return end
    EnsureSetsTable()
    ZaiiaPawnDB.activeSets = names
    if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
end

-------------------------------------------------
-- Seeding
-------------------------------------------------
function ZaiiaPawn.SeedSetsFromDefaults(class)
    if not class then return end
    EnsureSetsTable()

    local roles = ZaiiaPawn.GetRolesForClass(class)
    local i, role
    for i = 1, table.getn(roles) do
        role = roles[i]
        if not ZaiiaPawnDB.sets[role] then
            local base = ZaiiaPawn.GetBaseWeights(class, role)
            if next(base) ~= nil then
                -- Pull the OctoPawn filter for this role, if any.
                local nu = nil
                if OctoPawnNotUsable and OctoPawnNotUsable[class] then
                    nu = OctoPawnNotUsable[class][role]
                end
                ZaiiaPawnDB.sets[role] = {
                    name = role,
                    baseRole = role,
                    weights = CloneWeights(base),
                    notUsable = nu,
                }
            end
        end
    end

    EnsureOrder()

    if not ZaiiaPawnDB.currentSet then
        local names = ZaiiaPawn.GetAllSetNames()
        if table.getn(names) > 0 then
            ZaiiaPawnDB.currentSet = names[1]
        end
    end
    if table.getn(ZaiiaPawnDB.activeSets) == 0 then
        local names = ZaiiaPawn.GetAllSetNames()
        if table.getn(names) > 0 then
            ZaiiaPawnDB.activeSets = { names[1] }
        end
    end
end

-------------------------------------------------
-- Inspect (per-class)
-------------------------------------------------
function ZaiiaPawn.GetInspectSet(class)
    if not class then return nil end
    EnsureSetsTable()
    return ZaiiaPawnDB.inspectSet[class]
end

function ZaiiaPawn.SetInspectSet(class, name)
    if not class then return end
    EnsureSetsTable()
    ZaiiaPawnDB.inspectSet[class] = name
end