-------------------------------------------------
-- ZaiiaPawn Defaults/ZaiiaPawn_Druid.lua
-- Druid presets (Turtle WoW 1.18.1).
--
-- Turtle-specific mechanics:
--   * Feral Cat: 1 Str = 2 AP (2.4 with Heart of
--     the Wild), 1 Agi = 1 AP + crit/dodge.
--     STR gives more raw AP; AGI gives crit.
--   * Feral Bear: 1 Str = 2 AP, Agi = armor/
--     dodge/crit (no AP).  Stamina boosted by
--     Survival of the Fittest.
--   * Dire Bear Form: +450% armor from items.
--   * Balance: Nature's Splendor / Genesis boost
--     periodic damage; Eclipse procs.
--   * Restoration: Spirit-driven regen; Healing
--     Power is the primary scaling stat.
--
-- Weapon notes (Feral forms):
--   * Weapon procs are useless in Feral forms.
--   * Weapon speed/damage is irrelevant for Feral
--     ability damage (weapon skill is normalised).
--   * Only stat bonuses on weapons matter.
--
-- Druid restrictions:
--   * Cannot use Mail, Plate, Shields.
--   * Cannot use Axes, Swords, Crossbows, Wands.
--   * Cannot use Thrown.
--
-- notUsable.byEquipLoc keys are INVTYPE_* TOKEN strings.
-- notUsable.byClassSubclass keys are numeric classID/subclassID.
-------------------------------------------------
ZaiiaPawnPresets = ZaiiaPawnPresets or {}
ZaiiaPawnPresets["DRUID"] = {

    -------------------------------------------------
    -- Feral Cat (DPS)
    -------------------------------------------------
    {
        name = "FeralCat [ZaiiaPawn]",
        weights = {
            ["STRENGTH"]             = 1.0,
            ["AGILITY"]              = 1.35,
            ["STAMINA"]              = 0.4,
            ["ATTACK POWER"]         = 1.05,
            ["FERAL ATTACK POWER"]   = 1.1,
            ["CRIT"]                 = 2.35,
            ["HIT"]                  = 2.15,
            ["ARMOR PENETRATION"]    = 1.15,
            ["DPS"]                  = 0.25,
            ["HASTE"]                = 1.4,
            ["LIFESTEAL"]            = 1.0,
            ["FORTUNE"]              = 0.6,
            ["AVOIDANCE"]            = 0.3,
            ["MOVEMENT SPEED"]       = 0.2,
            ["STAVES"]               = 0.0,
            ["MACES"]                = 0.1,
            ["POLEARMS"]             = 0.15,
            ["DAGGERS"]              = 0.05,
            ["WEAPON DAMAGE"]        = 0.0,
            ["WEAPON SPEED"]         = 0.0,
        },
        notUsable = {
            byEquipLoc = { ["INVTYPE_THROWN"] = true },
            byClassSubclass = {
                [4] = { [3] = true, [4] = true, [6] = true },
                [2] = {
                    [0] = true, [1] = true, [2] = true, [3] = true,
                    [7] = true, [8] = true, [16] = true, [17] = true,
                },
            },
        },
    },

    -------------------------------------------------
    -- Feral Bear (Tank)
    -------------------------------------------------
    {
        name = "FeralBear [ZaiiaPawn]",
        weights = {
            ["STAMINA"]              = 1.65,
            ["AGILITY"]              = 0.95,
            ["STRENGTH"]             = 0.7,
            ["ARMOR"]                = 0.025,
            ["DEFENSE"]              = 1.0,
            ["DODGE"]                = 2.7,
            ["PARRY"]                = 0.0,
            ["BLOCK"]                = 0.0,
            ["BLOCK VALUE"]          = 0.0,
            ["FERAL ATTACK POWER"]   = 0.65,
            ["ATTACK POWER"]         = 0.55,
            ["HIT"]                  = 1.5,
            ["CRIT"]                 = 0.6,
            ["DPS"]                  = 0.15,
            ["HASTE"]                = 0.5,
            ["LIFESTEAL"]            = 0.8,
            ["AVOIDANCE"]            = 1.6,
            ["FORTUNE"]              = 0.4,
            ["HEALTH PER 5"]         = 0.5,
            ["ALL RESISTANCES"]      = 0.6,
            ["FIRE RESISTANCE"]      = 0.2,
            ["NATURE RESISTANCE"]    = 0.2,
            ["FROST RESISTANCE"]     = 0.15,
            ["SHADOW RESISTANCE"]    = 0.15,
            ["MOVEMENT SPEED"]       = 0.15,
            ["WEAPON DAMAGE"]        = 0.0,
            ["WEAPON SPEED"]         = 0.0,
        },
        notUsable = {
            byEquipLoc = { ["INVTYPE_THROWN"] = true },
            byClassSubclass = {
                [4] = { [3] = true, [4] = true, [6] = true },
                [2] = {
                    [0] = true, [1] = true, [2] = true, [3] = true,
                    [7] = true, [8] = true, [16] = true, [17] = true,
                },
            },
        },
    },

    -------------------------------------------------
    -- Restoration (Healer)
    -------------------------------------------------
    {
        name = "Restoration [ZaiiaPawn]",
        weights = {
            ["SPIRIT"]               = 1.35,
            ["INTELLECT"]            = 1.1,
            ["HEALING"]              = 1.45,
            ["SPELL POWER"]          = 0.55,
            ["SPELL DAMAGE"]         = 0.25,
            ["SPELL CRIT"]           = 1.25,
            ["SPELL HIT"]            = 0.4,
            ["MANA PER 5"]           = 1.5,
            ["CASTING REGEN"]        = 2.6,
            ["MANA"]                 = 0.1,
            ["STAMINA"]              = 0.55,
            ["HASTE"]                = 1.25,
            ["NATURE DAMAGE"]        = 0.2,
            ["LIFESTEAL"]            = 0.2,
            ["FORTUNE"]              = 0.5,
            ["AVOIDANCE"]            = 0.35,
            ["MOVEMENT SPEED"]       = 0.2,
            ["ALL RESISTANCES"]      = 0.5,
            ["STAVES"]               = 0.12,
            ["MACES"]                = 0.1,
            ["DAGGERS"]              = 0.05,
        },
        notUsable = {
            byEquipLoc = { ["INVTYPE_THROWN"] = true },
            byClassSubclass = {
                [4] = { [3] = true, [4] = true, [6] = true },
                [2] = {
                    [0] = true, [1] = true, [2] = true, [3] = true,
                    [7] = true, [8] = true, [16] = true, [17] = true,
                },
            },
        },
    },

    -------------------------------------------------
    -- Balance (Moonkin / caster DPS)
    -------------------------------------------------
    {
        name = "Balance [ZaiiaPawn]",
        weights = {
            ["INTELLECT"]            = 1.15,
            ["SPIRIT"]               = 0.7,
            ["SPELL POWER"]          = 1.05,
            ["SPELL DAMAGE"]         = 1.05,
            ["NATURE DAMAGE"]        = 1.3,
            ["ARCANE DAMAGE"]        = 0.95,
            ["SPELL HIT"]            = 2.6,
            ["SPELL CRIT"]           = 2.1,
            ["SPELL PENETRATION"]    = 1.25,
            ["HASTE"]                = 1.6,
            ["MANA PER 5"]           = 1.15,
            ["CASTING REGEN"]        = 2.0,
            ["MANA"]                 = 0.09,
            ["STAMINA"]              = 0.4,
            ["HEALING"]              = 0.25,
            ["LIFESTEAL"]            = 0.25,
            ["FORTUNE"]              = 0.85,
            ["AVOIDANCE"]            = 0.3,
            ["MOVEMENT SPEED"]       = 0.2,
            ["STAVES"]               = 0.12,
            ["MACES"]                = 0.1,
            ["DAGGERS"]              = 0.05,
            ["WANDS"]                = 0.08,
        },
        notUsable = {
            byEquipLoc = { ["INVTYPE_THROWN"] = true },
            byClassSubclass = {
                [4] = { [3] = true, [4] = true, [6] = true },
                [2] = {
                    [0] = true, [1] = true, [2] = true, [3] = true,
                    [7] = true, [8] = true, [16] = true, [17] = true,
                },
            },
        },
    },

    -------------------------------------------------
    -- Leveling 1-60 (Feral Cat primary)
    -------------------------------------------------
    {
        name = "Leveling 1-60 [ZaiiaPawn]",
        weights = {
            ["AGILITY"]              = 1.3,
            ["STRENGTH"]             = 1.0,
            ["STAMINA"]              = 0.9,
            ["ATTACK POWER"]         = 0.8,
            ["FERAL ATTACK POWER"]   = 0.6,
            ["CRIT"]                 = 1.8,
            ["HIT"]                  = 1.6,
            ["DPS"]                  = 0.2,
            ["HASTE"]                = 1.2,
            ["LIFESTEAL"]            = 1.5,
            ["SPIRIT"]               = 0.4,
            ["HEALTH PER 5"]         = 0.3,
            ["ARMOR"]                = 0.015,
            ["DODGE"]                = 1.0,
            ["MOVEMENT SPEED"]       = 0.4,
            ["MOUNT SPEED"]          = 0.3,
            ["STAVES"]               = 0.05,
            ["MACES"]                = 0.1,
            ["POLEARMS"]             = 0.1,
            ["DAGGERS"]              = 0.05,
            ["WEAPON DAMAGE"]        = 0.0,
            ["WEAPON SPEED"]         = 0.0,
        },
        notUsable = {
            byEquipLoc = { ["INVTYPE_THROWN"] = true },
            byClassSubclass = {
                [4] = { [3] = true, [4] = true, [6] = true },
                [2] = {
                    [0] = true, [1] = true, [2] = true, [3] = true,
                    [7] = true, [8] = true, [16] = true, [17] = true,
                },
            },
        },
    },
}