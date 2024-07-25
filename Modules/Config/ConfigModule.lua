--[[
    Copyright (C) 2023 GurliGebis

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

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local ConfigModule = BattlePetCompletionist:NewModule("ConfigModule", "AceConsole-3.0")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local standardControlWidth = 1.2; -- A little wider to allow for longer option labels
local options = {
    name = "Battle Pet Completionist",
    handler = ConfigModule,
    type = "group",
    args = {
        tooltipsAndNotificationsHeader = {
            order = 1,
            name = "Tooltips and Notifications",
            type = "header"
        },
        tooltipsDescription = {
            order = 2,
            name = "Tooltip and notification settings" .. "\n",
            type = "description"
        },
        petCageTooltipEnabled = {
            order = 3,
            name = "Enable tooltips for pet cages and auction listings",
            type = "toggle",
            desc = "Show a tooltip when hovering over a Pet Cage item or a pet in the auction UI.",
            width = "full",
            get = function()
                return DBModule:GetProfile().petCageTooltipEnabled
            end,
            set = function()
                local profile = DBModule:GetProfile()
                profile.petCageTooltipEnabled = not profile.petCageTooltipEnabled
            end
        },
        petBattleUnknownNotifyEnabled = {
            order = 4,
            name = "Show notification when uncollected pets are in the enemy team.",
            type = "toggle",
            desc = "Show a notification window when one or more uncollected pets can be captured",
            width = "full",
            get = function()
                return DBModule:GetProfile().petBattleUnknownNotifyEnabled
            end,
            set = function()
                local profile = DBModule:GetProfile()
                profile.petBattleUnknownNotifyEnabled = not profile.petBattleUnknownNotifyEnabled
            end
        },
        displayHeader = {
            order = 5,
            name = "Display",
            type = "header"
        },
        minimapDescription = {
            order = 6,
            name = "Minimap settings" .. "\n",
            type = "description"
        },
        minimapIconEnabled = {
            order = 7,
            name = "Enable the minimap icon",
            type = "toggle",
            desc = "Show an icon on the minimap.",
            width = "full",
            get = function()
                return DBModule:GetProfile().minimapIconEnabled
            end,
            set = function()
                local profile = DBModule:GetProfile()
                profile.minimapIconEnabled = not profile.minimapIconEnabled

                local MinimapModule = BattlePetCompletionist:GetModule("MinimapModule")
                MinimapModule:UpdateMinimap()
            end
        },
        brokerDescription = {
            order = 8,
            name = "Data Broker settings" .. "\n",
            type = "description"
        },
        brokerGoal = {
            order = 9,
            name = "Display Goal",
            type = "select",
            width = standardControlWidth,
            desc = "The goal to track in the data source.",
            values = {
                [_BattlePetCompletionist.Enums.Goal.COLLECT] = "Collect at least one",
                [_BattlePetCompletionist.Enums.Goal.COLLECT_RARE] = "Collect at least one rare",
                [_BattlePetCompletionist.Enums.Goal.COLLECT_MAX] = "Collect maximum amount",
                [_BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE] = "Collect maximum amount rare",
            },
            sorting = {
                _BattlePetCompletionist.Enums.Goal.COLLECT,
                _BattlePetCompletionist.Enums.Goal.COLLECT_RARE,
                _BattlePetCompletionist.Enums.Goal.COLLECT_MAX,
                _BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE,
            },
            get = function()
                return DBModule:GetProfile().brokerGoal
            end,
            set = function(_, value)
                DBModule:GetProfile().brokerGoal = value
                local BrokerModule = BattlePetCompletionist:GetModule("BrokerModule")
                BrokerModule:RefreshData()
            end
        },
        brokerGoalTextEnabled = {
            order = 10,
            name = "Include goal text",
            type = "toggle",
            desc = "Add a suffix to the displayed text",
            width = standardControlWidth,
            get = function()
                return DBModule:GetProfile().brokerGoalTextEnabled
            end,
            set = function()
                local profile = DBModule:GetProfile()
                profile.brokerGoalTextEnabled = not profile.brokerGoalTextEnabled
                local BrokerModule = BattlePetCompletionist:GetModule("BrokerModule")
                BrokerModule:RefreshData()
            end
        },
        mapPinsHeader = {
            order = 11,
            name = "Map pins",
            type = "header"
        },
        mapPinsDescription = {
            order = 12,
            name = "Map pins settings" .. "\n",
            type = "description"
        },
        mapPinsToInclude = {
            order = 13,
            name = "Map pins to include",
            type = "select",
            width = standardControlWidth,
            desc = "Which map pins should be shown on the map.",
            values = {
                [_BattlePetCompletionist.Enums.MapPinFilter.ALL] = "All",
                [_BattlePetCompletionist.Enums.MapPinFilter.MISSING] = "Missing",
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_RARE] = "Not rare",
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_COLLECTED] = "Not maximum amount collected",
                [_BattlePetCompletionist.Enums.MapPinFilter.NAME_FILTER] = "Name filter",
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_RARE] = "Not maximum rare collected",
                [_BattlePetCompletionist.Enums.MapPinFilter.NONE] = "None",
            },
            sorting = {
                _BattlePetCompletionist.Enums.MapPinFilter.ALL,
                _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_RARE,
                _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_COLLECTED,
                _BattlePetCompletionist.Enums.MapPinFilter.NOT_RARE,
                _BattlePetCompletionist.Enums.MapPinFilter.MISSING,
                _BattlePetCompletionist.Enums.MapPinFilter.NAME_FILTER,
                _BattlePetCompletionist.Enums.MapPinFilter.NONE,
            },
            get = function()
                return DBModule:GetProfile().mapPinsToInclude
            end,
            set = function(_, value)
                local profile = DBModule:GetProfile()
                if value == _BattlePetCompletionist.Enums.MapPinFilter.NONE and profile.mapPinsToInclude ~= _BattlePetCompletionist.Enums.MapPinFilter.NONE then
                    -- Save the value from before "None" was selected, so we can switch to that if enabled from the map dropdown.
                    profile.mapPinsToIncludeOriginal = profile.mapPinsToInclude
                end
                profile.mapPinsToInclude = value
                local MapModule = BattlePetCompletionist:GetModule("MapModule")
                MapModule:UpdateWorldMap()
            end
        },
        mapPinsFilter = {
            order = 14,
            name = "Partial pet name",
            type = "input",
            width = standardControlWidth,
            desc = "Enter part the name to filter by",
            get = function()
                return DBModule:GetProfile().mapPinsFilter
            end,
            set = function(_, value)
                DBModule:GetProfile().mapPinsFilter = value
                local MapModule = BattlePetCompletionist:GetModule("MapModule")
                MapModule:UpdateWorldMap()
            end
        },
        spacer1 = {
            order = 15,
            name = "",
            type = "description"
        },
        mapPinSize = {
            order = 16,
            name = "Map pin size",
            type = "select",
            width = standardControlWidth,
            desc = "The size of the pins on the map.",
            values = {
                [_BattlePetCompletionist.Enums.MapPinSize.X_SMALL] = "Extra small",
                [_BattlePetCompletionist.Enums.MapPinSize.SMALL] = "Small",
                [_BattlePetCompletionist.Enums.MapPinSize.MEDIUM] = "Medium",
                [_BattlePetCompletionist.Enums.MapPinSize.LARGE] = "Large",
            },
            sorting = {
                _BattlePetCompletionist.Enums.MapPinSize.X_SMALL,
                _BattlePetCompletionist.Enums.MapPinSize.SMALL,
                _BattlePetCompletionist.Enums.MapPinSize.MEDIUM,
                _BattlePetCompletionist.Enums.MapPinSize.LARGE,
            },
            get = function()
                return DBModule:GetProfile().mapPinSize
            end,
            set = function(_, value)
                DBModule:GetProfile().mapPinSize = value
            end
        },
        spacer2 = {
            order = 17,
            name = "",
            type = "description"
        },
        mapPinIconType = {
            order = 18,
            name = "Map pin icon type",
            type = "select",
            width = standardControlWidth,
            desc = "The kind of icon to show in the pins on the map.",
            values = {
                [_BattlePetCompletionist.Enums.MapPinIconType.PET] = "Pet Icon",
                [_BattlePetCompletionist.Enums.MapPinIconType.FAMILY] = "Pet Family",
            },
            sorting = {
                _BattlePetCompletionist.Enums.MapPinIconType.PET,
                _BattlePetCompletionist.Enums.MapPinIconType.FAMILY,
            },
            get = function()
                return DBModule:GetProfile().mapPinIconType
            end,
            set = function(_, value)
                DBModule:GetProfile().mapPinIconType = value
            end
        },
        spacer3 = {
            order = 19,
            name = "",
            type = "description"
        },
        mapPinSources = {
            order = 20,
            name = "Map pin sources",
            type = "multiselect",
            desc = "The sources for pets to show on the map.",
            values = _BattlePetCompletionist.Constants.PET_SOURCES,
            get = function(_, key)
                return DBModule:GetProfile().mapPinSources[key]
            end,
            set = function(_, key, value)
                DBModule:GetProfile().mapPinSources[key] = value
            end
        },
        integrationHeader = {
            order = 21,
            name = "Integrations",
            type = "header"
        },
        integrationDescription = {
            order = 22,
            name = "Integration settings" .. "\n",
            type = "description"
        },
        tomtomIntegrationEnabled = {
            order = 23,
            name = "Tomtom",
            type = "toggle",
            desc = "SHIFT + left clicking a map pin creates a TomTom waypoint.",
            width = "full",
            get = function()
                return DBModule:GetProfile().tomtomIntegration
            end,
            set = function()
                local profile = DBModule:GetProfile()
                profile.tomtomIntegration = not profile.tomtomIntegration
            end
        },
        combatHeader = {
            order = 24,
            name = "Combat",
            type = "header"
        },
        combatDescription = {
            order = 25,
            name = "Combat settings" .. "\n",
            type = "description"
        },
        combatMode = {
            order = 26,
            name = "Combat mode",
            type = "select",
            width = standardControlWidth,
            desc = "How to function when pet battles are started",
            values = {
                [_BattlePetCompletionist.Enums.CombatMode.HELP_A_FRIEND] = "Help a Friend",
                [_BattlePetCompletionist.Enums.CombatMode.FORFEIT] = "Forfeit",
                [_BattlePetCompletionist.Enums.CombatMode.NONE] = "None",
            },
            sorting = {
                _BattlePetCompletionist.Enums.CombatMode.HELP_A_FRIEND,
                _BattlePetCompletionist.Enums.CombatMode.FORFEIT,
                _BattlePetCompletionist.Enums.CombatMode.NONE,
            },
            get = function()
                return DBModule:GetProfile().combatMode
            end,
            set = function(_, value)
                DBModule:GetProfile().combatMode = value
            end
        },
        forfeitThreshold = {
            order = 27,
            name = "Forfeit threshold",
            type = "select",
            width = standardControlWidth,
            desc = "The threshold for when to always suggest forfeit.",
            values = {
                [_BattlePetCompletionist.Enums.ForfeitThreshold.RARE] = "Rare",
                [_BattlePetCompletionist.Enums.ForfeitThreshold.UNCOMMON] = "Uncommon",
                [_BattlePetCompletionist.Enums.ForfeitThreshold.COMMON] = "Common",
                [_BattlePetCompletionist.Enums.ForfeitThreshold.POOR] = "Poor"
            },
            sorting = {
                _BattlePetCompletionist.Enums.ForfeitThreshold.RARE,
                _BattlePetCompletionist.Enums.ForfeitThreshold.UNCOMMON,
                _BattlePetCompletionist.Enums.ForfeitThreshold.COMMON,
                _BattlePetCompletionist.Enums.ForfeitThreshold.POOR,
            },
            get = function()
                return DBModule:GetProfile().forfeitThreshold
            end,
            set = function(_, value)
                DBModule:GetProfile().forfeitThreshold = value
            end
        },
        forfeitPromptUnless = {
            order = 28,
            name = "Forfeit prompt unless",
            type = "select",
            width = standardControlWidth,
            desc = "The condition for when to not forfeit.",
            values = {
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.MISSING] = "Missing",
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_RARE] = "Not rare",
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_COLLECTED] = "Not maximum amount collected",
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_RARE] = "Not maximum rare collected",
            },
            sorting = {
                _BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_RARE,
                _BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_COLLECTED,
                _BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_RARE,
                _BattlePetCompletionist.Enums.ForfeitPromptUnless.MISSING,
            },
            get = function()
                return DBModule:GetProfile().forfeitPromptUnless
            end,
            set = function(_, value)
                DBModule:GetProfile().forfeitPromptUnless = value
            end
        },
    },
}

function ConfigModule:OnInitialize()
    AceConfig:RegisterOptionsTable("BattlePetCompletionist_options", options)
    ConfigModule.OptionsFrame = AceConfigDialog:AddToBlizOptions("BattlePetCompletionist_options", "Battle Pet Completionist")

    ConfigModule:RegisterChatCommand("bpcom", "ChatCommandOptions")
end

function ConfigModule:ChatCommandOptions(msg)
    Settings.OpenToCategory(ConfigModule.OptionsFrame.name)
end
