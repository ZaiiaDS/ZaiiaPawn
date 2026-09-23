-------------------------------------------------
-- ZaiiaPawn Scoring/Parser.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

ZaiiaPawn.StatPatterns = {
    { pattern = "DAMAGE AND HEALING DONE BY MAGICAL SPELLS", stat = "SPELL POWER" },
    { pattern = "DAMAGE AND HEALING DONE BY SPELLS",         stat = "SPELL POWER" },
    { pattern = "DAMAGE DONE BY SHADOW SPELLS",  stat = "SHADOW DAMAGE" },
    { pattern = "DAMAGE DONE BY FIRE SPELLS",    stat = "FIRE DAMAGE" },
    { pattern = "DAMAGE DONE BY FROST SPELLS",   stat = "FROST DAMAGE" },
    { pattern = "DAMAGE DONE BY NATURE SPELLS",  stat = "NATURE DAMAGE" },
    { pattern = "DAMAGE DONE BY ARCANE SPELLS",  stat = "ARCANE DAMAGE" },
    { pattern = "DAMAGE DONE BY HOLY SPELLS",    stat = "HOLY DAMAGE" },
    { pattern = "NATURE SPELL DAMAGE",  stat = "NATURE DAMAGE" },
    { pattern = "FIRE SPELL DAMAGE",    stat = "FIRE DAMAGE" },
    { pattern = "FROST SPELL DAMAGE",   stat = "FROST DAMAGE" },
    { pattern = "SHADOW SPELL DAMAGE",  stat = "SHADOW DAMAGE" },
    { pattern = "ARCANE SPELL DAMAGE",  stat = "ARCANE DAMAGE" },
    { pattern = "HOLY SPELL DAMAGE",    stat = "HOLY DAMAGE" },
    { pattern = "NATURE DAMAGE",        stat = "NATURE DAMAGE" },
    { pattern = "FIRE DAMAGE",          stat = "FIRE DAMAGE" },
    { pattern = "FROST DAMAGE",         stat = "FROST DAMAGE" },
    { pattern = "SHADOW DAMAGE",        stat = "SHADOW DAMAGE" },
    { pattern = "ARCANE DAMAGE",        stat = "ARCANE DAMAGE" },
    { pattern = "HOLY DAMAGE",          stat = "HOLY DAMAGE" },
    { pattern = "INCREASES HEALING DONE",        stat = "HEALING" },
    { pattern = "HEALING DONE BY SPELLS",        stat = "HEALING" },
    { pattern = "DAMAGE DEALT IS RETURNED AS HEALING", stat = "LIFESTEAL" },
    { pattern = "RETURNED AS HEALING",                 stat = "LIFESTEAL" },
    { pattern = "VAMPIRISM",                           stat = "LIFESTEAL" },
    { pattern = "VAMPIRIC",                            stat = "LIFESTEAL" },
    { pattern = "DECREASES THE MAGICAL RESISTANCES OF YOUR SPELL TARGETS",
        stat = "SPELL PENETRATION" },
    { pattern = "DECREASES THE MAGICAL RESISTANCES",  stat = "SPELL PENETRATION" },
    { pattern = "SPELL PENETRATION",                  stat = "SPELL PENETRATION" },
    { pattern = "YOUR ATTACKS IGNORE",                stat = "ARMOR PENETRATION" },
    { pattern = "IGNORE .* OF THE TARGET'S ARMOR",    stat = "ARMOR PENETRATION" },
    { pattern = "ARMOR PENETRATION",                  stat = "ARMOR PENETRATION" },
    { pattern = "INCREASES YOUR ATTACK AND CASTING SPEED", stat = "HASTE" },
    { pattern = "ATTACK AND CASTING SPEED",           stat = "HASTE" },
    { pattern = "INCREASES YOUR ATTACK SPEED",        stat = "HASTE" },
    { pattern = "INCREASES YOUR CASTING SPEED",       stat = "HASTE" },
    { pattern = "CHANCE TO GRANT .* EXTRA ATTACK",    stat = "EXTRA ATTACK" },
    { pattern = "GRANT .* EXTRA ATTACK",              stat = "EXTRA ATTACK" },
    { pattern = "EXTRA ATTACK",                       stat = "EXTRA ATTACK" },
    { pattern = "CHANCE TO TRIGGER CHANCE BASED ITEM EFFECTS", stat = "FORTUNE" },
    { pattern = "TRIGGER EFFECTS FROM EQUIPPED ITEMS",         stat = "FORTUNE" },
    { pattern = "TRIGGER CHANCE BASED ITEM EFFECTS",           stat = "FORTUNE" },
    { pattern = "INCREASES YOUR CHANCE TO TRIGGER",            stat = "FORTUNE" },
    { pattern = "DAMAGE YOU TAKE FROM AREA OF EFFECT", stat = "AVOIDANCE" },
    { pattern = "DAMAGE FROM AREA OF EFFECT",          stat = "AVOIDANCE" },
    { pattern = "AREA OF EFFECT ATTACKS BY",           stat = "AVOIDANCE" },
    { pattern = "AVOIDANCE",                           stat = "AVOIDANCE" },
    { pattern = "ATTACK POWER IN CAT, BEAR, DIRE BEAR, AND MOONKIN",
        stat = "FERAL ATTACK POWER" },
    { pattern = "ATTACK POWER IN CAT, BEAR",  stat = "FERAL ATTACK POWER" },
    { pattern = "ATTACK POWER IN CAT",        stat = "FERAL ATTACK POWER" },
    { pattern = "ATTACK POWER IN BEAR",       stat = "FERAL ATTACK POWER" },
    { pattern = "FERAL ATTACK POWER",         stat = "FERAL ATTACK POWER" },

    -- Situational damage vs Undead.  Must come BEFORE the generic
    -- ATTACK POWER / SPELL DAMAGE patterns below.
    { pattern = "ATTACK POWER WHEN FIGHTING UNDEAD", stat = "ATTACK POWER UNDEAD" },
    { pattern = "ATTACK POWER VS%.?%s*UNDEAD",        stat = "ATTACK POWER UNDEAD" },
    { pattern = "ATTACK POWER VERSUS UNDEAD",        stat = "ATTACK POWER UNDEAD" },
    { pattern = "ATTACK POWER AGAINST UNDEAD",       stat = "ATTACK POWER UNDEAD" },

    { pattern = "SPELL DAMAGE WHEN FIGHTING UNDEAD", stat = "SPELL DAMAGE UNDEAD" },
    { pattern = "SPELL DAMAGE VS%.?%s*UNDEAD",        stat = "SPELL DAMAGE UNDEAD" },
    { pattern = "SPELL DAMAGE VERSUS UNDEAD",        stat = "SPELL DAMAGE UNDEAD" },
    { pattern = "SPELL DAMAGE AGAINST UNDEAD",       stat = "SPELL DAMAGE UNDEAD" },
    { pattern = "DAMAGE TO UNDEAD",                  stat = "SPELL DAMAGE UNDEAD" },

    { pattern = "CHANCE TO HIT WITH SPELLS",  stat = "SPELL HIT" },
    { pattern = "HIT WITH SPELLS",            stat = "SPELL HIT" },
    { pattern = "SPELL HIT",                  stat = "SPELL HIT" },
    { pattern = "IMPROVES YOUR CHANCE TO HIT",stat = "HIT" },
    { pattern = "INCREASES YOUR CHANCE TO HIT", stat = "HIT" },
    { pattern = "INCREASE TO HIT",            stat = "HIT" },
    { pattern = "TO HIT BY",                  stat = "HIT" },
    { pattern = "CRITICAL STRIKE WITH SPELLS",stat = "SPELL CRIT" },
    { pattern = "CRITICAL STRIKE WITH HOLY",  stat = "HOLY CRIT" },
    { pattern = "CRITICAL STRIKE WITH RANGED",stat = "RANGED CRIT" },
    { pattern = "RANGED CRITICAL",            stat = "RANGED CRIT" },
    { pattern = "STRENGTH",  stat = "STRENGTH" },
    { pattern = "AGILITY",   stat = "AGILITY" },
    { pattern = "STAMINA",   stat = "STAMINA" },
    { pattern = "INTELLECT", stat = "INTELLECT" },
    { pattern = "SPIRIT",    stat = "SPIRIT" },
    { pattern = "RANGED ATTACK POWER", stat = "RANGED ATTACK POWER" },
    { pattern = "ATTACK POWER",        stat = "ATTACK POWER" },
    { pattern = "SPELL DAMAGE",        stat = "SPELL DAMAGE" },
    { pattern = "SPELL POWER",         stat = "SPELL POWER" },
    { pattern = "SPELL CRIT",          stat = "SPELL CRIT" },
    { pattern = "HEALTH PER 5",        stat = "HEALTH PER 5" },
    { pattern = "MANA PER 5",          stat = "MANA PER 5" },
    { pattern = "MANA REGENERATION TO CONTINUE WHILE CASTING", stat = "CASTING REGEN" },
    { pattern = "REGENERATION TO CONTINUE WHILE CASTING",      stat = "CASTING REGEN" },
    { pattern = "CONTINUE WHILE CASTING",                      stat = "CASTING REGEN" },
    { pattern = "WHILE CASTING",                               stat = "CASTING REGEN" },
    { pattern = "INCREASES HEALTH",   stat = "HEALTH" },
    { pattern = "HEALTH",             stat = "HEALTH" },
    { pattern = "INCREASES MANA",     stat = "MANA" },
    { pattern = "MANA",               stat = "MANA" },
    { pattern = "DAMAGE PER SECOND",  stat = "DPS" },
    { pattern = "DPS",                stat = "DPS" },
    { pattern = "CRIT",               stat = "CRIT" },
    { pattern = "DEFENSE",            stat = "DEFENSE" },
    { pattern = "DODGE",              stat = "DODGE" },
    { pattern = "PARRY",              stat = "PARRY" },
    { pattern = "BLOCK VALUE",        stat = "BLOCK VALUE" },
    { pattern = "BLOCK",              stat = "BLOCK" },
    { pattern = "REINFORCED ARMOR",   stat = "ARMOR" },
    { pattern = "ARMOR",              stat = "ARMOR" },
    { pattern = "TO ALL RESISTANCES", stat = "ALL RESISTANCES" },
    { pattern = "ALL RESISTANCES",    stat = "ALL RESISTANCES" },
    { pattern = "ALL RESISTANCE",     stat = "ALL RESISTANCES" },
    { pattern = "FIRE RESISTANCE",    stat = "FIRE RESISTANCE" },
    { pattern = "FROST RESISTANCE",   stat = "FROST RESISTANCE" },
    { pattern = "SHADOW RESISTANCE",  stat = "SHADOW RESISTANCE" },
    { pattern = "NATURE RESISTANCE",  stat = "NATURE RESISTANCE" },
    { pattern = "ARCANE RESISTANCE",  stat = "ARCANE RESISTANCE" },
    { pattern = "RANGED ATTACK SPEED",stat = "RANGED HASTE" },
    { pattern = "MOUNT SPEED",        stat = "MOUNT SPEED" },
    { pattern = "RUN SPEED",          stat = "MOVEMENT SPEED" },
    { pattern = "MOVEMENT SPEED",     stat = "MOVEMENT SPEED" },
    { pattern = "TO SWORDS",          stat = "SWORDS" },
    { pattern = "TO AXES",            stat = "AXES" },
    { pattern = "TO MACES",           stat = "MACES" },
    { pattern = "TO DAGGERS",         stat = "DAGGERS" },
    { pattern = "TO FIST WEAPONS",    stat = "FIST WEAPONS" },
    { pattern = "TO POLEARMS",        stat = "POLEARMS" },
    { pattern = "TO STAVES",          stat = "STAVES" },
    { pattern = "TO BOWS",            stat = "BOWS" },
    { pattern = "TO GUNS",            stat = "GUNS" },
    { pattern = "TO CROSSBOWS",       stat = "CROSSBOWS" },
    { pattern = "TO THROWN",          stat = "THROWN" },
    { pattern = "TO WANDS",           stat = "WANDS" },
}

