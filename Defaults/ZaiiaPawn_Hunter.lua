-------------------------------------------------
-- ZaiiaPawn Defaults/ZaiiaPawn_Hunter.lua
-- Hunter presets (Turtle WoW 1.18.1).
--
-- Ranged vs melee weapon stats:
--   The parser routes ranged weapons' DPS / per-hit
--   damage / swing speed into the RANGED-* stats, so
--   the two categories can be weighted independently.
--
--   * Ranged specs (BM / MM / Survival): the ranged
--     weapon is the main damage source, so RANGED DPS
--     carries full weight.  The melee weapon contributes
--     only stat bonuses; its DPS / damage / speed sit at
--     0.05 so two melee weapons with equal stats can
--     still be ranked, but stats always dominate.
--   * Melee spec: the melee weapon is the main damage
--     source (Aspect of the Wolf), so melee DPS / damage
--     / speed carry full weight there.
--
-- Turtle-specific mechanics (Melee only):
--   * Mongoose Bite: 60% weapon damage + flat, resets
--     auto-attack swing timer.
--   * Improved Predator Aspects: attack speed proc.
--   * Endurance Training: 6..30% of Stamina to pet.
--
-- Hunter weapon proficiencies:
--   * Usable: Axes (1H/2H), Swords (1H/2H), Daggers,
--     Fist Weapons, Polearms, Staves,
--     Bows, Guns, Crossbows, Thrown.
--   * NOT usable: Maces (1H/2H), Wands, Shields,
--     Holdables, Off-hand weapons.
-------------------------------------------------
ZaiiaPawnPresets = ZaiiaPawnPresets or {}
ZaiiaPawnPresets["HUNTER"] = {

    -------------------------------------------------
    -- Beast Mastery (ranged, pet-focused)
    -------------------------------------------------
    {
        name = "BeastMastery [ZaiiaPawn]",
        weights = {
            ["AGILITY"]              = 1.35,
            ["STAMINA"]              = 0.55,
            ["RANGED ATTACK POWER"]  = 1.25,
            ["ATTACK POWER"]         = 0.5,
            ["RANGED CRIT"]          = 2.2,
            ["RANGED HASTE"]         = 1.9,
            ["CRIT"]                 = 1.7,
            ["HIT"]                  = 2.1,

            -- Ranged weapon (main damage source)
            ["RANGED DPS"]           = 1.3,
            ["RANGED WEAPON DAMAGE"] = 0.05,
            ["RANGED WEAPON SPEED"]  = 0,

            -- Melee weapon (stats only, tiny DPS tiebreak)
            ["DPS"]                  = 0.05,
            ["WEAPON DAMAGE"]        = 0.05,
            ["WEAPON SPEED"]         = 0,

            ["HASTE"]                = 1.5,
            ["BOWS"]                 = 0.55,
            ["GUNS"]                 = 0.55,
            ["CROSSBOWS"]            = 0.55,
            ["AXES"]                 = 0.2,
            ["SWORDS"]               = 0.2,
            ["DAGGERS"]              = 0.15,
            ["POLEARMS"]             = 0.15,
            ["STAVES"]               = 0.1,
            ["FIST WEAPONS"]         = 0.15,
            ["INTELLECT"]            = 0.15,
            ["LIFESTEAL"]            = 1.0,
            ["FORTUNE"]              = 0.8,
            ["MOVEMENT SPEED"]       = 0.2,
            ["WEAPON TYPE 2H"]       = 10,
            ["WEAPON TYPE 1H"]       = 5,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [4] = { [6] = true },
                [2] = {
                    [17] = true, [4] = true, [5] = true,
                },
            },
        },
    },

    -------------------------------------------------
    -- Marksmanship (ranged, shot-focused)
    -------------------------------------------------
    {
        name = "Marksmanship [ZaiiaPawn]",
        weights = {
            ["AGILITY"]              = 1.4,
            ["STAMINA"]              = 0.45,
            ["RANGED ATTACK POWER"]  = 1.35,
            ["ATTACK POWER"]         = 0.35,
            ["RANGED CRIT"]          = 2.5,
            ["RANGED HASTE"]         = 2.1,
            ["CRIT"]                 = 1.9,
            ["HIT"]                  = 2.25,

            ["RANGED DPS"]           = 1.4,
            ["RANGED WEAPON DAMAGE"] = 0.05,
            ["RANGED WEAPON SPEED"]  = 0,

            ["DPS"]                  = 0.05,
            ["WEAPON DAMAGE"]        = 0.05,
            ["WEAPON SPEED"]         = 0,

            ["ARMOR PENETRATION"]    = 0.9,
            ["BOWS"]                 = 0.6,
            ["GUNS"]                 = 0.6,
            ["CROSSBOWS"]            = 0.6,
            ["AXES"]                 = 0.15,
            ["SWORDS"]               = 0.15,
            ["INTELLECT"]            = 0.25,
            ["MANA PER 5"]           = 0.3,
            ["LIFESTEAL"]            = 0.8,
            ["FORTUNE"]              = 0.8,
            ["MOVEMENT SPEED"]       = 0.2,
            ["WEAPON TYPE 2H"]       = 10,
            ["WEAPON TYPE 1H"]       = 5,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [4] = { [6] = true },
                [2] = { [17] = true, [4] = true, [5] = true },
            },
        },
    },

    -------------------------------------------------
    -- Survival (ranged, agility/expose-weakness)
    -------------------------------------------------
    {
        name = "Survival [ZaiiaPawn]",
        weights = {
            ["AGILITY"]              = 1.5,
            ["STAMINA"]              = 0.6,
            ["RANGED ATTACK POWER"]  = 1.15,
            ["ATTACK POWER"]         = 0.5,
            ["RANGED CRIT"]          = 2.0,
            ["RANGED HASTE"]         = 1.8,
            ["CRIT"]                 = 1.8,
            ["HIT"]                  = 2.0,

            ["RANGED DPS"]           = 1.3,
            ["RANGED WEAPON DAMAGE"] = 0.05,
            ["RANGED WEAPON SPEED"]  = 0,

            ["DPS"]                  = 0.05,
            ["WEAPON DAMAGE"]        = 0.05,
            ["WEAPON SPEED"]         = 0,

            ["HASTE"]                = 1.7,
            ["LIFESTEAL"]            = 1.2,
            ["BOWS"]                 = 0.5,
            ["GUNS"]                 = 0.5,
            ["CROSSBOWS"]            = 0.5,
            ["AXES"]                 = 0.25,
            ["SWORDS"]               = 0.25,
            ["POLEARMS"]             = 0.2,
            ["DAGGERS"]              = 0.2,
            ["STAVES"]               = 0.1,
            ["FORTUNE"]              = 0.8,
            ["MOVEMENT SPEED"]       = 0.2,
            ["WEAPON TYPE 2H"]       = 10,
            ["WEAPON TYPE 1H"]       = 5,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [4] = { [6] = true },
                [2] = { [17] = true, [4] = true, [5] = true },
            },
        },
    },

    -------------------------------------------------
    -- Melee (Aspect of the Wolf)
    -------------------------------------------------
    {
        name = "Melee [ZaiiaPawn]",
        weights = {
            ["STRENGTH"]             = 1.0,
            ["AGILITY"]              = 1.0,
            ["STAMINA"]              = 0.9,
            ["ATTACK POWER"]         = 1.05,
            ["HIT"]                  = 2.15,
            ["CRIT"]                 = 2.1,

            -- Melee weapon carries the build
            ["DPS"]                  = 1.5,
            ["WEAPON DAMAGE"]        = 2.0,
            ["WEAPON SPEED"]         = 15,

            -- Ranged weapon is unused
            ["RANGED DPS"]           = 0,
            ["RANGED WEAPON DAMAGE"] = 0,
            ["RANGED WEAPON SPEED"]  = 0,

            ["HASTE"]                = 1.8,
            ["ARMOR"]                = 0.02,
            ["DODGE"]                = 1.5,
            ["DEFENSE"]              = 1.2,
            ["LIFESTEAL"]            = 1.6,
            ["FORTUNE"]              = 1.0,
            ["AVOIDANCE"]            = 0.5,
            ["HEALTH PER 5"]         = 0.4,
            ["AXES"]                 = 0.5,
            ["SWORDS"]               = 0.5,
            ["DAGGERS"]              = 0.25,
            ["FIST WEAPONS"]         = 0.25,
            ["POLEARMS"]             = 0.3,
            ["STAVES"]               = 0.2,
            ["MOVEMENT SPEED"]       = 0.3,
            ["WEAPON TYPE 2H"]       = 20,
            ["WEAPON TYPE 1H"]       = 5,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [4] = { [6] = true },
                [2] = { [17] = true, [4] = true, [5] = true },
            },
        },
    },

    -------------------------------------------------
    -- Leveling 1-60 (Beast Mastery base)
    -------------------------------------------------
    {
        name = "Leveling 1-60 [ZaiiaPawn]",
        weights = {
            ["AGILITY"]              = 1.35,
            ["STAMINA"]              = 0.9,
            ["SPIRIT"]               = 0.35,
            ["RANGED ATTACK POWER"]  = 1.15,
            ["ATTACK POWER"]         = 0.5,
            ["RANGED CRIT"]          = 1.8,
            ["RANGED HASTE"]         = 1.6,
            ["CRIT"]                 = 1.6,
            ["HIT"]                  = 1.7,

            ["RANGED DPS"]           = 1.3,
            ["RANGED WEAPON DAMAGE"] = 0.05,
            ["RANGED WEAPON SPEED"]  = 0,

            ["DPS"]                  = 0.05,
            ["WEAPON DAMAGE"]        = 0.05,
            ["WEAPON SPEED"]         = 0,

            ["HASTE"]                = 1.5,
            ["LIFESTEAL"]            = 1.5,
            ["FORTUNE"]              = 0.7,
            ["HEALTH PER 5"]         = 0.35,
            ["BOWS"]                 = 0.45,
            ["GUNS"]                 = 0.45,
            ["CROSSBOWS"]            = 0.45,
            ["AXES"]                 = 0.3,
            ["SWORDS"]               = 0.3,
            ["DAGGERS"]              = 0.2,
            ["POLEARMS"]             = 0.2,
            ["STAVES"]               = 0.15,
            ["MOVEMENT SPEED"]       = 0.4,
            ["MOUNT SPEED"]          = 0.3,
            ["WEAPON TYPE 2H"]       = 10,
            ["WEAPON TYPE 1H"]       = 5,
        },
        notUsable = {
            byEquipLoc = {
                ["INVTYPE_HOLDABLE"]      = true,
                ["INVTYPE_WEAPONOFFHAND"] = true,
            },
            byClassSubclass = {
                [4] = { [6] = true },
                [2] = { [17] = true, [4] = true, [5] = true },
            },
        },
    },
}