-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Priest.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 0,1,2,3,5,6,7,8,11,16
--   4: 2=Leather, 3=Mail, 4=Plate, 6=Shield
-------------------------------------------------
defaultWeights.PRIEST = defaultWeights.PRIEST or {}

defaultWeights.PRIEST.Discipline = OctoPawn_Healer({
    HEALING = 1.25, ["SPELL POWER"] = 0.75, ["SPELL DAMAGE"] = 0.45,
    SPIRIT = 1.15, INTELLECT = 1.15, ["SPELL CRIT"] = 1.35,
    STAVES = 0.1, WANDS = 0.12, MACES = 0.1
})
defaultWeights.PRIEST.Holy = OctoPawn_Healer({
    HEALING = 1.45, SPIRIT = 1.35, INTELLECT = 1.1,
    ["HOLY DAMAGE"] = 0.2, ["HOLY CRIT"] = 1.5,
    STAVES = 0.1, WANDS = 0.12, MACES = 0.1, DAGGERS = 0.05
})
defaultWeights.PRIEST.Shadow = OctoPawn_CasterDPS({
    ["SHADOW DAMAGE"] = 1.35, ["SPELL DAMAGE"] = 1.05,
    ["SPELL POWER"] = 1.05, SPIRIT = 0.85,
    ["SPELL DAMAGE UNDEAD"] = 0.55, HEALING = 0.15,
    STAVES = 0.1, WANDS = 0.15, DAGGERS = 0.05, MACES = 0.05
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local priestFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [4] = { [6]=true, [2]=true, [3]=true, [4]=true },
        [2] = { [0]=true, [1]=true, [2]=true, [3]=true,
                [5]=true, [6]=true, [7]=true, [8]=true,
                [11]=true, [16]=true },
    },
}
OctoPawnNotUsable["PRIEST"] = {
    Discipline = priestFilter,
    Holy       = priestFilter,
    Shadow     = priestFilter,
}