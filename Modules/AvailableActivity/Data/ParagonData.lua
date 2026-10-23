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

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.paragonPetData = {
    [2045] = { -- Armies of Legionfall
        pets = {
            { petNpcID = 121715, petSpeciesID = 2050 }, -- Orphaned Felbat
        },
    },
    [2156] = { -- Talanji's Expedition
        pets = {
            { petNpcID = 149372, petSpeciesID = 2567 }, -- Crimson Bat Pup
        },
    },
    [2160] = { -- Proudmoore Admiralty
        pets = {
            { petNpcID = 149363, petSpeciesID = 2566 }, -- Albatross Hatchling
        },
    },
    [2161] = { -- Order of Embers
        pets = {
            { petNpcID = 149375, petSpeciesID = 2568 }, -- Cobalt Raven
        },
    },
    [2162] = { -- Storm's Wake
        pets = {
            { petNpcID = 149376, petSpeciesID = 2569 }, -- Violet Abyssal Eel
        },
    },
    [2407] = { -- The Ascended (Kyrian)
        pets = {
            { petNpcID = 175564, petSpeciesID = 3064 }, -- Larion Cub
        },
    },
    [2410] = { -- The Undying Army (Necrolords)
        pets = {
            { petNpcID = 172148, petSpeciesID = 2959 }, -- Micromancer
        },
    },
    [2413] = { -- Court of Harvesters (Venthyr)
        pets = {
            { petNpcID = 173502, petSpeciesID = 3006 }, -- Stoneskin Dredwing Pup
        },
    },
    [2415] = { -- Rajani
        pets = {
            { petNpcID = 162013, petSpeciesID = 2852 }, -- Jade Defender
        },
    },
    [2432] = { -- Ve'nari
        pets = {
            { petNpcID = 179242, petSpeciesID = 3133 }, -- Rook
        },
    },
    [2465] = { -- The Wild Hunt (Night Fae)
        pets = {
            { petNpcID = 171242, petSpeciesID = 2916 }, -- Hungry Burrower
        },
    },
    [2470] = { -- Death's Advance
        pets = {
            { petNpcID = 179252, petSpeciesID = 3137 }, -- Mosscoated Gromit
        },
    },
    [2770] = { -- Slayer's Duellum
        pets = {
            { petNpcID = 257695, petSpeciesID = 4981 }, -- Nova
        },
    },
}