-------------------------------------------------
-- Stats whose names are substrings of a more
-- specific variant.  If the specific one already
-- matched on the same tooltip line, the generic
-- one is suppressed to avoid double-counting.
--
-- Examples:
--   "+20 Ranged Attack Power" would otherwise add
--   RANGED ATTACK POWER + ATTACK POWER.
--   "+5 Block Value" adds BLOCK VALUE + BLOCK.
--   "Crit with spells" adds SPELL CRIT + CRIT.
-------------------------------------------------
local GENERIC_BLOCKED_BY = {
    ["ATTACK POWER"] = {
        "RANGED ATTACK POWER", "FERAL ATTACK POWER", "ATTACK POWER UNDEAD",
    },
    ["CRIT"]         = { "SPELL CRIT", "HOLY CRIT", "RANGED CRIT" },
    ["HIT"]          = { "SPELL HIT" },
    ["HASTE"]        = { "RANGED HASTE" },
    ["ARMOR"]        = { "ARMOR PENETRATION" },
    ["MANA"]         = { "MANA PER 5" },
    ["HEALTH"]       = { "HEALTH PER 5" },
    ["BLOCK"]        = { "BLOCK VALUE" },
    ["SPELL DAMAGE"] = {
        "SPELL DAMAGE UNDEAD",
        "SHADOW DAMAGE", "FIRE DAMAGE", "FROST DAMAGE",
        "NATURE DAMAGE", "ARCANE DAMAGE", "HOLY DAMAGE",
    },
    ["SPELL POWER"]  = {
        "SHADOW DAMAGE", "FIRE DAMAGE", "FROST DAMAGE",
        "NATURE DAMAGE", "ARCANE DAMAGE", "HOLY DAMAGE",
    },
}

