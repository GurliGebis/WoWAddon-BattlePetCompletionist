--[[
    Copyright (C) 2023 GurliGebis

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
]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DataModule = BattlePetCompletionist:NewModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local LibPetJournal = LibStub('LibPetJournal-2.0')

local function DoesPetMatchSourceFilters(speciesId)
    local petSource = DataModule:GetPetSource(speciesId)

    local enabledSources = DBModule:GetMapPinSources()

    for _, v in ipairs(enabledSources) do
        if v == petSource then
            return true
        end
    end

    return false
end

function DataModule:GetPetsInMap(mapId)
    return DataModule.PetData[mapId]
end

function DataModule:ShouldPetBeShown(speciesId)
    -- Apply source filters first so that later settings can't forget to take them into account
    if not DoesPetMatchSourceFilters(speciesId) then
        return false
    end

    local profile = DBModule:GetProfile()

    if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.ALL then
        return true
    end

    if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NONE then
        return false
    end

    local rareQuality = 4 -- Rare / Blue
    -- Filter species based on pet journal entries
    local noMatchResult = true
    for _, petId in LibPetJournal:IteratePetIDs() do
        local speciesIdFromJournal, _, _, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(petId)

        if speciesIdFromJournal == speciesId then
            local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
            local quality = select(5, C_PetJournal.GetPetStats(petId))

            if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.MISSING then
                return numCollected < 1
            end

            if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NOT_RARE then
                if (quality >= rareQuality) then
                    return false
                end
            end

            if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_COLLECTED then
                return numCollected < limit
            end

            if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_RARE then
                if numCollected < limit then
                    return true
                end
                -- Since we're at limit, we want to show if any of the pets are less than rare.
                -- We can't determine that until we've gone through all of them.
                if quality < rareQuality then
                    return true
                end
                noMatchResult = false
            end

            if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NAME_FILTER then
                if profile.mapPinsFilter == "" then
                    -- Name filter has been selected, but the filter text box is empty
                    -- So we just return true for all pets.
                    return true
                end
                
                -- Since string.find is case sensitive, we convert everything to lowercase first.
                local loweredTextBoxValue = string.lower(profile.mapPinsFilter)
                local loweredPetName = string.lower(petName)

                return string.find(loweredPetName, loweredTextBoxValue)
            end
        end
    end

    return noMatchResult
end

function DataModule:GetOwnedPets(speciesId)
    local ownedPets = {}
    local anyPetsFound = false

    for _, petId in LibPetJournal:IteratePetIDs() do
        local speciesIdFromJournal, _, petLevel = C_PetJournal.GetPetInfoByPetID(petId)

        if speciesIdFromJournal == speciesId then
            local quality = select(5, C_PetJournal.GetPetStats(petId))

            table.insert(ownedPets, { petLevel, quality })
            anyPetsFound = true
        end
    end

    if anyPetsFound then
        return ownedPets
    else
        return nil
    end
end

function DataModule:GetEnemyPetsInBattle()
    local numberOfEnemyPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)
    local foundNotOwnedPets = {}
    local foundOwnedPets = {}

    for i = 1, numberOfEnemyPets do
        local speciesId = C_PetBattles.GetPetSpeciesID(Enum.BattlePetOwner.Enemy, i)
        local breedQuality = C_PetBattles.GetBreedQuality(Enum.BattlePetOwner.Enemy, i)
        local obtainable = select(11, C_PetJournal.GetPetInfoBySpeciesID(speciesId));

        -- In 11.0.0, Blizzard changed the C_PetBattles.GetBreedQuality to be indexed from 0.
        -- However, all other functions related to pet quality is still indexed from 1.
        -- So until everything is changed, we just add 1 to the result.
        breedQuality = breedQuality + 1

        if obtainable then
            local ownedPets = DataModule:GetOwnedPets(speciesId)

            if (ownedPets == nil) then
                table.insert(foundNotOwnedPets, { speciesId, breedQuality })
            else
                table.insert(foundOwnedPets, { speciesId, breedQuality })
            end
        end
    end

    return foundNotOwnedPets, foundOwnedPets
end

function DataModule:CanWeCapturePets()
    local isNpcControlled = C_PetBattles.IsPlayerNPC(Enum.BattlePetOwner.Enemy)

    if isNpcControlled == false then
        -- It is a PvP pet battle, you cannot capture pets here.
        return false
    end

    local isWildBattle = C_PetBattles.IsWildBattle()

    if isWildBattle == false then
        -- It is a quest or something else like that - you cannot capture pets here.
        return false
    end

    local numberOfEnemyPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)

    for i = 1, numberOfEnemyPets do
        local speciesId = C_PetBattles.GetPetSpeciesID(Enum.BattlePetOwner.Enemy, i)
        local obtainable = select(11, C_PetJournal.GetPetInfoBySpeciesID(speciesId))

        -- We can end here, but without any captureable pets, so if we see at least one that can be captured, we return true.
        if (obtainable == true) then
            return true
        end
    end

    return false
end

function DataModule:GetPetSource(speciesId)
    local tooltipSource = select(5, C_PetJournal.GetPetInfoBySpeciesID(speciesId))

    -- Remove the color part of the name
    local trimmed = string.sub(tooltipSource, 11, string.len(tooltipSource) - 1)

    for i = 1, C_PetJournal.GetNumPetSources() do
        local filter = _G["BATTLE_PET_SOURCE_"..i]

        -- Then we look at the length that matches the length of the BATTLE_PET_SOURCE string.
        -- If they match, we return.
        if string.sub(trimmed, 1, #filter) == filter then
            return filter
        end
    end

    return nil
end