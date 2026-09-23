-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Druid.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 0,1,2,3,7,8,16,17
--   4: 3=Mail, 4=Plate, 6=Shield
-------------------------------------------------
defaultWeights.DRUID = defaultWeights.DRUID or {}

defaultWeights.DRUID.Balance = OctoPawn_CasterDPS({
    ["NATURE DAMAGE"] = 1.3, ["ARCANE DAMAGE"] = 0.95,
    ["SPELL DAMAGE"] = 1.05, ["SPELL POWER"] = 1.05, SPIRIT = 0.7,
    STAVES = 0.12, MACES = 0.1, DAGGERS = 0.05
})
defaultWeights.DRUID.FeralBear = OctoPawn_Tank({
    STRENGTH = 0.7, AGILITY = 0.95, STAMINA = 1.65, ARMOR = 0.025,
    ["FERAL ATTACK POWER"] = 0.65, ["ATTACK POWER"] = 0.55,
    DODGE = 2.7, DEFENSE = 2.3, PARRY = 0, BLOCK = 0, ["BLOCK VALUE"] = 0,
    DPS = 0.15
})
defaultWeights.DRUID.FeralCat = OctoPawn_MeleeDPS({
    STRENGTH = 0.85, AGILITY = 1.35, ["ATTACK POWER"] = 1.05,
    ["FERAL ATTACK POWER"] = 1.1, CRIT = 2.35, HIT = 2.15,
    ["ARMOR PENETRATION"] = 1.15, DPS = 0.25,
    STAVES = 0, MACES = 0.1, POLEARMS = 0.15
})
defaultWeights.DRUID.Restoration = OctoPawn_Healer({
    HEALING = 1.45, SPIRIT = 1.35, ["NATURE DAMAGE"] = 0.2,
    STAVES = 0.12, MACES = 0.1, DAGGERS = 0.05
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
local druidFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [4] = { [6]=true, [3]=true, [4]=true },
        [2] = { [0]=true, [1]=true, [2]=true, [3]=true,
                [7]=true, [8]=true, [16]=true, [17]=true },
    },
}
OctoPawnNotUsable["DRUID"] = {
    Balance     = druidFilter,
    FeralBear   = druidFilter,
    FeralCat    = druidFilter,
    Restoration = druidFilter,
}