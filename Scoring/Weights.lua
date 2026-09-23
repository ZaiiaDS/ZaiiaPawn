-------------------------------------------------
-- ZaiiaPawn Scoring/Weights.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local DEFAULT_DR = {
    HIT                 = { softCap = 6,  postScale = 0.35 },
    ["SPELL HIT"]       = { softCap = 10, postScale = 0.30 },
    CRIT                = { softCap = 25, postScale = 0.40 },
    ["SPELL CRIT"]      = { softCap = 25, postScale = 0.40 },
    ["RANGED CRIT"]     = { softCap = 25, postScale = 0.40 },
    ["HOLY CRIT"]       = { softCap = 25, postScale = 0.40 },
    DEFENSE             = { softCap = 25, postScale = 0.35 },
    DODGE               = { softCap = 25, postScale = 0.40 },
    PARRY               = { softCap = 20, postScale = 0.40 },
    BLOCK               = { softCap = 25, postScale = 0.40 },
    HASTE               = { softCap = 20, postScale = 0.45 },
    ["RANGED HASTE"]    = { softCap = 20, postScale = 0.45 },
    ["SPELL PENETRATION"] = { softCap = 20, postScale = 0.40 },
    ["ARMOR PENETRATION"] = { softCap = 30, postScale = 0.45 },
}

function ZaiiaPawn.GetDefaultDR() return DEFAULT_DR end

function ZaiiaPawn.GetDR(stat)
    if ZaiiaPawnDB and ZaiiaPawnDB.dr and ZaiiaPawnDB.dr[stat] then
        local d = ZaiiaPawnDB.dr[stat]
        if d.softCap ~= nil and tonumber(d.softCap) == 0 then return nil end
        return d
    end
    return DEFAULT_DR[stat]
end

function ZaiiaPawn.EffectiveValue(stat, value)
    if not value then return 0 end
    local dr = ZaiiaPawn.GetDR(stat)
    if not dr or not dr.softCap then return value end
    local soft = tonumber(dr.softCap) or 0
    if soft <= 0 then return value end
    local post = tonumber(dr.postScale) or 0.5
    if value <= soft then return value end
    return soft + (value - soft) * post
end

