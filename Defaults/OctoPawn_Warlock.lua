-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Warlock.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 0,1,2,3,4,5,6,8,11,16
--   4: 2=Leather, 3=Mail, 4=Plate, 6=Shield
-------------------------------------------------
defaultWeights.WARLOCK = defaultWeights.WARLOCK or {}

defaultWeights.WARLOCK.Affliction = OctoPawn_CasterDPS({
    ["SHADOW DAMAGE"] = 1.4, ["SPELL DAMAGE"] = 1.1, ["SPELL POWER"] = 1.1,
    ["SPELL HIT"] = 2.7, ["SPELL CRIT"] = 1.7,
    ["SPELL PENETRATION"] = 1.35, ["SPELL DAMAGE UNDEAD"] = 0.6,
    SPIRIT = 0.7, STAVES = 0.1, WANDS = 0.15, DAGGERS = 0.05, SWORDS = 0.05
})
defaultWeights.WARLOCK.Demonology = OctoPawn_CasterDPS({
    ["SHADOW DAMAGE"] = 1.15, ["FIRE DAMAGE"] = 0.9,
    ["SPELL DAMAGE"] = 1.05, ["SPELL POWER"] = 1.05,
    STAMINA = 0.55, INTELLECT = 1.1,
    ["SPELL HIT"] = 2.5, ["SPELL CRIT"] = 1.9,
    STAVES = 0.1, WANDS = 0.15, DAGGERS = 0.05, SWORDS = 0.05
})
defaultWeights.WARLOCK.Destruction = OctoPawn_CasterDPS({
    ["FIRE DAMAGE"] = 1.35, ["SHADOW DAMAGE"] = 0.9,
    ["SPELL DAMAGE"] = 1.1, ["SPELL POWER"] = 1.1,
    ["SPELL CRIT"] = 2.45, ["SPELL HIT"] = 2.5, HASTE = 1.7,
    STAVES = 0.1, WANDS = 0.15, DAGGERS = 0.05, SWORDS = 0.05
})

-------------------------------------------------
-- Filters (same shape as mage)
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local warlockFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [4] = { [6]=true, [2]=true, [3]=true, [4]=true },
        [2] = { [0]=true, [1]=true, [2]=true, [3]=true,
                [4]=true, [5]=true, [6]=true, [8]=true,
                [11]=true, [16]=true },
    },
}
OctoPawnNotUsable["WARLOCK"] = {
    Affliction = warlockFilter,
    Demonology = warlockFilter,
    Destruction = warlockFilter,
}