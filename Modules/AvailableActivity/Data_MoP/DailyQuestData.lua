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
        C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) -- for account wide quests. note https://us.forums.blizzard.com/en/wow/t/warband-quest-api-returning-faulty-data/1916987
        C_QuestLog.IsQuestFlaggedCompleted(questID) -- for character only (testing shows it returns correctly for account...)
        C_QuestLog.IsAccountQuest(questID) -- determines if account wide quest
        C_PetJournal.GetNumPetsInJournal(petNpcID) [MaxAllowed, NumCollected]
        C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID) [LocalizedName]

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.dailyQuestPetData = {
    [11665] = { -- Crocolisks in the City
        pets = {
            { petNpcID = 24388, petSpeciesID = 163 }, -- Toothy
            { petNpcID = 24389, petSpeciesID = 164 }, -- Muckbreath
            { petNpcID = 26050, petSpeciesID = 173 }, -- Snarly
            { petNpcID = 26056, petSpeciesID = 174 }, -- Chuck
        },
    },
    [31752] = { -- Blingtron 4000
        pets = {
            { petNpcID = 73011, petSpeciesID = 1320 }, -- Lil' Bling
        },
    },
    --[[ [32434] = { -- Burning Pandaren Spirit -- currently returning nil. need to know why!
        pets = {
            { petNpcID = 68466, petSpeciesID = 1124 }, -- Pandaren Fire Spirit -- verified this line is right
        },
    }, --]]
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
    [32441] = { -- Thundering Pandaren Spirit
        pets = {
            { petNpcID = 68468, petSpeciesID = 1126 }, -- Pandaren Earth Spirit
        },
    },
    [32604] = { -- Beasts of Fable Book I
        pets = {
            { petNpcID = 69893, petSpeciesID = 1197 }, -- Snowy Panda
            { petNpcID = 69892, petSpeciesID = 1198 }, -- Mountain Panda
            { petNpcID = 69891, petSpeciesID = 1196 }, -- Sunfur Panda
        },
    },
    [32868] = { -- Beasts of Fable Book II
        pets = {
            { petNpcID = 69893, petSpeciesID = 1197 }, -- Snowy Panda
            { petNpcID = 69892, petSpeciesID = 1198 }, -- Mountain Panda
            { petNpcID = 69891, petSpeciesID = 1196 }, -- Sunfur Panda
        },
    },
    [32869] = { -- Beasts of Fable Book III
        pets = {
            { petNpcID = 69893, petSpeciesID = 1197 }, -- Snowy Panda
            { petNpcID = 69892, petSpeciesID = 1198 }, -- Mountain Panda
            { petNpcID = 69891, petSpeciesID = 1196 }, -- Sunfur Panda
        },
    },
}
