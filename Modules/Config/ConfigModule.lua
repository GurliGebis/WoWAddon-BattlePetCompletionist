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

BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
ConfigModule = BattlePetCompletionist:NewModule("ConfigModule", "AceConsole-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local petSources = {
    [1] = BATTLE_PET_SOURCE_1,
    [2] = BATTLE_PET_SOURCE_2,
    [3] = BATTLE_PET_SOURCE_3,
    [4] = BATTLE_PET_SOURCE_4,
    [5] = BATTLE_PET_SOURCE_5,
    [7] = BATTLE_PET_SOURCE_7
}

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
                return ConfigModule.AceDB.profile.petCageTooltipEnabled
            end,
            set = function()
                ConfigModule.AceDB.profile.petCageTooltipEnabled = not ConfigModule.AceDB.profile.petCageTooltipEnabled
            end
        },
        petBattleUnknownNotifyEnabled = {
            order = 4,
            name = "Show notification when uncollected pets are in the enemy team.",
            type = "toggle",
            desc = "Show a notification window when one or more uncollected pets can be captured",
            width = "full",
            get = function()
                return ConfigModule.AceDB.profile.petBattleUnknownNotifyEnabled
            end,
            set = function()
                ConfigModule.AceDB.profile.petBattleUnknownNotifyEnabled = not ConfigModule.AceDB.profile.petBattleUnknownNotifyEnabled
            end
        },
        minimapHeader = {
            order = 5,
            name = "Minimap",
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
                return ConfigModule.AceDB.profile.minimapIconEnabled
            end,
            set = function()
                ConfigModule.AceDB.profile.minimapIconEnabled = not ConfigModule.AceDB.profile.minimapIconEnabled

                MinimapModule = BattlePetCompletionist:GetModule("MinimapModule")
                MinimapModule:UpdateMinimap()
            end
        },
        mapPinsHeader = {
            order = 8,
            name = "Map pins",
            type = "header"
        },
        mapPinsDescription = {
            order = 9,
            name = "Map pins settings" .. "\n",
            type = "description"
        },
        mapPinsToInclude = {
            order = 10,
            name = "Map pins to include",
            type = "select",
            desc = "Which map pins should be shown on the map.",
            values = {
                T1ALL = "All",
                T2MISSING = "Missing",
                T3NOTRARE = "Not Rare",
                T5NOTMAXCOLLECTED = "Not maximum amount collected",
                T6NAMEFILTER = "Name filter",
                T4NONE = "None"
            },
            get = function()
                return ConfigModule.AceDB.profile.mapPinsToInclude
            end,
            set = function(_, value)
                if value == "T4NONE" and ConfigModule.AceDB.profile.mapPinsToInclude ~= "T4NONE" then
                    -- Save the value from before "None" was selected, so we can switch to that if enabled from the map dropdown.
                    ConfigModule.AceDB.profile.mapPinsToIncludeOriginal = ConfigModule.AceDB.profile.mapPinsToInclude
                end
                ConfigModule.AceDB.profile.mapPinsToInclude = value
                MapModule:UpdateWorldMap()
            end
        },
        mapPinsFilter = {
            order = 11,
            name = "Partial pet name",
            type = "input",
            desc = "Enter part the name to filter by",
            get = function()
                return ConfigModule.AceDB.profile.mapPinsFilter
            end,
            set = function(_, value)
                ConfigModule.AceDB.profile.mapPinsFilter = value
                MapModule:UpdateWorldMap()
            end
        },
        spacer1 = {
            order = 12,
            name = "",
            type = "description"
        },
        mapPinSize = {
            order = 13,
            name = "Map pin size",
            type = "select",
            desc = "The size of the pins on the map.",
            values = {
                S1 = "Small",
                S2 = "Medium",
                S3 = "Large"
            },
            get = function()
                return ConfigModule.AceDB.profile.mapPinSize
            end,
            set = function(_, value)
                ConfigModule.AceDB.profile.mapPinSize = value
            end
        },
        spacer2 = {
            order = 14,
            name = "",
            type = "description"
        },
        mapPinIconType = {
            order = 15,
            name = "Map pin icon type",
            type = "select",
            desc = "The kind of icon to show in the pins on the map.",
            values = {
                T1PET = "Pet Icon",
                T2FAMILY = "Pet Family"
            },
            get = function()
                return ConfigModule.AceDB.profile.mapPinIconType
            end,
            set = function(_, value)
                ConfigModule.AceDB.profile.mapPinIconType = value
            end
        },
        spacer3 = {
            order = 16,
            name = "",
            type = "description"
        },
        mapPinSources = {
            order = 17,
            name = "Map pin sources",
            type = "multiselect",
            desc = "The sources for pets to show on the map.",
            values = petSources,
            get = function(_, key)
                return ConfigModule.AceDB.profile.mapPinSources[key]
            end,
            set = function(_, key, value)
                ConfigModule.AceDB.profile.mapPinSources[key] = value
            end
        },
        integrationHeader = {
            order = 18,
            name = "Integrations",
            type = "header"
        },
        integrationDescription = {
            order = 19,
            name = "Integration settings" .. "\n",
            type = "description"
        },
        tomtomIntegrationEnabled = {
            order = 20,
            name = "Tomtom",
            type = "toggle",
            desc = "SHIFT + left clicking a map pin creates a TomTom waypoint.",
            width = "full",
            get = function()
                return ConfigModule.AceDB.profile.tomtomIntegration
            end,
            set = function()
                ConfigModule.AceDB.profile.tomtomIntegration = not ConfigModule.AceDB.profile.tomtomIntegration
            end
        },
        combatHeader = {
            order = 21,
            name = "Combat",
            type = "header"
        },
        combatDescription = {
            order = 22,
            name = "Combat settings" .. "\n",
            type = "description"
        },
        combatMode = {
            order = 23,
            name = "Combat mode",
            type = "select",
            desc = "How to function when pet battles are started",
            values = {
                V1HAF = "Help a Friend",
                V2FORFEIT = "Forfeit",
                V3NONE = "None"
            },
            get = function()
                return ConfigModule.AceDB.profile.combatMode
            end,
            set = function(_, value)
                ConfigModule.AceDB.profile.combatMode = value
            end
        },
        forfeitThreshold = {
            order = 24,
            name = "Forfeit threshold",
            type = "select",
            desc = "The threshold for when to always suggest forfeit.",
            values = {
                C1BLUE = "Rare",
                C2GREEN = "Uncommon",
                C3WHITE = "Common",
                C4GREY = "Poor"
            },
            get = function()
                return ConfigModule.AceDB.profile.forfeitThreshold
            end,
            set = function(_, value)
                ConfigModule.AceDB.profile.forfeitThreshold = value
            end
        },
    },
}

