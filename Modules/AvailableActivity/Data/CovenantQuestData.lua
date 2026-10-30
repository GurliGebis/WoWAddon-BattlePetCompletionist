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

DataModule.ActivitiesData.covenantPetData = {
    [60418] = { -- A Call to Bastion (Night Fae)
        pets = {
            { petNpcID = 171710, petSpeciesID = 2938 }, -- Gilded Wader
        },
    },
    [60426] = { -- A Call to Bastion (Necrolord)
        pets = {
            { petNpcID = 171710, petSpeciesID = 2938 }, -- Gilded Wader
        },
    },
    [60427] = { -- A Call to Bastion (Venthyr)
        pets = {
            { petNpcID = 171710, petSpeciesID = 2938 }, -- Gilded Wader
        },
    },
    [62692] = { -- A Call to Bastion (Kyrian)
        pets = {
            { petNpcID = 171710, petSpeciesID = 2938 }, -- Gilded Wader
        },
    },
    [60420] = { -- A Call to Maldraxxus (Night Fae)
        pets = {
            { petNpcID = 171987, petSpeciesID = 2949 }, -- Skittering Venomspitter
            { petNpcID = 172132, petSpeciesID = 2952 }, -- Bubbling Pustule
        },
    },
    [62694] = { -- A Call to Maldraxxus (Necrolord)
        pets = {
            { petNpcID = 171987, petSpeciesID = 2949 }, -- Skittering Venomspitter
            { petNpcID = 172132, petSpeciesID = 2952 }, -- Bubbling Pustule
        },
    },
    [60431] = { -- A Call to Maldraxxus (Venthyr)
        pets = {
            { petNpcID = 171987, petSpeciesID = 2949 }, -- Skittering Venomspitter
            { petNpcID = 172132, petSpeciesID = 2952 }, -- Bubbling Pustule
        },
    },
    [60430] = { -- A Call to Maldraxxus (Kyrian)
        pets = {
            { petNpcID = 171987, petSpeciesID = 2949 }, -- Skittering Venomspitter
            { petNpcID = 172132, petSpeciesID = 2952 }, -- Bubbling Pustule
        },
    },
    [60421] = { -- A Call to Revendreth (Night Fae)
        pets = {
            { petNpcID = 171122, petSpeciesID = 2894 }, -- Burdened Soul
            { petNpcID = 171125, petSpeciesID = 2901 }, -- Trapped Stonefiend
        },
    },
    [60433] = { -- A Call to Revendreth (Necrolord)
        pets = {
            { petNpcID = 171122, petSpeciesID = 2894 }, -- Burdened Soul
            { petNpcID = 171125, petSpeciesID = 2901 }, -- Trapped Stonefiend
        },
    },
    [62691] = { -- A Call to Revendreth (Venthyr)
        pets = {
            { petNpcID = 171122, petSpeciesID = 2894 }, -- Burdened Soul
            { petNpcID = 171125, petSpeciesID = 2901 }, -- Trapped Stonefiend
        },
    },
    [60434] = { -- A Call to Revendreth (Kyrian)
        pets = {
            { petNpcID = 171122, petSpeciesID = 2894 }, -- Burdened Soul
            { petNpcID = 171125, petSpeciesID = 2901 }, -- Trapped Stonefiend
        },
    },
    [60388] = { -- Training Our Forces (Night Fae)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60404] = { -- Training Our Forces (Kyrian)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60410] = { -- Training Our Forces (Venthyr)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60408] = { -- Training Our Forces (Necrolord)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60403] = { -- Training in Ardenweald (Kyrian)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60401] = { -- Training in Ardenweald (Venthyr)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60402] = { -- Training in Ardenweald (Necrolord)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60387] = { -- Training in Bastion (Night Fae)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60406] = { -- Training in Bastion (Venthyr)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60405] = { -- Training in Bastion (Necrolord)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60407] = { -- Training in Maldraxxus (Kyrian)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60409] = { -- Training in Maldraxxus (Venthyr)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60386] = { -- Training in Maldraxxus (Night Fae)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60412] = { -- Training in Revendreth (Kyrian)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60385] = { -- Training in Revendreth (Night Fae)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60411] = { -- Training in Revendreth (Necrolord)
        pets = {
            { petNpcID = 175715, petSpeciesID = 3066 }, -- Lucy
        },
    },
    [60414] = { -- Rare Resources (Night Fae)
        pets = {
            { petNpcID = 171117, petSpeciesID = 2891 }, -- Blushing Spiderling
            { petNpcID = 171118, petSpeciesID = 2897 }, -- Wrathling
            { petNpcID = 171120, petSpeciesID = 2893 }, -- Animated Tome
            { petNpcID = 171231, petSpeciesID = 2920 }, -- Gorm Needler
            { petNpcID = 171239, petSpeciesID = 2908 }, -- Chirpy Valeshrieker
            { petNpcID = 171246, petSpeciesID = 2907 }, -- Rocky
            { petNpcID = 171565, petSpeciesID = 2925 }, -- Golden Cloudfeather
            { petNpcID = 171986, petSpeciesID = 2948 }, -- Boneweave Hatchling
            { petNpcID = 172134, petSpeciesID = 2953 }, -- Shy Melvin
            { petNpcID = 172136, petSpeciesID = 2955 }, -- Corpselouse Larva
            { petNpcID = 172137, petSpeciesID = 2956 }, -- Feasting Larva
            { petNpcID = 172139, petSpeciesID = 2957 }, -- Writhing Spine
            { petNpcID = 172155, petSpeciesID = 2964 }, -- Foulwing Buzzer
            { petNpcID = 173993, petSpeciesID = 3035 }, -- Lavender Nibbler
        },
    },
    [60415] = { -- Rare Resources (Kyrian)
        pets = {
            { petNpcID = 171117, petSpeciesID = 2891 }, -- Blushing Spiderling
            { petNpcID = 171118, petSpeciesID = 2897 }, -- Wrathling
            { petNpcID = 171120, petSpeciesID = 2893 }, -- Animated Tome
            { petNpcID = 171231, petSpeciesID = 2920 }, -- Gorm Needler
            { petNpcID = 171239, petSpeciesID = 2908 }, -- Chirpy Valeshrieker
            { petNpcID = 171246, petSpeciesID = 2907 }, -- Rocky
            { petNpcID = 171565, petSpeciesID = 2925 }, -- Golden Cloudfeather
            { petNpcID = 171986, petSpeciesID = 2948 }, -- Boneweave Hatchling
            { petNpcID = 172134, petSpeciesID = 2953 }, -- Shy Melvin
            { petNpcID = 172136, petSpeciesID = 2955 }, -- Corpselouse Larva
            { petNpcID = 172137, petSpeciesID = 2956 }, -- Feasting Larva
            { petNpcID = 172139, petSpeciesID = 2957 }, -- Writhing Spine
            { petNpcID = 172155, petSpeciesID = 2964 }, -- Foulwing Buzzer
            { petNpcID = 173993, petSpeciesID = 3035 }, -- Lavender Nibbler
        },
    },
    [60417] = { -- Rare Resources (Venthyr)
        pets = {
            { petNpcID = 171117, petSpeciesID = 2891 }, -- Blushing Spiderling
            { petNpcID = 171118, petSpeciesID = 2897 }, -- Wrathling
            { petNpcID = 171120, petSpeciesID = 2893 }, -- Animated Tome
            { petNpcID = 171231, petSpeciesID = 2920 }, -- Gorm Needler
            { petNpcID = 171239, petSpeciesID = 2908 }, -- Chirpy Valeshrieker
            { petNpcID = 171246, petSpeciesID = 2907 }, -- Rocky
            { petNpcID = 171565, petSpeciesID = 2925 }, -- Golden Cloudfeather
            { petNpcID = 171986, petSpeciesID = 2948 }, -- Boneweave Hatchling
            { petNpcID = 172134, petSpeciesID = 2953 }, -- Shy Melvin
            { petNpcID = 172136, petSpeciesID = 2955 }, -- Corpselouse Larva
            { petNpcID = 172137, petSpeciesID = 2956 }, -- Feasting Larva
            { petNpcID = 172139, petSpeciesID = 2957 }, -- Writhing Spine
            { petNpcID = 172155, petSpeciesID = 2964 }, -- Foulwing Buzzer
            { petNpcID = 173993, petSpeciesID = 3035 }, -- Lavender Nibbler
        },
    },
    [60416] = { -- Rare Resources (Necrolord)
        pets = {
            { petNpcID = 171117, petSpeciesID = 2891 }, -- Blushing Spiderling
            { petNpcID = 171118, petSpeciesID = 2897 }, -- Wrathling
            { petNpcID = 171120, petSpeciesID = 2893 }, -- Animated Tome
            { petNpcID = 171231, petSpeciesID = 2920 }, -- Gorm Needler
            { petNpcID = 171239, petSpeciesID = 2908 }, -- Chirpy Valeshrieker
            { petNpcID = 171246, petSpeciesID = 2907 }, -- Rocky
            { petNpcID = 171565, petSpeciesID = 2925 }, -- Golden Cloudfeather
            { petNpcID = 171986, petSpeciesID = 2948 }, -- Boneweave Hatchling
            { petNpcID = 172134, petSpeciesID = 2953 }, -- Shy Melvin
            { petNpcID = 172136, petSpeciesID = 2955 }, -- Corpselouse Larva
            { petNpcID = 172137, petSpeciesID = 2956 }, -- Feasting Larva
            { petNpcID = 172139, petSpeciesID = 2957 }, -- Writhing Spine
            { petNpcID = 172155, petSpeciesID = 2964 }, -- Foulwing Buzzer
            { petNpcID = 173993, petSpeciesID = 3035 }, -- Lavender Nibbler
        },
    },
}
