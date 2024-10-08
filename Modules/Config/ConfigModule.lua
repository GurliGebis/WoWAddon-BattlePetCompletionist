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

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_Config")

local standardControlWidth = 1.2; -- A little wider to allow for longer option labels
local options = {
    name = L["Config Section - Battle Pet Completionist"],
    handler = ConfigModule,
    type = "group",
    args = {
        tooltipsAndNotificationsHeader = {
            order = 1,
            name = L["Header - Tooltips and Notifications"],
            type = "header"
        },
        tooltipsDescription = {
            order = 2,
            name = L["Description - Tooltip and notification settings"] .. "\n",
            type = "description"
        },
        petCageTooltipEnabled = {
            order = 3,
            name = L["Enable tooltips for pet cages and auction listings"],
            type = "toggle",
            desc = L["Show a tooltip when hovering over a Pet Cage item or a pet in the auction UI"],
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
            name = L["Show notification when uncollected pets are in the enemy team"],
            type = "toggle",
            desc = L["Show a notification window when one or more uncollected pets can be captured"],
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
            name = L["Header - Display"],
            type = "header"
        },
        minimapDescription = {
            order = 6,
            name = L["Description - Minimap settings"] .. "\n",
            type = "description"
        },
        minimapIconEnabled = {
            order = 7,
            name = L["Enable the minimap icon"],
            type = "toggle",
            desc = L["Show an icon on the minimap"],
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
            name = L["Description - Data Broker settings"] .. "\n",
            type = "description"
        },
        brokerGoal = {
            order = 9,
            name = L["Display Goal"],
            type = "select",
            width = standardControlWidth,
            desc = L["The goal to track in the data source"],
            values = {
                [_BattlePetCompletionist.Enums.Goal.COLLECT] = L["Broker Goal - Collect at least one"],
                [_BattlePetCompletionist.Enums.Goal.COLLECT_RARE] = L["Broker Goal - Collect at least one rare"],
                [_BattlePetCompletionist.Enums.Goal.COLLECT_MAX] = L["Broker Goal - Collect maximum amount"],
                [_BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE] = L["Broker Goal - Collect maximum amount rare"],
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
            name = L["Include goal text"],
            type = "toggle",
            desc = L["Add a suffix to the displayed text"],
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
            name = L["Header - Map pins"],
            type = "header"
        },
        mapPinsDescription = {
            order = 12,
            name = L["Description - Map pins settings"] .. "\n",
            type = "description"
        },
        mapPinsToInclude = {
            order = 13,
            name = L["Map pins to include"],
            type = "select",
            width = standardControlWidth,
            desc = L["Which map pins should be shown on the map"],
            values = {
                [_BattlePetCompletionist.Enums.MapPinFilter.ALL] = L["Map Pin Filter - All"],
                [_BattlePetCompletionist.Enums.MapPinFilter.MISSING] = L["Map Pin Filter - Missing"],
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_RARE] = L["Map Pin Filter - Not rare"],
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_COLLECTED] = L["Map Pin Filter - Not maximum amount collected"],
                [_BattlePetCompletionist.Enums.MapPinFilter.NAME_FILTER] = L["Map Pin Filter - Name filter"],
                [_BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_RARE] = L["Map Pin Filter - Not maximum rare collected"],
                [_BattlePetCompletionist.Enums.MapPinFilter.NONE] = L["Map Pin Filter - None"],
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
            name = L["Partial pet name"],
            type = "input",
            width = standardControlWidth,
            desc = L["Enter part the name to filter by"],
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
            name = L["Map pin size"],
            type = "select",
            width = standardControlWidth,
            desc = L["The size of the pins on the map"],
            values = {
                [_BattlePetCompletionist.Enums.MapPinSize.X_SMALL] = L["Map Pin Size - Extra small"],
                [_BattlePetCompletionist.Enums.MapPinSize.SMALL] = L["Map Pin Size - Small"],
                [_BattlePetCompletionist.Enums.MapPinSize.MEDIUM] = L["Map Pin Size - Medium"],
                [_BattlePetCompletionist.Enums.MapPinSize.LARGE] = L["Map Pin Size - Large"],
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
            name = L["Map pin icon type"],
            type = "select",
            width = standardControlWidth,
            desc = L["The kind of icon to show in the pins on the map"],
            values = {
                [_BattlePetCompletionist.Enums.MapPinIconType.PET] = L["Map Pin Icon Type - Pet Icon"],
                [_BattlePetCompletionist.Enums.MapPinIconType.FAMILY] = L["Map Pin Icon Type - Pet Family"],
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
            name = L["Map pin sources"],
            type = "multiselect",
            desc = L["The sources for pets to show on the map"],
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
            name = L["Header - Integrations"],
            type = "header"
        },
        integrationDescription = {
            order = 22,
            name = L["Description - Integration settings"] .. "\n",
            type = "description"
        },
        tomtomIntegrationEnabled = {
            order = 23,
            name = L["Tomtom"],
            type = "toggle",
            desc = L["SHIFT + left clicking a map pin creates a TomTom waypoint"],
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
            name = L["Header - Combat"],
            type = "header"
        },
        combatDescription = {
            order = 25,
            name = L["Description - Combat settings"] .. "\n",
            type = "description"
        },
        combatMode = {
            order = 26,
            name = L["Combat mode"],
            type = "select",
            width = standardControlWidth,
            desc = L["How to function when pet battles are started"],
            values = {
                [_BattlePetCompletionist.Enums.CombatMode.HELP_A_FRIEND] = L["Combat Mode - Help a Friend"],
                [_BattlePetCompletionist.Enums.CombatMode.FORFEIT] = L["Combat Mode - Forfeit"],
                [_BattlePetCompletionist.Enums.CombatMode.NONE] = L["Combat Mode - None"],
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
            name = L["Forfeit threshold"],
            type = "select",
            width = standardControlWidth,
            desc = L["The threshold for when to always suggest forfeit"],
            values = {
                [_BattlePetCompletionist.Enums.ForfeitThreshold.RARE] = L["Forfeit Threshold - Rare"],
                [_BattlePetCompletionist.Enums.ForfeitThreshold.UNCOMMON] = L["Forfeit Threshold - Uncommon"],
                [_BattlePetCompletionist.Enums.ForfeitThreshold.COMMON] = L["Forfeit Threshold - Common"],
                [_BattlePetCompletionist.Enums.ForfeitThreshold.POOR] = L["Forfeit Threshold - Poor"],
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
            name = L["Forfeit prompt unless"],
            type = "select",
            width = standardControlWidth,
            desc = L["The condition for when to not forfeit"],
            values = {
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.MISSING] = L["Forfeit Prompt Unless - Missing"],
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_RARE] = L["Forfeit Prompt Unless - Not rare"],
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_COLLECTED] = L["Forfeit Prompt Unless - Not maximum amount collected"],
                [_BattlePetCompletionist.Enums.ForfeitPromptUnless.NOT_MAX_RARE] = L["Forfeit Prompt Unless - Not maximum rare collected"],
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
    ConfigModule.OptionsFrame, ConfigModule.CategoryId = AceConfigDialog:AddToBlizOptions("BattlePetCompletionist_options", "Battle Pet Completionist")
    ConfigModule:RegisterChatCommand("bpcom", "ChatCommandOptions")
end

function ConfigModule:ChatCommandOptions(msg)
    Settings.OpenToCategory(ConfigModule.OptionsFrame.name)
end