-------------------------------------------------
-- Extract the numeric value that goes with a stat.
--
-- WoW tooltips almost always place the value BEFORE
-- the stat name ("+10 Strength", "Restores 5 mana
-- per 5 sec"), and some stat names themselves end
-- with a digit ("MANA PER 5").  We therefore:
--
--   1) prefer the LAST number BEFORE the pattern;
--   2) fall back to the FIRST number AFTER the pattern
--      ("Attack Power by 20").
--
-- This avoids picking up the trailing "5" of
-- "MANA PER 5" instead of the actual value.
-------------------------------------------------
function ZaiiaPawn.ExtractNumberNearStat(line, upper, pattern)
    local startPos = string.find(upper, pattern)
    if not startPos then return nil end

    local before = string.sub(line, 1, startPos - 1)
    local lastNum = nil
    for n in string.gfind(before, "([%+%-]?%d+%.?%d*)") do
        lastNum = n
    end
    if lastNum then return tonumber(lastNum) end

    local after = string.sub(line, startPos)
    local _, _, numAfter = string.find(after, "([%+%-]?%d+%.?%d*)")
    if numAfter then return tonumber(numAfter) end

    return nil
end

function ZaiiaPawn.IsSetBonusLine(upper)
    if string.find(upper, "%)%s*SET%s*:") then return true end
    if string.find(upper, "^SET%s*:") then return true end
    if string.find(upper, "SET BONUS") then return true end
    return false
