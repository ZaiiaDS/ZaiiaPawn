-------------------------------------------------
-- ZaiiaPawn Core/Utils.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

-------------------------------------------------
-- Table helpers
-------------------------------------------------
function ZaiiaPawn.CloneWeights(src)
    local t = {}
    for k, v in pairs(src or {}) do t[k] = v end
    return t
end

-------------------------------------------------
-- Number formatting
-------------------------------------------------
function ZaiiaPawn.TrimNum(n)
    if type(n) ~= "number" then return "0" end
    local s = string.format("%.4f", n)
    s = string.gsub(s, "0+$", "")
    s = string.gsub(s, "%.$", "")
    if s == "" or s == "-" or s == "-0" then s = "0" end
    return s
end

-------------------------------------------------
-- Pawn v1 stat token mapping (Classic Era 1.15.9)
-------------------------------------------------
ZaiiaPawn.PAWN_STAT_MAP = {
    -- Primary stats
    ["STRENGTH"]        = "Strength",
    ["AGILITY"]         = "Agility",
    ["STAMINA"]         = "Stamina",
    ["INTELLECT"]       = "Intellect",
    ["SPIRIT"]          = "Spirit",

    -- Power
    ["ATTACK POWER"]        = "AttackPower",
    ["RANGED ATTACK POWER"] = "RangedAttackPower",
    ["FERAL ATTACK POWER"]  = "FeralAttackPower",
    ["ATTACK POWER UNDEAD"] = "AttackPowerUndead",

    -- Spell
    ["SPELL POWER"]         = "SpellPower",
    ["SPELL DAMAGE"]        = "SpellDamage",
    ["HEALING"]             = "SpellHealing",
    ["SPELL HIT"]           = "SpellHitRating",
    ["SPELL CRIT"]          = "SpellCritRating",
    ["SPELL PENETRATION"]   = "SpellPenetration",
    ["SPELL DAMAGE UNDEAD"] = "SpellDamageUndead",
    ["SHADOW DAMAGE"]       = "ShadowSpellDamage",
    ["FIRE DAMAGE"]         = "FireSpellDamage",
    ["FROST DAMAGE"]        = "FrostSpellDamage",
    ["NATURE DAMAGE"]       = "NatureSpellDamage",
    ["ARCANE DAMAGE"]       = "ArcaneSpellDamage",
    ["HOLY DAMAGE"]         = "HolySpellDamage",

    -- Melee / ranged
    ["HIT"]                = "HitRating",
    ["CRIT"]               = "CritRating",
    ["RANGED CRIT"]        = "RangedCritRating",
    ["HOLY CRIT"]          = "SpellCritRating",
    ["DPS"]                = "WeaponDPS",
    ["HASTE"]              = "HasteRating",
    ["RANGED HASTE"]       = "RangedHasteRating",
    ["ARMOR PENETRATION"]  = "ArmorPenetration",
    ["EXTRA ATTACK"]       = "ExtraAttack",

    -- Defense
    ["ARMOR"]       = "Armor",
    ["DEFENSE"]     = "DefenseRating",
    ["DODGE"]       = "DodgeRating",
    ["PARRY"]       = "ParryRating",
    ["BLOCK"]       = "BlockRating",
    ["BLOCK VALUE"] = "BlockValue",

    -- Regeneration / pools
    ["MANA PER 5"]    = "ManaPer5",
    ["HEALTH PER 5"]  = "HealthPer5",
    ["CASTING REGEN"] = "SpellManaRegen",
    ["MANA"]          = "Mana",
    ["HEALTH"]        = "Health",

    -- Resistances
    ["ALL RESISTANCES"]   = "AllResist",
    ["FIRE RESISTANCE"]   = "FireResist",
    ["FROST RESISTANCE"]  = "FrostResist",
    ["NATURE RESISTANCE"] = "NatureResist",
    ["SHADOW RESISTANCE"] = "ShadowResist",
    ["ARCANE RESISTANCE"] = "ArcaneResist",

    -- Misc / Turtle-custom
    ["LIFESTEAL"]      = "Lifesteal",
    ["FORTUNE"]        = "Fortune",
    ["AVOIDANCE"]      = "Avoidance",
    ["MOVEMENT SPEED"] = "MovementSpeed",
    ["MOUNT SPEED"]    = "MountSpeed",
}

ZaiiaPawn.PAWN_STAT_MAP_REVERSE = {}
do
    for k, v in pairs(ZaiiaPawn.PAWN_STAT_MAP) do
        ZaiiaPawn.PAWN_STAT_MAP_REVERSE[v] = k
    end
end

