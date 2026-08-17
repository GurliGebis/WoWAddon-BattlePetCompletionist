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
        C_TaskQuest.IsActive(questID) [boolean true/false] -- world quests
        C_PetJournal.GetNumPetsInJournal(petNpcID) [MaxAllowed, NumCollected]
        C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID) [LocalizedName]

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.worldQuestPetData = {
    [59808] = { -- Quest: Muck It Up; Spawns Rare: Bog Beast; Pet Drop Chance: Primordial Bogling
        pets = {
            { petNpcID = 171121, petSpeciesID = 2896 }, -- Primordial Bogling
        },
    },
    [60654] = { -- Quest: Swarming Souls; Spawns Rare: Manifestation of Wrath; Pet Drop Chance: Wrathling
        pets = {
            { petNpcID = 171118, petSpeciesID = 2897 }, -- Wrathling
        },
    },
    [60655] = { -- Quest: A Stolen Stone Fiend; Talk to the NPC after for Key to get Dal
        pets = {
            { petNpcID = 171136, petSpeciesID = 2900 }, -- Dal
        },
    },
    [63543] = { -- Necrolord Maw Assault
        pets = {
            { petNpcID = 179008, petSpeciesID = 3098 }, -- Lil' Abom, have to craft from Necrolord Assault Items
            { petNpcID = 179171, petSpeciesID = 3114 }, -- Fodder, Random Reward from Necrolord Cache/Chest
        },
    },
    --[[[63822] = { -- Venthyr Maw Assault
        pets = {
        },
    },--]]
    [63823] = { -- Night Fae Maw Assault
        pets = {
            { petNpcID = 179025, petSpeciesID = 3099 }, -- Infused Etherwyrm, Random Reward from Night Fae Cache/Chest
            { petNpcID = 179180, petSpeciesID = 3116 }, -- Invasive Buzzer, Random Reward from Night Fae Cache/Chest
        },
    },
    [63824] = { -- Kyrian Maw Assault
        pets = {
            { petNpcID = 179083, petSpeciesID = 3101 }, -- Sly, from Kyrian Maw Assault Achievement "A Sly Fox"
            { petNpcID = 179132, petSpeciesID = 3103 }, -- Copperback Etherwyrm, Random Reward from Kyrian Cache/Chest
        },
    },
}