end

local function IsBureaucraticLine(upper)
    if string.find(upper, "REQUIRES") then return true end
    if string.find(upper, "SOULBOUND") then return true end
    if string.find(upper, "UNIQUE") then return true end
    if string.find(upper, "LEVEL") then return true end
    if string.find(upper, "BIND") then return true end
    if string.find(upper, "MADE BY") then return true end
    return false
end

local function IsUseLine(upper)
    if string.find(upper, "^USE:") then return true end
    if string.find(upper, "^USE ") then return true end
    return false
end

local function IsTargetedLine(upper)
    if string.find(upper, "WHEN FIGHTING") then return true end
    if string.find(upper, "VERSUS")        then return true end
    if string.find(upper, "AGAINST")       then return true end
    if string.find(upper, "%sVS%.?%s")     then return true end
    return false
end

local function IsUndeadLine(upper)
    return string.find(upper, "UNDEAD") ~= nil
end

local function IsWeaponDamageLine(upper)
    return string.find(upper, "%d+%s*%-%s*%d+%s*DAMAGE") ~= nil
end

local function IsWeaponSpeedLine(upper)
    return string.find(upper, "^SPEED%s+[%d%.]+") ~= nil
end

local function ExtractWeaponStats(line, totals)
    local _, _, lo, hi, spd = string.find(line,
        "(%d+)%s*%-%s*(%d+)%s*Damage%s+Speed%s+([%d%.]+)")
    if lo then
        local avg = (tonumber(lo) + tonumber(hi)) / 2
        totals["WEAPON DAMAGE"] = (totals["WEAPON DAMAGE"] or 0) + avg
        totals["WEAPON SPEED"]  = (totals["WEAPON SPEED"] or 0)
            + (tonumber(spd) or 0)
        return
    end
    local _, _, lo2, hi2 = string.find(line, "(%d+)%s*%-%s*(%d+)%s*Damage")
    if lo2 then
        local avg = (tonumber(lo2) + tonumber(hi2)) / 2
        totals["WEAPON DAMAGE"] = (totals["WEAPON DAMAGE"] or 0) + avg
    end
