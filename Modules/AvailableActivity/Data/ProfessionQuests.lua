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

potentially useful note: factionGroup = GetQuestFactionGroup(questID)
	0 = both
	1 = alliance
	2 = horde

--]]

    --[[
        THIS DATA IS NOT LIVE AS THE QUEST POOLS ARE AN ISSUE.
        IT IS NOT CURRENTLY POSSIBLE TO TELL WHICH QUESTS ARE TRUELY ACTIVE.
        This conundrum is under investigation. This data is compiled for future addition.
    --]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.poolQuestPetData = {
    pool = {
        questPool = "Fishing Quests",
        aQuestIDs = { 29344, 29342, 29343, 29347, 29321, 26414, 29359, 26536, 26442, 26488, 29324, 29350, 29323, 26420, 29325, }, -- calssic/alliance
        hQuestIDs = { 29346, 26557, 29361, 29543, 29317, 29322, 29354, 29345, 26588, 29349, 26572, 26556, 29320, 29348, 29319, }, -- classic/horde
        nQuestIDs = { 13830, 13832, 13833, 13834, 13836 }, -- northrend/neutral
        pets = { { petNpcID = 33226, petSpeciesID = 211 }, }, -- strand crawler
    },
}
