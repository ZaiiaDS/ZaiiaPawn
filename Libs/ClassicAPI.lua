-------------------------------------------------
-- ZaiiaPawn Libs/ClassicAPI.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}
ZaiiaPawn.API = ZaiiaPawn.API or {}

-- Feature detection: table + method exist
ZaiiaPawn.API.hasClassicAPI = (type(C_Item) == "table"
    and type(C_Item.GetItemInfoInstant) == "function")

-- Extract itemID from a link or numeric string.
-- Uses C_Item when available; falls back to string.find (Lua 5.0-safe).
function ZaiiaPawn.API.GetItemID(itemLinkOrID)
    if not itemLinkOrID then return nil end
    if type(itemLinkOrID) == "number" then return itemLinkOrID end
    if type(itemLinkOrID) ~= "string" then return nil end

    if ZaiiaPawn.API.hasClassicAPI then
        local id = C_Item.GetItemInfoInstant(itemLinkOrID)
        if id then return id end
    end

    -- Lua 5.0 compatible: string.find with capture (no string.match)
    local _, _, id = string.find(itemLinkOrID, "item:(%d+)")
    return tonumber(id)
end

-- Returns name, link, quality, ilvl (or nil if not cached).
function ZaiiaPawn.API.GetItemInfo(itemID)
    if not itemID then return nil end
    if ZaiiaPawn.API.hasClassicAPI and C_Item.GetItemInfo then
        local name, link, quality, ilvl = C_Item.GetItemInfo(itemID)
        if name then return name, link, quality, ilvl end
    end
    local name, link, quality, ilvl = GetItemInfo(itemID)
    return name, link, quality, ilvl
end

-- Async request to load item data.
function ZaiiaPawn.API.RequestItemData(itemID)
    if not itemID then return false end
    if ZaiiaPawn.API.hasClassicAPI and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemID)
        return true
    end
    if GetItemInfo then GetItemInfo(itemID) end
    return false
end

-- Spell info accessor.  Prefers C_Spell; falls back to legacy GetSpellInfo.
function ZaiiaPawn.API.GetSpellInfo(spellID)
    if not spellID then return nil end
    if type(C_Spell) == "table" and C_Spell.GetSpellInfo then
        local t = C_Spell.GetSpellInfo(spellID)
        if t then
            return t.name, t.rank, t.iconID, t.castTime, nil, t.powerType,
                   t.castTime, t.minRange, t.maxRange, t.spellID
        end
    end
    return GetSpellInfo(spellID)
end