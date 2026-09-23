-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Mage.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 0,1,2,3,4,5,6,8,11,16
--   4: 2=Leather, 3=Mail, 4=Plate, 6=Shield
-------------------------------------------------
defaultWeights.MAGE = defaultWeights.MAGE or {}

defaultWeights.MAGE.Arcane = OctoPawn_CasterDPS({
    ["ARCANE DAMAGE"] = 1.35, ["SPELL DAMAGE"] = 1.05,
    ["SPELL POWER"] = 1.05, INTELLECT = 1.15, SPIRIT = 0.5,
    ["SPELL CRIT"] = 2.2, ["SPELL HIT"] = 2.5,
    STAVES = 0.1, WANDS = 0.15, SWORDS = 0.05, DAGGERS = 0.05
})
defaultWeights.MAGE.Fire = OctoPawn_CasterDPS({
    ["FIRE DAMAGE"] = 1.4, ["SPELL DAMAGE"] = 1.05, ["SPELL POWER"] = 1.05,
    ["SPELL CRIT"] = 2.4, ["SPELL HIT"] = 2.4, HASTE = 1.5,
    STAVES = 0.1, WANDS = 0.15, SWORDS = 0.05, DAGGERS = 0.05
})
defaultWeights.MAGE.Frost = OctoPawn_CasterDPS({
    ["FROST DAMAGE"] = 1.4, ["SPELL DAMAGE"] = 1.05, ["SPELL POWER"] = 1.05,
    ["SPELL CRIT"] = 2.0, ["SPELL HIT"] = 2.7, ["SPELL PENETRATION"] = 1.4,
    STAVES = 0.1, WANDS = 0.15, SWORDS = 0.05, DAGGERS = 0.05
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local mageFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [4] = { [6]=true, [2]=true, [3]=true, [4]=true },
        [2] = { [0]=true, [1]=true, [2]=true, [3]=true,
                [4]=true, [5]=true, [6]=true, [8]=true,
                [11]=true, [16]=true },
    },
}
OctoPawnNotUsable["MAGE"] = {
    Arcane = mageFilter,
    Fire   = mageFilter,
    Frost  = mageFilter,
}