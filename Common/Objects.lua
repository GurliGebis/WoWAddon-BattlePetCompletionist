--[[
    Copyright (C) 2023-2026 GurliGebis

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]

_BattlePetCompletionist = {
    Constants = {
        PET_QUALITY_RARE = 4,
        PET_TYPE_ICONS = {
            "Interface\\icons\\Icon_PetFamily_Humanoid",
            "Interface\\icons\\Icon_PetFamily_Dragon",
            "Interface\\icons\\Icon_PetFamily_Flying",
            "Interface\\icons\\Icon_PetFamily_Undead",
            "Interface\\icons\\Icon_PetFamily_Critter",
            "Interface\\icons\\Icon_PetFamily_Magical",
            "Interface\\icons\\Icon_PetFamily_Elemental",
            "Interface\\icons\\Icon_PetFamily_Beast",
            "Interface\\icons\\Icon_PetFamily_Water",
            "Interface\\icons\\Icon_PetFamily_Mechanical",
        },
        PET_SOURCES = {
            [1] = BATTLE_PET_SOURCE_1,
            [2] = BATTLE_PET_SOURCE_2,
            [3] = BATTLE_PET_SOURCE_3,
            [4] = BATTLE_PET_SOURCE_4,
            [5] = BATTLE_PET_SOURCE_5,
            [7] = BATTLE_PET_SOURCE_7,
            [9] = BATTLE_PET_SOURCE_9
        },
    },
    Enums = {
        CombatMode = {
            HELP_A_FRIEND = "HELP_A_FRIEND",
            FORFEIT = "FORFEIT",
            NONE = "NONE",
        },
        Goal = {
            COLLECT = "COLLECT",
            COLLECT_RARE = "COLLECT_RARE",
            COLLECT_MAX = "COLLECT_MAX",
            COLLECT_MAX_RARE = "COLLECT_MAX_RARE",
        },
        ForfeitPromptUnless = {
            MISSING = "MISSING",
            NOT_RARE = "NOT_RARE",
            NOT_MAX_COLLECTED = "NOT_MAX_COLLECTED",
            NOT_MAX_RARE = "NOT_MAX_RARE",
        },
        ForfeitThreshold = {
            RARE = "Rare",
            UNCOMMON = "Uncommon",
            COMMON = "Common",
            POOR = "Poor",
        },
        MapPinFilter = {
            ALL = "ALL",
            MISSING = "MISSING",
            NOT_RARE = "NOT_RARE",
            NONE = "NONE",
            NOT_MAX_COLLECTED = "NOT_MAX_COLLECTED",
            NAME_FILTER = "NAME_FILTER",
            NOT_MAX_RARE = "NOT_MAX_RARE",
        },
        MapPinIconType = {
            PET = "PET",
            FAMILY = "FAMILY",
        },
        MapPinSize = {
            X_SMALL = "X_SMALL",
            SMALL = "SMALL",
            MEDIUM = "MEDIUM",
            LARGE = "LARGE",
        },
        GameEdition = {
            RETAIL = "Retail",
            CLASSIC = "Classic"
        },
    },
    Events = {
        ZONE_CHANGE = "BattlePetCompletionist_ZoneChange",
    },
}
