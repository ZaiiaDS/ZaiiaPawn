-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Shaman.lua
-- Numeric literals: 2 = Weapon, 4 = Armor.
--   2: 2=Bow, 3=Gun, 6=Polearm, 7=1H Sword, 8=2H Sword,
--      16=Crossbow, 17=Wand
--   4: 6=Shield
-------------------------------------------------
defaultWeights.SHAMAN = defaultWeights.SHAMAN or {}

defaultWeights.SHAMAN.Elemental = OctoPawn_CasterDPS({
    ["NATURE DAMAGE"] = 1.3, ["FIRE DAMAGE"] = 0.55, ["FROST DAMAGE"] = 0.25,
    ["SPELL DAMAGE"] = 1.05, ["SPELL POWER"] = 1.05,
    STAVES = 0.1, MACES = 0.12, DAGGERS = 0.05, AXES = 0.05
})
defaultWeights.SHAMAN.Enhancement = OctoPawn_MeleeDPS({
    STRENGTH = 1.05, AGILITY = 1.05, INTELLECT = 0.4, SPIRIT = 0.2,
    CRIT = 2.2, HIT = 2.1, HASTE = 2.1, DPS = 1.45,
    ["NATURE DAMAGE"] = 0.5, ["SPELL POWER"] = 0.4, ["SPELL DAMAGE"] = 0.35,
    ["SPELL CRIT"] = 0.7, ["SPELL HIT"] = 0.5, MANA = 0.05,
    ["MANA PER 5"] = 0.45, ["CASTING REGEN"] = 0.45,
    AXES = 0.5, MACES = 0.5, DAGGERS = 0.25, ["FIST WEAPONS"] = 0.25
})
defaultWeights.SHAMAN.EnhancementTank = OctoPawn_Tank({
    STRENGTH = 0.95, AGILITY = 0.95, STAMINA = 1.55, INTELLECT = 0.35,
    ARMOR = 0.02, DEFENSE = 2.3, DODGE = 2.4, PARRY = 2.2, BLOCK = 1.8,
    ["BLOCK VALUE"] = 1.0, ["ATTACK POWER"] = 0.55, HIT = 1.7, CRIT = 0.9,
    DPS = 0.6, HASTE = 0.8, ["NATURE DAMAGE"] = 0.55,
    ["SPELL POWER"] = 0.4, ["SPELL DAMAGE"] = 0.35,
    ["SPELL HIT"] = 0.5, ["SPELL CRIT"] = 0.4,
    MANA = 0.05, ["MANA PER 5"] = 0.55, ["CASTING REGEN"] = 0.5,
    AXES = 0.35, MACES = 0.4, DAGGERS = 0.2, ["FIST WEAPONS"] = 0.2,
    AVOIDANCE = 1.4
})
defaultWeights.SHAMAN.Restoration = OctoPawn_Healer({
    HEALING = 1.4, ["NATURE DAMAGE"] = 0.2, SPIRIT = 1.2,
    STAVES = 0.1, MACES = 0.12, DAGGERS = 0.05
})

-------------------------------------------------
-- Filters
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}

local shamanCasterFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [2] = { [7]=true, [8]=true, [6]=true,
                [2]=true, [3]=true, [16]=true, [17]=true },
    },
}
local shamanEnhFilter = {
    byEquipLoc = { ["INVTYPE_THROWN"] = true },
    byClassSubclass = {
        [4] = { [6]=true },   -- Shield (enh uses DW)
        [2] = { [7]=true, [8]=true, [6]=true,
                [2]=true, [3]=true, [16]=true, [17]=true },
    },
}
local shamanTankFilter = {
    byEquipLoc = {
        ["INVTYPE_2HWEAPON"] = true,
        ["INVTYPE_THROWN"]   = true,
    },
    byClassEquipLoc = {
        [2] = { ["INVTYPE_WEAPONOFFHAND"] = true },
    },
    byClassSubclass = {
        [2] = { [7]=true, [8]=true, [6]=true,
                [2]=true, [3]=true, [16]=true, [17]=true },
    },
}
OctoPawnNotUsable["SHAMAN"] = {
    Elemental       = shamanCasterFilter,
    Restoration     = shamanCasterFilter,
    Enhancement     = shamanEnhFilter,
    EnhancementTank = shamanTankFilter,
}