local defaultOptions = {
    profile = {
        petCageTooltipEnabled = true,
        petBattleUnknownNotifyEnabled = true,
        mapPinSize = "S1",
        mapPinsToInclude = "T1ALL",
        mapPinsToIncludeOriginal = "T1ALL",
        mapPinIconType = "T1PET",
        mapPinsFilter = "",
        mapPinSources = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [7] = true
        },
        minimapIconEnabled = true,
        tomtomIntegration = true,
        combatMode = "V1HAF",
        forfeitThreshold = "C1BLUE"
    }
}

function ConfigModule:OnInitialize()
    ConfigModule.AceDB = LibStub("AceDB-3.0"):New("BattlePetCompletionistDB", defaultOptions, true)

    AceConfig:RegisterOptionsTable("BattlePetCompletionist_options", options)
    ConfigModule.OptionsFrame = AceConfigDialog:AddToBlizOptions("BattlePetCompletionist_options", "Battle Pet Completionist")

    ConfigModule:RegisterChatCommand("bpcom", "ChatCommandOptions")
end

function ConfigModule:ChatCommandOptions(msg)
    InterfaceOptionsFrame_OpenToCategory(ConfigModule.OptionsFrame)
end

function ConfigModule:IsPetCageTooltipEnabled()
    return ConfigModule.AceDB.profile.petCageTooltipEnabled
end

function ConfigModule:IsPetBattleUnknownNotifyEnabled()
    return ConfigModule.AceDB.profile.petBattleUnknownNotifyEnabled
end

function ConfigModule:GetCombatMode()
    return strsub(ConfigModule.AceDB.profile.combatMode, 3)
end

function ConfigModule:GetForfeitThreshold()
    return strsub(ConfigModule.AceDB.profile.forfeitThreshold, 3)
end

function ConfigModule:GetMapPinsIconType()
    if ConfigModule.AceDB.profile.mapPinIconType == "T1PET" then
        return "PET"
    else
        return "FAMILY"
    end
end

function ConfigModule:GetMapPinScale()
    local scaleMap = {
        S1 = 1.0,
        S2 = 1.2,
        S3 = 1.4
    }

    return scaleMap[ConfigModule.AceDB.profile.mapPinSize]
end

function ConfigModule:GetMapPinSources()
    local sources = {}

    for key, value in pairs(petSources) do
        if ConfigModule.AceDB.profile.mapPinSources[key] then
            table.insert(sources, value)
        end
    end

    return sources
end
