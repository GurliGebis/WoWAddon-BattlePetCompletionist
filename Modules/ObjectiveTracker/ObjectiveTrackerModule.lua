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
]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local ObjectiveTrackerModule = BattlePetCompletionist:NewModule("ObjectiveTrackerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")

-- Sorts by speciesName alphabetically, falling back to speciesId for unnamed entries.
local function ComparePetsByName(a, b)
    if a.speciesName and b.speciesName then
        return a.speciesName < b.speciesName
    elseif a.speciesName then
        return true
    elseif b.speciesName then
        return false
    else
        return a.speciesId < b.speciesId
    end
end

-- Build the sorted, filtered pet list for the current zone.
-- Returns filteredPets, mapID or nil when nothing should be displayed.
function ObjectiveTrackerModule:GetFilteredPetList()
    local profile = DBModule:GetProfile()
    if not profile.objectiveTrackerEnabled then
        return nil
    end

    local mapID = ZoneModule:ResolveZone()
    if not mapID then
        return nil
    end

    local pets = DataModule:GetPetsInMap(mapID) or {}
    if not next(pets) then
        return nil
    end

    local anyMissing = false
    local allPets = {}
    for speciesId in pairs(pets) do
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesId)
        if numCollected == 0 then
            anyMissing = true
        end
        local speciesName = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
        tinsert(allPets, { speciesId = speciesId, numCollected = numCollected, speciesName = speciesName })
    end

    table.sort(allPets, ComparePetsByName)

    if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and not anyMissing then
        return nil
    end

    local filteredPets = {}
    for _, petInfo in ipairs(allPets) do
        if petInfo.speciesName then
            if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.ALL
                or (profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and petInfo.numCollected == 0)
            then
                tinsert(filteredPets, petInfo)
            end
        end
    end

    if not next(filteredPets) then
        return nil
    end

    return filteredPets, mapID
end
