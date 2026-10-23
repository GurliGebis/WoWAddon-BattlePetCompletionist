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

DataModule.ActivitiesData.TimedZoneActivityPetData = {
--[[
    This outlines how to make an entry.
    [UIMapID] = { -- English Map Name for Upkeep Ease
        requireTimer = xxxx, -- Does this require a timer? (true/false) NOTE BENE: THIS EXPECTS WE WILL NOT HAVE BOTH TYPES ON THE SAME MAP!
        events = {
            [eventData] = { -- one of these sections per event in map zone; this should be the event id or "something descriptive"
                mapZone = x, -- timer zone number/area name (use 0/not applicable when an eventID is used instead)
                pets = {
                    { petNpcID = xxxxxx, petSpeciesID = xxxx }, -- name and other notes for upkeep (one line per associated pet)
                },
            },
        },
    }
--]]
    [1527] = { -- Uldum
        requireTimer = false, -- No
        events = {
            [56308] = { -- Assault: Aqir Unearthed (BFA - Minor Assault)
                mapZone = 0, -- N/A
                pets = {
                    { petNpcID = 161997, petSpeciesID = 2847 }, -- Rotbreath (from: Lord Aj'qirai (56340))
                    { petNpcID = 162004, petSpeciesID = 2848 }, -- Aqir Tunneler (from: Skikx'traz (58697))
                },
            },
            [57157] = { -- Assault: The Black Empire (BFA - Major Assault)
                mapZone = 0, -- N/A
                pets = {
                    { petNpcID = 162012, petSpeciesID = 2851 }, -- Wicked Lurker (from: Amalgamation of Flesh (58330) | Pyre of the Amalagamated One)
                },
            },
        },
    },
    [1530] = { -- Vale of Eternal Blossoms
        requireTimer = false, -- No
        events = {
            [56064] = { -- Assault: The Black Empire (BFA - Major Assault)
                mapZone = 0, -- N/A
                pets = {
                    { petNpcID = 161954, petSpeciesID = 2845 }, -- K'uddly (from: The Forgotten (57342))
                    { petNpcID = 161992, petSpeciesID = 2846 }, -- Corrupted Tentacle (from: Will of N'zoth (56303))
                },
            },
        },
    },
   [2133] = { -- Zaralek Caverns
        requireTimer = true, -- Yes
        events = {
            ["Glimmerogg"] = {
                mapZone = 1,
                pets = {
                    { petNpcID = 204303, petSpeciesID = 3533 }, -- Brullo the Strong/Brul
                    { petNpcID = 204339, petSpeciesID = 3541 }, -- Karokta/Ridged Shalewing
                    { petNpcID = 204359, petSpeciesID = 3548 }, -- Aquifon/Aquapo
                },
            },
            ["Loamm"] = {
                mapZone = 3,
                pets = {
                    { petNpcID = 204263, petSpeciesID = 3521 }, -- Klakatak/Lord Stantley
                    { petNpcID = 204343, petSpeciesID = 3545 }, -- Kob'rok/Salverun
                    { petNpcID = 204345, petSpeciesID = 3546 }, -- Kob'rok/Skaarn
                    { petNpcID = 204363, petSpeciesID = 3551 }, -- Underlight Queen/Teardrop Moth
                },
            },
        },
    },
    [1469] = { -- Vision of SW (used for both visions here)
        requireTimer = true, -- Yes
        events = {
            ["BFA Vision of SW"] = {
                mapZone = 1, -- timer zone number/area name (use 0/not applicable when an eventID is used instead)
                pets = {
                    { petNpcID = 161961, petSpeciesID = 2839 }, -- Void-Scarred Hare
                    { petNpcID = 161962, petSpeciesID = 2840 }, -- Void-Scarred Cat
                    { petNpcID = 161963, petSpeciesID = 2841 }, -- Void-Scarred Rat
                    { petNpcID = 161964, petSpeciesID = 2842 }, -- Anomalus
                },
            },
            ["BFA Vision of Org"] = {
                mapZone = 2, -- timer zone number/area name (use 0/not applicable when an eventID is used instead)
                pets = {
                    { petNpcID = 161959, petSpeciesID = 2838 }, -- C'Thuffer
                    { petNpcID = 160187, petSpeciesID = 2796 }, -- Void-Scarred Toad
                    { petNpcID = 161964, petSpeciesID = 2842 }, -- Anomalus
                    { petNpcID = 160196, petSpeciesID = 2797 }, -- Void-Scarred Pup
                },
            },
        },
    }
}