end

local function ExtractWeaponSpeedOnly(line, totals)
    local _, _, spd = string.find(line, "^Speed%s+([%d%.]+)")
    if spd then
        totals["WEAPON SPEED"] = (totals["WEAPON SPEED"] or 0)
            + (tonumber(spd) or 0)
    end
end

local function IsProcLine(upper)
    return string.find(upper, "CHANCE ON HIT") ~= nil
end

local function ProcIsAoe(upper)
    if string.find(upper, "ALL ENEMIES") then return true end
    if string.find(upper, "NEARBY ENEMIES") then return true end
    if string.find(upper, "ENEMIES IN FRONT") then return true end
    if string.find(upper, "ALL TARGETS") then return true end
    if string.find(upper, "UP TO %d+ ENEMIES") then return true end
    if string.find(upper, "ENEMIES WITHIN") then return true end
    return false
end

local function ProcIsHeal(upper)
    if string.find(upper, "HEALS YOU") then return true end
    if string.find(upper, "HEALS THE") then return true end
    if string.find(upper, "RESTORES %d+ HEALTH") then return true end
    return false
end

local function ExtractProc(upper, totals)
    totals["PROCS"] = (totals["PROCS"] or 0) + 1

    local hasDamage = false
    local _, _, lo, hi = string.find(upper, "(%d+)%s+TO%s+(%d+)")
    if lo and hi then
        hasDamage = true
        totals["PROC DAMAGE"] = (totals["PROC DAMAGE"] or 0)
            + (tonumber(lo) + tonumber(hi)) / 2
    else
        local _, _, n = string.find(upper, "DEALS%s+(%d+)")
        if n then
            hasDamage = true
            totals["PROC DAMAGE"] = (totals["PROC DAMAGE"] or 0)
                + tonumber(n)
        end
    end

    if ProcIsAoe(upper) then
        totals["PROC AOE"] = (totals["PROC AOE"] or 0) + 1
    end
    if ProcIsHeal(upper) and not hasDamage then
        totals["PROC HEAL"] = (totals["PROC HEAL"] or 0) + 1
    end
end

