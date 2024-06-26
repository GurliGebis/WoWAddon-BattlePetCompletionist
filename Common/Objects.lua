_BattlePetCompletionist = {
    Constants = {
        PET_QUALITY_RARE = 4,
        PET_SOURCES = {
            [1] = BATTLE_PET_SOURCE_1,
            [2] = BATTLE_PET_SOURCE_2,
            [3] = BATTLE_PET_SOURCE_3,
            [4] = BATTLE_PET_SOURCE_4,
            [5] = BATTLE_PET_SOURCE_5,
            [7] = BATTLE_PET_SOURCE_7
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
    },
    Events = {
        ZONE_CHANGE = "BattlePetCompletionist_ZoneChange",
    },
}
