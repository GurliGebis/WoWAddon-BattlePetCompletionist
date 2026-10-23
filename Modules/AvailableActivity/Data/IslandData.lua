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

    -----------------------------------------------------------------------

    This File is for Battle Pet Completionist.
    It is meant to help brainstorm the Implementation of the FR "Calendar
    Reminders" ... FR Link:
    https://github.com/GurliGebis/WoWAddon-BattlePetCompletionist/issues/86

    The data is in a Multi-Layered Hash Table with format:
        EventID -- English name in comment for ease of maintaining
            PetHash of Pet NPC ID & Pet Species ID
                WoW Head Base URL: https://www.wowhead.com/npc=
                Add NPC ID and the display shows the Species ID

    Related API Calls [Return Details We Use]
        C_QuestLog.GetTitleForQuestID(questID) [title]
        C_PetJournal.GetNumPetsInJournal(petNpcID) [MaxAllowed, NumCollected]
        C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID) [LocalizedName]

    This has the Island UI Map ID so we can denote which ones if one is selective

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.islandPetData = {
    [1501] = { -- Crestfall
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1036] = { -- The Dread Chain
        pets = {
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143810, petSpeciesID = 2468, islands = { 1036, 1032, 1034, 1037, } }, -- Laughing Stonekin
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143811, petSpeciesID = 2465, islands = { 1036, 1035, 1033, 981, 1037, } }, -- Playful Frostkin
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1336] = { -- Havenswood
        pets = {
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143794, petSpeciesID = 2445, islands = { 1336, 1337, 1033, } }, -- Scuttle
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1337] = { -- Jorundall
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143794, petSpeciesID = 2445, islands = { 1336, 1337, 1033, } }, -- Scuttle
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1035] = { -- Molten Cay
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143820, petSpeciesID = 2454, islands = { 1035, 1502, } }, -- Kunchong Hatchling
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143811, petSpeciesID = 2465, islands = { 1036, 1035, 1033, 981, 1037, } }, -- Playful Frostkin
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1033] = { -- The Rotting Mire
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143819, petSpeciesID = 2453, islands = { 1033, 981, 1037, } }, -- Juvenile Brineshell
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143811, petSpeciesID = 2465, islands = { 1036, 1035, 1033, 981, 1037, } }, -- Playful Frostkin
            { petNpcID = 143794, petSpeciesID = 2445, islands = { 1336, 1337, 1033, } }, -- Scuttle
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1032] = { -- Skittering Hollow
        pets = {
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143810, petSpeciesID = 2468, islands = { 1036, 1032, 1034, 1037, } }, -- Laughing Stonekin
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143822, petSpeciesID = 2460, islands = { 1032, } }, -- Voru'kar Leecher
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [1502] = { -- Snowblossom Village
        pets = {
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143820, petSpeciesID = 2454, islands = { 1035, 1502, } }, -- Kunchong Hatchling
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [981] = { -- Un'gol Ruins
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143819, petSpeciesID = 2453, islands = { 1033, 981, 1037, } }, -- Juvenile Brineshell
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143811, petSpeciesID = 2465, islands = { 1036, 1035, 1033, 981, 1037, } }, -- Playful Frostkin
        },
    },
    [1034] = { -- Verdant Wilds
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143810, petSpeciesID = 2468, islands = { 1036, 1032, 1034, 1037, } }, -- Laughing Stonekin
            { petNpcID = 143812, petSpeciesID = 2467, islands = { 1036, 1337, 1035, 1033, 981, 1034,  } }, -- Mischievous Zephyr
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
        },
    },
    [1037] = { -- Whispering Reef
        pets = {
            { petNpcID = 143796, petSpeciesID = 2456, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037 } }, -- Barnaby
            { petNpcID = 143795, petSpeciesID = 2455, islands = { 1501, 1337, 1035, 1033, 981, 1034, 1037, } }, -- Captain Nibs
            { petNpcID = 143821, petSpeciesID = 2457, islands = { 1037 } }, -- Coldlight Surfrunner
            { petNpcID = 143803, petSpeciesID = 2448, islands = { 1501, 1036, 1336, 1337, 1035, 1032, 1502, 981, 1034, 1037, } }, -- Craghoof Kid
            { petNpcID = 143819, petSpeciesID = 2453, islands = { 1033, 981, 1037, } }, -- Juvenile Brineshell
            { petNpcID = 143810, petSpeciesID = 2468, islands = { 1036, 1032, 1034, 1037, } }, -- Laughing Stonekin
            { petNpcID = 143818, petSpeciesID = 2458, islands = { 1501, 1336, 1337, 1035, 1033, 1032, 1502, 981, 1034, 1037, } }, -- Muskflank Calfling
            { petNpcID = 143798, petSpeciesID = 2462, islands = { 1036, 1035, 1033, 1502, 981, 1034, 1037, } }, -- Octopode Fry
            { petNpcID = 143811, petSpeciesID = 2465, islands = { 1036, 1035, 1033, 981, 1037, } }, -- Playful Frostkin
            { petNpcID = 143806, petSpeciesID = 2463, islands = { 1501, 1036, 1336, 1337, 1035, 1033, 1032, 1502, 1037,  } }, -- Sandshell Chitterer
        },
    },
    [-1] = { -- all islands
        pets = {
            { petNpcID = 143797, petSpeciesID = 2452, islands = { } }, -- Poro
            { petNpcID = 143799, petSpeciesID = 2461, islands = { } }, -- Inky
            { petNpcID = 143801, petSpeciesID = 2446, islands = { } }, -- Sparkleshell Sandcrawler
            { petNpcID = 143802, petSpeciesID = 2447, islands = { } }, -- Kindleweb Spiderling
            { petNpcID = 143804, petSpeciesID = 2449, islands = { } }, -- False Knucklebump
            { petNpcID = 143805, petSpeciesID = 2450, islands = { } }, -- Tinder Pup
            { petNpcID = 143807, petSpeciesID = 2464, islands = { } }, -- Deathsting Scorpid
            { petNpcID = 143808, petSpeciesID = 2469, islands = { } }, -- Thistlebrush Bud
            { petNpcID = 143809, petSpeciesID = 2466, islands = { } }, -- Giggling Flame
            { petNpcID = 143813, petSpeciesID = 2471, islands = { } }, -- Littlehoof
            { petNpcID = 143814, petSpeciesID = 2472, islands = { } }, -- Snapper
            { petNpcID = 143815, petSpeciesID = 2473, islands = { } }, -- Sunscale Hatchling
            { petNpcID = 143816, petSpeciesID = 2451, islands = { } }, -- Bloodstone Tunneler
            { petNpcID = 143817, petSpeciesID = 2459, islands = { } }, -- Snort
        },
    },
}
--[[
DataModule.ActivitiesData.islandData = {
    -- this is a reference only array and may be removed at any time.
    -- UI Map ID Reference: https://warcraft.wiki.gg/wiki/UiMapID
    -- Zone ID Reference: https://www.wowhead.com/zones
    { UIMapID = 1034, ZoneID = 9440, englishName="Verdant Wilds" },
    { UIMapID = 1033, ZoneID = 9466, englishName="The Rotting Mire" },
    { UIMapID = 981, ZoneID = 9469, englishName="Un'gol Ruins" },
    { UIMapID = 1035, ZoneID = 9496, englishName="Molten Cay" },
    { UIMapID = 1032, ZoneID = 9497, englishName="Skittering Hollow" },
    { UIMapID = 1502, ZoneID = 9540, englishName="Snowblossom Village" },
    { UIMapID = 1336, ZoneID = 9548, englishName="Havenswood" },
    { UIMapID = 1036, ZoneID = 9576, englishName="The Dread Chain" },
    { UIMapID = 1037, ZoneID = 9591, englishName="Whispering Reef" },
    { UIMapID = 1337, ZoneID = 9616, englishName="Jorundall" },
    { UIMapID = 1501, ZoneID = 10222, englishName="Crestfall" },
},
--]]
