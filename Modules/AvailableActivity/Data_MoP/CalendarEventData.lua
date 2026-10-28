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

    Holiday ID Source: https://www.wowhead.com/events
    Pet to Holiday Research Starter:
        https://www.warcraftpets.com/wow-pets/filter/
    Instant Level 25 Stone:
        https://www.wowhead.com/item=122457/ultimate-battle-training-stone

    WoW Head has two IDs for Legion (1263/1271) & Shadowlands (1703/1704).
    We need to verify the correct one. This command while they are running
    will verify the Event ID:
    /run a=C_DateAndTime.GetCurrentCalendarTime(); b=C_Calendar.GetNumDayEvents(0,a["monthDay"]); for c=0, b do d=C_Calendar.GetDayEvent(0,a["monthDay"],c); if d then print(d["eventID"] .. " is the id for " .. d["title"]) end end
    
    this can check up to roughly 4 weeks out.
    /run e=0; a=1; b=C_Calendar.GetNumDayEvents(e,a); for c=0, b do d=C_Calendar.GetDayEvent(e,a,c); if d then print(d["eventID"] .. " is the id for " .. d["title"]) end end
    
    Legion Verified on xxxx xx xx as
    Shadowlands Verified on 2026 07 16 as 1703
    As of 2026 08 07 it seems some events have regional IDs. This means
    both are needed for these IDs
    
    Unable to find Pet Rewards associated with Cataclysm, Warlords of
    Draenor, & Legion TimeWalking.

    The data is in a Multi-Layered Hash Table with format:
        EventID -- English name in comment for ease of maintaining
            PetHash of Pet NPC ID & Pet Species ID
                WoW Head Base URL: https://www.wowhead.com/npc=
                Add NPC ID and the display shows the Species ID

    Related API Calls [Return Details We Use]
        C_Calendar.GetDayEvent(0,DayOfMonth,EventNumber) [eventID, title]
        C_PetJournal.GetNumPetsInJournal(petNpcID) [MaxAllowed, NumCollected]
        C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID) [LocalizedName]

    -----------------------------------------------------------------------

--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:GetModule("DataModule")

DataModule.ActivitiesData.calendarEventPetData = {
    [141] = { -- Feast of Winter Veil
        pets = {
            { petNpcID = 15698, petSpeciesID = 119 }, -- Father Winter's Helper
            { petNpcID = 15705, petSpeciesID = 120 }, -- Winter's Little Helper
            { petNpcID = 15706, petSpeciesID = 118 }, -- Winter Reindeer
            { petNpcID = 15710, petSpeciesID = 117 }, -- Tiny Snowman
            { petNpcID = 24968, petSpeciesID = 191 }, -- Clockwork Rocket Bot
            { petNpcID = 40295, petSpeciesID = 254 }, -- Blue Clockwork Rocket Bot
            { petNpcID = 55215, petSpeciesID = 337 }, -- Lumpy
            { petNpcID = 73741, petSpeciesID = 1349 }, -- Rotten Little Helper
        },
    },
    [181] = { -- Noblegarden
        pets = {
            { petNpcID = 32791, petSpeciesID = 200 }, -- Spring Rabbit
        },
    },
    [201] = { -- Children's Week
        pets = {
            { petNpcID = 16547, petSpeciesID = 125 }, -- Speedy
            { petNpcID = 16548, petSpeciesID = 126 }, -- Mr. Wiggles
            { petNpcID = 16549, petSpeciesID = 127 }, -- Whiskers the Rat
            { petNpcID = 23231, petSpeciesID = 157 }, -- Willy
            { petNpcID = 23258, petSpeciesID = 158 }, -- Egbert
            { petNpcID = 23266, petSpeciesID = 159 }, -- Peanut
            { petNpcID = 33529, petSpeciesID = 226 }, -- Curious Wolvar Pup
            { petNpcID = 33530, petSpeciesID = 225 }, -- Curious Oracle Hatchling
            { petNpcID = 51635, petSpeciesID = 289 }, -- Scooter the Snail
            { petNpcID = 53048, petSpeciesID = 308 }, -- Legs
        },
    },
    [324] = { -- Hallow's End
        pets = {
            { petNpcID = 23909, petSpeciesID = 162 }, -- Sinister Squashling
            { petNpcID = 53884, petSpeciesID = 319 }, -- Feline Familiar
            { petNpcID = 54128, petSpeciesID = 321 }, -- Creepy Crate
        },
    },
    [327] = { -- Lunar Festival
        pets = {
            { petNpcID = 55571, petSpeciesID = 341 }, -- Lunar Lantern
            { petNpcID = 55574, petSpeciesID = 342 }, -- Festival Lantern
        },
    },
    [341] = { -- Midsummer
        pets = {
            { petNpcID = 16701, petSpeciesID = 128 }, -- Spirit of Summer
            { petNpcID = 40198, petSpeciesID = 253 }, -- Frigid Frostling
        },
    },
    [372] = { -- Brewfest
        pets = {
            { petNpcID = 22943, petSpeciesID = 153 }, -- Wolpertinger
            { petNpcID = 24753, petSpeciesID = 166 }, -- Pint-Sized Pachyderm
        },
    },
    [404] = { -- Pilgrim's Bounty
        pets = {
            { petNpcID = 32818, petSpeciesID = 201 }, -- Plump Turkey
        },
    },
    [409] = { -- Day of the Dead
        pets = {
            { petNpcID = 34770, petSpeciesID = 1351 }, -- Macabre Marionette
        },
    },
    [423] = { -- Love is in the Air
        pets = {
            { petNpcID = 16085, petSpeciesID = 122 }, -- Peddlefeet
            { petNpcID = 38374, petSpeciesID = 251 }, -- Toxic Wasteling
        },
    },
    [479] = { -- Darkmoon Faire
        pets = {
            { petNpcID = 7549, petSpeciesID = 65 }, -- Tree Frog
            { petNpcID = 7550, petSpeciesID = 64 }, -- Wood Frog
            { petNpcID = 14878, petSpeciesID = 106 }, -- Jubling
            { petNpcID = 54487, petSpeciesID = 335 }, -- Darkmoon Turtle
            { petNpcID = 54491, petSpeciesID = 330 }, -- Darkmoon Monkey
            { petNpcID = 55187, petSpeciesID = 336 }, -- Darkmoon Balloon
            { petNpcID = 55356, petSpeciesID = 338 }, -- Darkmoon Tonk
            { petNpcID = 55367, petSpeciesID = 339 }, -- Darkmoon Zeppelin
            { petNpcID = 55386, petSpeciesID = 340 }, -- Sea Pony
            { petNpcID = 56031, petSpeciesID = 343 }, -- Darkmoon Cub
            { petNpcID = 59358, petSpeciesID = 848 }, -- Darkmoon Rabbit
            { petNpcID = 67319, petSpeciesID = 1061 }, -- Darkmoon Hatchling
            { petNpcID = 67332, petSpeciesID = 1063 }, -- Darkmoon Eye
            { petNpcID = 67329, petSpeciesID = 1062 }, -- Darkmoon Glowfly
            { petNpcID = 67443, petSpeciesID = 1068 }, -- Crow
            { petNpcID = 72160, petSpeciesID = 1276 }, -- Moon Moon
        },
    },
}
