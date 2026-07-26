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
            { petNpcID = 97229, petSpeciesID = 1725 }, -- Grumpling
            { petNpcID = 128156, petSpeciesID = 2114 }, -- Globe Yeti
            { petNpcID = 151780, petSpeciesID = 2622 }, -- Jingles
            { petNpcID = 233564, petSpeciesID = 4691 }, -- Grunch
            { petNpcID = 233965, petSpeciesID = 4694 }, -- Portenous Present
            { petNpcID = 245616, petSpeciesID = 4851 }, -- Tiny Snow Buddy
        },
    },
    [181] = { -- Noblegarden
        pets = {
            { petNpcID = 32791, petSpeciesID = 200 }, -- Spring Rabbit
            { petNpcID = 33975, petSpeciesID = 1943 }, -- Noblegarden Bunny
            { petNpcID = 85773, petSpeciesID = 1514 }, -- Mystical Spring Bouquet
            { petNpcID = 215565, petSpeciesID = 4409 }, -- Lovely Duckling
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
            { petNpcID = 150098, petSpeciesID = 2575 }, -- Mr. Crabs
            { petNpcID = 150119, petSpeciesID = 2576 }, -- Beakbert
            { petNpcID = 150120, petSpeciesID = 2577 }, -- Froglet
            { petNpcID = 185425, petSpeciesID = 3245 }, -- Helpful Workshop Bot
            { petNpcID = 222204, petSpeciesID = 4466 }, -- Argos
            { petNpcID = 231466, petSpeciesID = 4635 }, -- Goggles
            { petNpcID = 150126, petSpeciesID = 2578 }, -- Scaley
        },
    },
    [324] = { -- Hallow's End
        pets = {
            { petNpcID = 23909, petSpeciesID = 162 }, -- Sinister Squashling
            { petNpcID = 53884, petSpeciesID = 319 }, -- Feline Familiar
            { petNpcID = 54128, petSpeciesID = 321 }, -- Creepy Crate
            { petNpcID = 86061, petSpeciesID = 1521 }, -- Cursed Birman
            { petNpcID = 86067, petSpeciesID = 1523 }, -- Widget the Departed
            { petNpcID = 97324, petSpeciesID = 1730 }, -- Spectral Spinner
            { petNpcID = 97568, petSpeciesID = 1741 }, -- Ghastly Rat
            { petNpcID = 97569, petSpeciesID = 1740 }, -- Ghost Maggot
            { petNpcID = 117341, petSpeciesID = 2002 }, -- Naxxy
            { petNpcID = 203463, petSpeciesID = 3491 }, -- Arfus
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
            { petNpcID = 85872, petSpeciesID = 1517 }, -- Blazing Cindercrawler
            { petNpcID = 114543, petSpeciesID = 1949 }, -- Igneous Flameling
        },
    },
    [372] = { -- Brewfest
        pets = {
            { petNpcID = 22943, petSpeciesID = 153 }, -- Wolpertinger
            { petNpcID = 24753, petSpeciesID = 166 }, -- Pint-Sized Pachyderm
            { petNpcID = 85994, petSpeciesID = 1518 }, -- Stout Alemental
        },
    },
    [404] = { -- Pilgrim's Bounty
        pets = {
            { petNpcID = 32818, petSpeciesID = 201 }, -- Plump Turkey
            { petNpcID = 85846, petSpeciesID = 1516 }, -- Bush Chicken
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
            { petNpcID = 85710, petSpeciesID = 1511 }, -- Lovebird Hatchling
            { petNpcID = 204360, petSpeciesID = 3549 }, -- Heartseeker Moth
            { petNpcID = 234131, petSpeciesID = 4704 }, -- Living Rose
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
            { petNpcID = 76873, petSpeciesID = 1384 }, -- Hogs
            { petNpcID = 85527, petSpeciesID = 1478 }, -- Syd the Squid
            { petNpcID = 90345, petSpeciesID = 1636 }, -- Race MiniZep
            { petNpcID = 93808, petSpeciesID = 1665 }, -- Ghostshell Crab
            { petNpcID = 93814, petSpeciesID = 1666 }, -- Blorp
            { petNpcID = 145946, petSpeciesID = 2484 }, -- Horse Balloon
            { petNpcID = 145947, petSpeciesID = 2483 }, -- Murloc Balloon
            { petNpcID = 145948, petSpeciesID = 2482 }, -- Wolf Balloon
        },
    },
    [559] = { -- Outland (aka The Burning Crusade) Timewalking
        pets = {
            { petNpcID = 232585, petSpeciesID = 4689 }, -- Karazhan Syphoner
        },
    },
    [562] = { -- Northrend (aka Wrath of the Lich King) Timewalking
        pets = {
            { petNpcID = 232579, petSpeciesID = 4686 }, -- Specter
        },
    },
    [565] = { -- Pet Battle Bonus Week
        pets = {
            { petNpcID = 122457, petSpeciesID = 122457 }, -- Ultimate Battle-Training Stone NOTE: THIS IS AN ITEM ID, NOT NPC ID!!
        },
    },
    -- [587] = {}, -- Cataclysm Timewalking; does not currently have pets
    [643] = { -- Mists of Pandaria Timewalking
        pets = {
            { petNpcID = 118060, petSpeciesID = 2017 }, -- Infinite Hatchling
            { petNpcID = 118063, petSpeciesID = 2018 }, -- Paradox Spirit
        },
    },
    -- [1056] = {}, -- Warlords of Draenor; does not currently have pets
    -- [1263] = {}, -- Legion Timewalking; does not currently have pets
    -- [1271] = {}, -- Legion Timewalking; does not currently have pets
    [1508] = { -- Classic (aka Vanilla) Timewalking
        pets = {
            { petNpcID = 224915, petSpeciesID = 4592 }, -- Misty
            { petNpcID = 224916, petSpeciesID = 4593 }, -- Craggles
        },
    },
    [1669] = { -- Battle for Azeroth Timewalking
        pets = {
            { petNpcID = 245545, petSpeciesID = 4849 }, -- Flotsam Harvester
            { petNpcID = 245647, petSpeciesID = 4852 }, -- Lil' Daz'ti
        },
    },
    [1703] = { -- Shadowlands Timewalking
        pets = {
            { petNpcID = 253374, petSpeciesID = 4911 }, -- P.O.S.T. Assistant
        },
    },
    [1704] = { -- Shadowlands Timewalking; Alternate ID in system
        pets = {
            { petNpcID = 253374, petSpeciesID = 4911 }, -- P.O.S.T. Assistant
        },
    },
    [1722] = { -- Dragonflight Timewalking
        pets = {
            { petNpcID = 256080, petSpeciesID = 4949 }, -- Shadowflame Remnant
        },
    },
}
