-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Hunter.lua
-- Hunters can use: axes (1H/2H), swords (1H/2H),
-- polearms, staves, daggers, fist weapons, bows,
-- guns, crossbows, thrown.
-- Cannot use: maces (1H/2H), wands, shields,
-- holdables.
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 4=1H Mace, 5=2H Mace, 17=Wand
--   4: 6=Shield
-------------------------------------------------
defaultWeights.HUNTER = defaultWeights.HUNTER or {}

defaultWeights.HUNTER.BeastMastery = OctoPawn_MeleeDPS({
    STRENGTH = 0.25, AGILITY = 1.35, STAMINA = 0.5,
    ["RANGED ATTACK POWER"] = 1.25, ["ATTACK POWER"] = 0.45,
    ["RANGED CRIT"] = 2.15, ["RANGED HASTE"] = 1.9,
    CRIT = 1.7, HIT = 2.1, DPS = 1.25, HASTE = 1.5,
    BOWS = 0.55, GUNS = 0.55, CROSSBOWS = 0.55,
    AXES = 0.2, SWORDS = 0.2, DAGGERS = 0.15, POLEARMS = 0.15
})
defaultWeights.HUNTER.Marksmanship = OctoPawn_MeleeDPS({
    STRENGTH = 0.2, AGILITY = 1.4, STAMINA = 0.45,
    ["RANGED ATTACK POWER"] = 1.35, ["ATTACK POWER"] = 0.35,
    ["RANGED CRIT"] = 2.5, ["RANGED HASTE"] = 2.1,
    CRIT = 1.9, HIT = 2.25, DPS = 1.35, ["ARMOR PENETRATION"] = 0.9,
    BOWS = 0.6, GUNS = 0.6, CROSSBOWS = 0.6,
    AXES = 0.15, SWORDS = 0.15
})
defaultWeights.HUNTER.Survival = OctoPawn_MeleeDPS({
    STRENGTH = 0.3, AGILITY = 1.3, STAMINA = 0.55,
    ["RANGED ATTACK POWER"] = 1.15, ["ATTACK POWER"] = 0.5,
    ["RANGED CRIT"] = 2.0, ["RANGED HASTE"] = 1.8,
    CRIT = 1.8, HIT = 2.0, DPS = 1.2, HASTE = 1.7, LIFESTEAL = 1.2,
    BOWS = 0.5, GUNS = 0.5, CROSSBOWS = 0.5,
    AXES = 0.25, SWORDS = 0.25, POLEARMS = 0.2, DAGGERS = 0.2
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local hunterFilter = {
    byEquipLoc = { ["INVTYPE_HOLDABLE"] = true },
    byClassSubclass = {
        [4] = { [6]  = true },                       -- Shield
        [2] = { [17] = true, [4] = true, [5] = true },  -- Wand, 1H Mace, 2H Mace
    },
}
OctoPawnNotUsable["HUNTER"] = {
    BeastMastery = hunterFilter,
    Marksmanship = hunterFilter,
    Survival     = hunterFilter,
}