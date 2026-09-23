-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Warrior.lua
-- Numeric literals for class/subclass IDs so the file
-- does not depend on Core/Utils.lua load order.
--   2 = Weapon, 4 = Armor
--   Weapon subclasses: 17 = Wand
--   Armor subclasses:   6 = Shield
-------------------------------------------------
defaultWeights.WARRIOR = defaultWeights.WARRIOR or {}

defaultWeights.WARRIOR.Arms = OctoPawn_MeleeDPS({
    STRENGTH = 1.25, AGILITY = 0.75, CRIT = 2.35, HIT = 2.3,
    ["ARMOR PENETRATION"] = 1.35, HASTE = 1.7, DPS = 1.7,
    AXES = 0.55, SWORDS = 0.55, POLEARMS = 0.4, MACES = 0.25
})
defaultWeights.WARRIOR.Fury = OctoPawn_MeleeDPS({
    STRENGTH = 1.15, AGILITY = 1.05, CRIT = 2.5, HIT = 2.15,
    HASTE = 2.3, ["EXTRA ATTACK"] = 3.6, DPS = 1.55,
    AXES = 0.45, SWORDS = 0.45, DAGGERS = 0.25, MACES = 0.2
})
defaultWeights.WARRIOR.Protection = OctoPawn_Tank({
    STRENGTH = 0.95, AGILITY = 0.75, BLOCK = 2.3,
    ["BLOCK VALUE"] = 1.25, PARRY = 2.5, HIT = 1.7,
    ["ATTACK POWER"] = 0.5,
    AXES = 0.25, SWORDS = 0.35, MACES = 0.25
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
OctoPawnNotUsable["WARRIOR"] = {
    Arms = {
        byClassSubclass = {
            [4] = { [6] = true },   -- Shield
            [2] = { [17] = true },  -- Wand
        },
    },
    Fury = {
        byClassSubclass = {
            [4] = { [6] = true },
            [2] = { [17] = true },
        },
    },
    Protection = {
        byEquipLoc = {
            ["INVTYPE_2HWEAPON"] = true,
        },
        byClassEquipLoc = {
            [2] = { ["INVTYPE_WEAPONOFFHAND"] = true },
        },
        byClassSubclass = {
            [2] = { [17] = true },
        },
    },
}