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

DataModule.ActivitiesData.dailyQuestAchievementPetData = {
    [60956] = { -- Family Battler of Northrend
        petReward = { { petNpcID = 222342, petSpeciesID = 4475, } },-- Webbers
    },
    [9696] = { -- Family Familiar
        petReward = { { petNpcID = 112798, petSpeciesID = 1932, } }, -- Nightmare Lasher
    },
    [12100] = { -- Family Fighter
        petReward = { { petNpcID = 128146, petSpeciesID = 2113, } }, -- Felclaw Marsuul
    },
    [14879] = { -- Family Exorcist
        petReward = { { petNpcID = 175756, petSpeciesID = 3067, } }, -- Spriggan Trickster
    },
    [13279] = { -- Family Battler
        petReward = { { petNpcID = 147884, petSpeciesID = 2535, } }, -- Wicker Wraith
    },
    [40980] = { -- Family Battler of Khaz Algar
        petReward = { { petNpcID = 222574, petSpeciesID = 4490, } }, -- Fuzzy
    },
    [41551] = { -- Family Battler of Undermine
        petReward = { { petNpcID = 231469, petSpeciesID = 4631, } }, -- Foreman
    },
    [17934] = { -- Family Battler of Zaralek Cavern
        petReward = { { petNpcID = 189119, petSpeciesID = 3294, } }, -- Gerald
    },
    [16512] = { -- Family Battler of  the Dragon Isles
        petReward = { { petNpcID = 197969, petSpeciesID = 3406, } }, -- Lady Feathersworth
    },
    [61040] = { -- Family Battler of Eastern Kingdoms
        petReward = { { petNpcID = 204240, petSpeciesID = 3519, } }, -- Byrn
    },
    [61051] = { -- Family Battler of Kalimdor
        petReward = { { petNpcID = 254979, petSpeciesID = 4913, } }, -- Moon Darter
    },
    [62460] = { -- Family Battler of Outland
        petReward = { { petNpcID = 262210, petSpeciesID = 5026, } }, -- Lil'Kruul
    },
    [62461] = { -- Family Battler of Cataclysm
        petReward = { { petNpcID = 262220, petSpeciesID = 5027, } }, -- Furiostraza
    },
}
