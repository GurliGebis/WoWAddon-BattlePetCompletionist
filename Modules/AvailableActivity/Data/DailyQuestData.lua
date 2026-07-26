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

    This has two arrays incase of variance later on by Blizzard.
    One is for World Quests and one is for Daily Quests

    The data is in a Multi-Layered Hash Table with format:
        EventID -- English name in comment for ease of maintaining
            PetHash of Pet NPC ID & Pet Species ID
                WoW Head Base URL: https://www.wowhead.com/npc=
                Add NPC ID and the display shows the Species ID

    Related API Calls [Return Details We Use]
        C_QuestLog.GetTitleForQuestID(questID) [title]
        C_TaskQuest.GetQuestTimeLeftMinutes(questID) [non-zero number, when available] -- daily quests
        C_PetJournal.GetNumPetsInJournal(petNpcID) [MaxAllowed, NumCollected]
        C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID) [LocalizedName]

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.dailyQuestPetData = {
    [32441] = { -- Thundering Pandaren Spirit
        pets = {
            { petNpcID = 68468, petSpeciesID = 1126 }, -- Pandaren Earth Spirit
        },
    },
    [32439] = { -- Flowing Pandaren Spirit
        pets = {
            { petNpcID = 66950, petSpeciesID = 868 }, -- Pandaren Water Spirit
        },
    },
    [32440] = { -- Whispering Pandaren Spirit
        pets = {
            { petNpcID = 68467, petSpeciesID = 1125 }, -- Pandaren Air Spirit
        },
    },
    [32434] = { -- Burning Pandaren Spirit
        pets = {
            { petNpcID = 68466, petSpeciesID = 1124 }, -- Pandaren Fire Spirit
        },
    },
    [37644] = { -- Mastering the Menagerie
        pets = {
            { petNpcID = 77021, petSpeciesID = 1385 }, -- Albino Chimaeraling
            { petNpcID = 78421, petSpeciesID = 1394 }, -- Weebomination
            { petNpcID = 87704, petSpeciesID = 1545 }, -- Firewing
            { petNpcID = 83588, petSpeciesID = 1434 }, -- Sun Sproutling
            { petNpcID = 83817, petSpeciesID = 1442 }, -- Ghastly Kid
            { petNpcID = 88300, petSpeciesID = 1568 }, -- Puddle Terror
            { petNpcID = 88367, petSpeciesID = 1570 }, -- Sunfire Kaliri
        },
    },
    [63435] = { -- Temple Throwdown
        pets = {
            { petNpcID = 176662, petSpeciesID = 3092 }, -- Squibbles
        },
    },
    [47895] = { -- Bert's Bots
        pets = {
            { petNpcID = 117340, petSpeciesID = 2001 }, -- Dibbler
        },
    },
    [11665] = { -- Crocolisks in the City
        pets = {
            { petNpcID = 24388, petSpeciesID = 163 }, -- Toothy
            { petNpcID = 24389, petSpeciesID = 164 }, -- Muckbreath
            { petNpcID = 26050, petSpeciesID = 173 }, -- Snarly
            { petNpcID = 26056, petSpeciesID = 174 }, -- Chuck
        },
    },
}
