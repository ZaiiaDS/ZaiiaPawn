-------------------------------------------------
-- ZaiiaPawn Defaults/OctoPawn_Paladin.lua
-- Original OctoPawn paladin weights (unchanged).
-- Only addition: notUsable filters, same format
-- and key conventions as ZaiiaPawn presets.
-------------------------------------------------
defaultWeights.PALADIN = defaultWeights.PALADIN or {}

defaultWeights.PALADIN.Holy = OctoPawn_Healer({
    HEALING = 1.4, SPIRIT = 1.15, INTELLECT = 1.15,
    ["HOLY DAMAGE"] = 0.25, ["HOLY CRIT"] = 1.4, ["SPELL POWER"] = 0.5,
    MACES = 0.1, STAVES = 0.05
})
defaultWeights.PALADIN.Protection = OctoPawn_Tank({
    STRENGTH = 0.9, INTELLECT = 0.45, SPIRIT = 0.2, BLOCK = 2.35,
    ["BLOCK VALUE"] = 1.35, PARRY = 2.3, ["HOLY DAMAGE"] = 0.75,
    ["SPELL POWER"] = 0.4, ["SPELL DAMAGE"] = 0.35, ["SPELL CRIT"] = 0.5,
    ["SPELL HIT"] = 0.4, ["HOLY CRIT"] = 0.6, MANA = 0.06,
    ["MANA PER 5"] = 0.5, ["CASTING REGEN"] = 0.5,
    MACES = 0.25, SWORDS = 0.25, AXES = 0.15
})
defaultWeights.PALADIN.Retribution = OctoPawn_MeleeDPS({
    STRENGTH = 1.2, AGILITY = 0.7, INTELLECT = 0.35, SPIRIT = 0.15,
    CRIT = 2.15, HIT = 2.0, DPS = 1.4, ["HOLY DAMAGE"] = 0.85,
    ["HOLY CRIT"] = 1.6, ["SPELL POWER"] = 0.45, ["SPELL DAMAGE"] = 0.35,
    ["SPELL CRIT"] = 0.8, ["SPELL HIT"] = 0.6, MANA = 0.05,
    ["MANA PER 5"] = 0.35, ["CASTING REGEN"] = 0.4,
    AXES = 0.35, SWORDS = 0.45, MACES = 0.45, POLEARMS = 0.25
})

-------------------------------------------------
-- OctoPawn equipment filters (per role).
-- byEquipLoc keys = INVTYPE_* token strings.
-- byClassSubclass keys = numeric class/subclass IDs.
-------------------------------------------------
OctoPawnNotUsable = OctoPawnNotUsable or {}
OctoPawnNotUsable["PALADIN"] = {
    Holy = {
        byEquipLoc = {
            ["INVTYPE_RANGED"]        = true,
            ["INVTYPE_RANGEDRIGHT"]   = true,
            ["INVTYPE_THROWN"]        = true,
            ["INVTYPE_WEAPONOFFHAND"] = true,
        },
        byClassSubclass = {
            [2] = { [13] = true, [11] = true, [17] = true, [10] = true },
            [4] = { [8] = true, [9] = true },
        },
    },
    Protection = {
        byEquipLoc = {
            ["INVTYPE_2HWEAPON"]      = true,
            ["INVTYPE_RANGED"]        = true,
            ["INVTYPE_RANGEDRIGHT"]   = true,
            ["INVTYPE_THROWN"]        = true,
            ["INVTYPE_HOLDABLE"]      = true,
            ["INVTYPE_WEAPONOFFHAND"] = true,
        },
        byClassSubclass = {
            [2] = { [13] = true, [11] = true, [17] = true, [10] = true },
            [4] = { [8] = true, [9] = true },
        },
    },
    Retribution = {
        byEquipLoc = {
            ["INVTYPE_RANGED"]        = true,
            ["INVTYPE_RANGEDRIGHT"]   = true,
            ["INVTYPE_THROWN"]        = true,
            ["INVTYPE_WEAPONOFFHAND"] = true,
        },
        byClassSubclass = {
            [2] = { [13] = true, [11] = true, [17] = true, [10] = true },
            [4] = { [8] = true, [9] = true },
        },
    },
}