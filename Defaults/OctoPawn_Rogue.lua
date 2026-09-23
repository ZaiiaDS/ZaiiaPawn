-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Rogue.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 0=1H Axe, 17=Wand
--   4: 6=Shield
-------------------------------------------------
defaultWeights.ROGUE = defaultWeights.ROGUE or {}

defaultWeights.ROGUE.Assassination = OctoPawn_MeleeDPS({
    STRENGTH = 0.55, AGILITY = 1.45, CRIT = 2.55, HIT = 2.35,
    ["ARMOR PENETRATION"] = 1.25, HASTE = 1.9, DPS = 1.5,
    DAGGERS = 0.75, SWORDS = 0.25, ["FIST WEAPONS"] = 0.2, MACES = 0.15
})
defaultWeights.ROGUE.Combat = OctoPawn_MeleeDPS({
    STRENGTH = 0.7, AGILITY = 1.35, CRIT = 2.35, HIT = 2.25,
    HASTE = 2.25, ["EXTRA ATTACK"] = 3.4, DPS = 1.65,
    ["ARMOR PENETRATION"] = 1.15,
    SWORDS = 0.55, AXES = 0.45, MACES = 0.35,
    DAGGERS = 0.35, ["FIST WEAPONS"] = 0.35
})
defaultWeights.ROGUE.Subtlety = OctoPawn_MeleeDPS({
    STRENGTH = 0.5, AGILITY = 1.4, CRIT = 2.3, HIT = 2.15,
    HASTE = 2.0, DPS = 1.45, LIFESTEAL = 1.6, FORTUNE = 1.15,
    DAGGERS = 0.65, SWORDS = 0.35, ["FIST WEAPONS"] = 0.25
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local rogueFilter = {
    byEquipLoc = {
        ["INVTYPE_2HWEAPON"] = true,
        ["INVTYPE_HOLDABLE"] = true,
    },
    byClassSubclass = {
        [4] = { [6]  = true },                -- Shield
        [2] = { [17] = true, [0] = true },    -- Wand, 1H Axe
    },
}
OctoPawnNotUsable["ROGUE"] = {
    Assassination = rogueFilter,
    Combat        = rogueFilter,
    Subtlety      = rogueFilter,
}