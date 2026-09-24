-------------------------------------------------
-- ZaiiaPawn Defaults/ZaiiaPawn_Paladin.lua
-- Paladin presets (Turtle WoW 1.18.1).
--
-- notUsable.byEquipLoc keys are INVTYPE_* TOKEN strings
-- (exactly what GetItemInfo() returns as its 9th value):
--   "INVTYPE_2HWEAPON", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT",
--   "INVTYPE_THROWN", "INVTYPE_HOLDABLE", "INVTYPE_WEAPONOFFHAND",
--   "INVTYPE_SHIELD", "INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND"
-- notUsable.byClassSubclass keys are numeric classID/subclassID
-- from GetItemInfo()'s 12th/13th returns (see Core/Utils.lua).
-- All keys are locale-independent.
--
-- Paladin can use: 1H/2H axe, 1H/2H mace, 1H/2H sword,
--   polearm, shield, holdable, libram.
-- Paladin cannot use: dagger, fist, bow, gun, crossbow,
--   thrown, wand, staff, idol, totem, off-hand weapon.
-------------------------------------------------
ZaiiaPawnPresets = ZaiiaPawnPresets or {}
ZaiiaPawnPresets["PALADIN"] = {

    -------------------------------------------------
    -- Protection (Tank)
    -------------------------------------------------
    {
        name = "Protection [ZaiiaPawn]",
        weights = {
            ["STAMINA"] = 5.46, ["DEFENSE"] = 2.05,
            ["DODGE"] = 2.0, ["PARRY"] = 2.0, ["BLOCK"] = 2.0,
            ["BLOCK VALUE"] = 1.5, ["ARMOR"] = 0.5,
            ["AVOIDANCE"] = 0.3, ["ALL RESISTANCES"] = 0.5,
            ["STRENGTH"] = 0.9, ["HIT"] = 1.44, ["SPELL HIT"] = 1.0,
            ["SPELL POWER"] = 0.44, ["INTELLECT"] = 0.2, ["SPIRIT"] = 0.05,
            ["CRIT"] = 0.5, ["LIFESTEAL"] = 0.5, ["MOVEMENT SPEED"] = 0.5,
            ["WEAPON TYPE 2H"] = -1000, ["WEAPON TYPE 1H"] = 50,
            ["WEAPON TYPE SHIELD"] = 100,
            ["WEAPON DAMAGE"] = 0, ["WEAPON SPEED"] = -3, ["DPS"] = 1.5,
            ["PROCS"] = 5, ["PROC DAMAGE"] = 0.1,
            ["PROC AOE"] = 20, ["PROC HEAL"] = 10,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_2HWEAPON"]      = true,
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },

    -------------------------------------------------
    -- Protection AOE (Farmer)
    -------------------------------------------------
    {
        name = "Protection AOE [ZaiiaPawn]",
        weights = {
            ["SPELL POWER"] = 2.5, ["SPELL DAMAGE"] = 2.0,
            ["STRENGTH"] = 1.5, ["ATTACK POWER"] = 1.2,
            ["HEALING"] = 0.5, ["SPELL HIT"] = 0.5, ["SPELL CRIT"] = 1.0,
            ["INTELLECT"] = 1.5, ["SPIRIT"] = 0.5,
            ["STAMINA"] = 3.0, ["ARMOR"] = 0.03, ["DEFENSE"] = 1.0,
            ["DODGE"] = 0.5, ["PARRY"] = 0.5, ["BLOCK"] = 1.0,
            ["BLOCK VALUE"] = 1.0, ["AVOIDANCE"] = 0.2,
            ["HIT"] = 0.5, ["CRIT"] = 0.5, ["LIFESTEAL"] = 2.5,
            ["WEAPON TYPE 2H"] = -1000, ["WEAPON TYPE 1H"] = 50,
            ["WEAPON TYPE SHIELD"] = 100,
            ["WEAPON DAMAGE"] = 0, ["WEAPON SPEED"] = -3, ["DPS"] = 1.5,
            ["PROCS"] = 5, ["PROC DAMAGE"] = 0.2,
            ["PROC AOE"] = 30, ["PROC HEAL"] = 15,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_2HWEAPON"]      = true,
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },

    -------------------------------------------------
    -- Holy (Healer)
    -------------------------------------------------
    {
        name = "Holy [ZaiiaPawn]",
        weights = {
            ["INTELLECT"] = 2.5, ["HEALING"] = 3.0,
            ["SPELL POWER"] = 1.5, ["SPELL CRIT"] = 1.2,
            ["MANA PER 5"] = 1.0, ["HASTE"] = 1.0, ["MANA"] = 0.5,
            ["STAMINA"] = 0.5, ["MOVEMENT SPEED"] = 0.5, ["SPIRIT"] = 0.3,
            ["WEAPON TYPE SHIELD"] = 20,
            ["WEAPON DAMAGE"] = 0, ["WEAPON SPEED"] = 0, ["DPS"] = 0,
            ["PROCS"] = 5, ["PROC HEAL"] = 15,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },

    -------------------------------------------------
    -- Retribution (DPS)
    -------------------------------------------------
    {
        name = "Retribution [ZaiiaPawn]",
        weights = {
            ["STRENGTH"] = 2.5, ["AGILITY"] = 0.8,
            ["STAMINA"] = 0.5, ["INTELLECT"] = 0.3,
            ["HIT"] = 2.0, ["CRIT"] = 2.0, ["HASTE"] = 1.0,
            ["ATTACK POWER"] = 1.5, ["SPELL POWER"] = 1.2,
            ["ARMOR PENETRATION"] = 0.3, ["LIFESTEAL"] = 0.3,
            ["WEAPON DAMAGE"] = 2.0, ["WEAPON SPEED"] = 20, ["DPS"] = 0.5,
            ["WEAPON TYPE 2H"] = 100, ["WEAPON TYPE 1H"] = -30,
            ["WEAPON TYPE SHIELD"] = -20,
            ["PROCS"] = 5, ["PROC DAMAGE"] = 0.3,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },

    -------------------------------------------------
    -- Spell Power (Retribution)
    -------------------------------------------------
    {
        name = "Spell Power [ZaiiaPawn]",
        weights = {
            ["SPELL POWER"] = 2.5, ["SPELL DAMAGE"] = 2.0,
            ["SPELL HIT"] = 1.0, ["SPELL CRIT"] = 1.5,
            ["SPELL PENETRATION"] = 0.5, ["HOLY DAMAGE"] = 0.5,
            ["INTELLECT"] = 1.0,
            ["STRENGTH"] = 1.8, ["ATTACK POWER"] = 1.2,
            ["HIT"] = 1.0, ["CRIT"] = 1.0,
            ["AGILITY"] = 0.5, ["HASTE"] = 0.5, ["STAMINA"] = 0.5,
            ["WEAPON TYPE 2H"] = 100, ["WEAPON TYPE 1H"] = -30,
            ["WEAPON TYPE SHIELD"] = -20,
            ["WEAPON DAMAGE"] = 1.5, ["WEAPON SPEED"] = 25, ["DPS"] = 0.3,
            ["PROCS"] = 5, ["PROC DAMAGE"] = 0.4,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },

    -------------------------------------------------
    -- Ret Leveling (1-60)
    -------------------------------------------------
    {
        name = "Ret Leveling [ZaiiaPawn]",
        weights = {
            ["STRENGTH"] = 2.5, ["AGILITY"] = 1.0,
            ["ATTACK POWER"] = 1.5, ["HIT"] = 1.5, ["CRIT"] = 1.5,
            ["STAMINA"] = 1.0, ["INTELLECT"] = 0.8,
            ["SPIRIT"] = 0.5, ["LIFESTEAL"] = 1.5,
            ["SPELL POWER"] = 1.0, ["SPELL DAMAGE"] = 0.8,
            ["WEAPON DAMAGE"] = 1.5, ["WEAPON SPEED"] = 15, ["DPS"] = 0.5,
            ["WEAPON TYPE 2H"] = 100, ["WEAPON TYPE 1H"] = -15,
            ["WEAPON TYPE SHIELD"] = -10,
            ["ARMOR"] = 0.02, ["MOVEMENT SPEED"] = 0.5,
            ["PROCS"] = 5, ["PROC DAMAGE"] = 0.3,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_RANGED"]        = true,
                ["INVTYPE_RANGEDRIGHT"]   = true,
                ["INVTYPE_THROWN"]        = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [2] = {
                    [13] = true,  -- Dagger
                    [11] = true,  -- Fist
                    [17] = true,  -- Wand
                    [10] = true,  -- Staff
                },
                [4] = {
                    [8] = true,   -- Idol
                    [9] = true,   -- Totem
                },
            },
        },
    },
}