local function DetectWeaponType(tooltip, totals)
    local link = tooltip.itemLink
    if not link then return end

    local _, _, idStr = string.find(link, "item:(%d+)")
    if not idStr then return end
    local id = tonumber(idStr)
    if not id then return end

    local equipLoc
    if type(C_Item) == "table" and C_Item.GetItemInfo then
        local t = { C_Item.GetItemInfo(id) }
        equipLoc = t[9]
    end
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
    if not equipLoc or equipLoc == "" then return end

    if equipLoc == "INVTYPE_2HWEAPON" then
        totals["WEAPON TYPE 2H"] = 1
    elseif equipLoc == "INVTYPE_WEAPON"
        or equipLoc == "INVTYPE_WEAPONMAINHAND" then
        totals["WEAPON TYPE 1H"] = 1
    elseif equipLoc == "INVTYPE_WEAPONOFFHAND"
        or equipLoc == "INVTYPE_HOLDABLE" then
        totals["WEAPON TYPE OFFHAND"] = 1
    elseif equipLoc == "INVTYPE_SHIELD" then
        totals["WEAPON TYPE SHIELD"] = 1
    elseif equipLoc == "INVTYPE_RANGED"
        or equipLoc == "INVTYPE_RANGEDRIGHT"
        or equipLoc == "INVTYPE_THROWN" then
        totals["WEAPON TYPE RANGED"] = 1
    end
end

-------------------------------------------------
-- Main parser
-------------------------------------------------
function ZaiiaPawn.ParseTooltip(tooltip)
    local patterns = ZaiiaPawn.StatPatterns
    local totals = {}
    local numLines = tooltip:NumLines()
    local i
    for i = 1, numLines do
        local lineObj = getglobal(tooltip:GetName() .. "TextLeft" .. i)
        if lineObj then
            local line = lineObj:GetText()
            if line then
                local upper = string.upper(line)
                if not ZaiiaPawn.IsSetBonusLine(upper)
                    and not IsBureaucraticLine(upper)
                    and not IsUseLine(upper) then

                    local isTargeted = IsTargetedLine(upper)
                    local allowUndeadOnly = isTargeted and IsUndeadLine(upper)
                    local skipAll = isTargeted and not allowUndeadOnly

                    if IsProcLine(upper) then
                        ExtractProc(upper, totals)
                    elseif IsWeaponDamageLine(upper) then
                        ExtractWeaponStats(line, totals)
                    elseif IsWeaponSpeedLine(upper) then
                        ExtractWeaponSpeedOnly(line, totals)
                    elseif not skipAll then
                        local matchedThisLine = {}
                        local _, entry
                        for _, entry in ipairs(patterns) do
                            if string.find(upper, entry.pattern)
                                and not matchedThisLine[entry.stat] then
                                local skip = false

                                if allowUndeadOnly
                                    and not string.find(entry.stat, "UNDEAD") then
                                    skip = true
                                end

                                if not skip
                                    and entry.stat == "HIT"
                                    and string.find(upper, "SPELL") then
                                    skip = true
                                end

                                -- Suppress generic stats when a more
                                -- specific variant already matched on
                                -- this same line.
                                if not skip then
                                    local blockers = GENERIC_BLOCKED_BY[entry.stat]
                                    if blockers then
                                        local k
                                        for k = 1, table.getn(blockers) do
                                            if matchedThisLine[blockers[k]] then
                                                skip = true
                                                break
                                            end
                                        end
                                    end
                                end

                                if not skip then
                                    local num = ZaiiaPawn.ExtractNumberNearStat(
                                        line, upper, entry.pattern)
                                    if not num then
                                        local _, _, captured = string.find(
                                            line, "([%+%-]?%d+%.?%d*)")
                                        if captured then
                                            num = tonumber(captured)
                                        end
                                    end
                                    if not num and entry.stat == "LIFESTEAL" then
                                        local _, _, captured =
                                            string.find(line, "([%+%-]?%d+)%s*%%")
                                        if captured then
                                            num = tonumber(captured)
                                        end
                                    end
                                    if num then
                                        matchedThisLine[entry.stat] = true
                                        totals[entry.stat] =
                                            (totals[entry.stat] or 0) + num
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    DetectWeaponType(tooltip, totals)

    return totals
end