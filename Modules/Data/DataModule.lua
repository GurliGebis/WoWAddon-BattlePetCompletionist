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

BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
DataModule = BattlePetCompletionist:NewModule("DataModule")
ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")
LibPetJournal = LibStub('LibPetJournal-2.0')

function DataModule:GetPetsInMap(mapId)
    return DataModule.PetData[mapId]
end

function DataModule:ShouldPetBeShown(speciesId)
    if ConfigModule.AceDB.profile.mapPinsToInclude == "T1ALL" then
        return true
    end

    if ConfigModule.AceDB.profile.mapPinsToInclude == "T4NONE" then
        return false
    end

    for _, petId in LibPetJournal:IteratePetIDs() do
        local speciesIdFromJournal = C_PetJournal.GetPetInfoByPetID(petId)

        if speciesIdFromJournal == speciesId then
            if ConfigModule.AceDB.profile.mapPinsToInclude == "T2MISSING" then
                return false
            end

            if ConfigModule.AceDB.profile.mapPinsToInclude == "T3NOTRARE" then
                local quality = select(5, C_PetJournal.GetPetStats(petId))

                if (quality >= 4) then
                    -- quality 4 is Rare / Blue
                    return false
                end
            end
        end
    end

    return true
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