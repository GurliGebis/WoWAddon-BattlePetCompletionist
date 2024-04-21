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
local DBModule = BattlePetCompletionist:NewModule("DBModule")

-- dataVersion is intentionally omitted from the defaults, as we may need to apply migrations to profiles that lack it
local defaultOptions = {
    profile = {
        petCageTooltipEnabled = true,
        petBattleUnknownNotifyEnabled = true,
        mapPinSize = "S1",
        mapPinsToInclude = _BattlePetCompletionist.Enums.MapPinFilter.ALL,
        mapPinsToIncludeOriginal = _BattlePetCompletionist.Enums.MapPinFilter.ALL,
        mapPinIconType = "T1PET",
        mapPinsFilter = "",
        mapPinSources = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [7] = true
        },
        minimapIconEnabled = true,
        brokerGoal = _BattlePetCompletionist.Enums.Goal.COLLECT,
        brokerGoalTextEnabled = true,
        tomtomIntegration = true,
        combatMode = "V1HAF",
        forfeitThreshold = "C1BLUE",
        forfeitPromptUnless = "T3NOTRARE"
    }
}

function DBModule:OnInitialize()
    self.AceDB = LibStub("AceDB-3.0"):New("BattlePetCompletionistDB", defaultOptions, true)
    DBModule:MigrateProfile()
end

function DBModule:GetGlobal()
    return self.AceDB.global
end

function DBModule:GetProfile()
    return self.AceDB.profile
end

function DBModule:IsPetCageTooltipEnabled()
    return self:GetProfile().petCageTooltipEnabled
end

function DBModule:IsPetBattleUnknownNotifyEnabled()
    return self:GetProfile().petBattleUnknownNotifyEnabled
end

-- TODO: replace with enum
function DBModule:GetCombatMode()
    return strsub(self:GetProfile().combatMode, 3)
end

-- TODO: replace with enum
function DBModule:GetForfeitThreshold()
    return strsub(self:GetProfile().forfeitThreshold, 3)
end

-- TODO: replace with enum
function DBModule:GetForfeitPromptUnless()
    return strsub(self:GetProfile().forfeitPromptUnless, 3)
end

function DBModule:GetMapPinsIconType()
    if self:GetProfile().mapPinIconType == "T1PET" then
        return "PET"
    else
        return "FAMILY"
    end
end

function DBModule:GetMapPinScale()
    local scaleMap = {
        S1 = 1.0,
        S2 = 1.2,
        S3 = 1.4
    }

    return scaleMap[self:GetProfile().mapPinSize]
end

function DBModule:GetMapPinSources()
    local profile = self:GetProfile()
    local sources = {}

    for key, value in pairs(_BattlePetCompletionist.Constants.PET_SOURCES) do
        if profile.mapPinSources[key] then
            table.insert(sources, value)
        end
    end

    return sources
end

local function dataVersion(profile)
    return profile.dataVersion or 0
end

-- Update MapPinFilter values to eliminate prefix and separate words
local function migrateV1(profile)
    local function convertValue(value)
        if value == "T1ALL" then
            return _BattlePetCompletionist.Enums.MapPinFilter.ALL
        elseif value == "T2MISSING" then
            return _BattlePetCompletionist.Enums.MapPinFilter.MISSING
        elseif value == "T3NOTRARE" then
            return _BattlePetCompletionist.Enums.MapPinFilter.NOT_RARE
        elseif value == "T4NONE" then
            return _BattlePetCompletionist.Enums.MapPinFilter.NONE
        elseif value == "T5NOTMAXCOLLECTED" then
            return _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_COLLECTED
        elseif value == "T6NAMEFILTER" then
            return _BattlePetCompletionist.Enums.MapPinFilter.NAME_FILTER
        elseif value == "T7NOTMAXRARE" then
            return _BattlePetCompletionist.Enums.MapPinFilter.NOT_MAX_RARE
        else
            return value
        end
    end

    profile.mapPinsToInclude = convertValue(profile.mapPinsToInclude)
    profile.mapPinsToIncludeOriginal = convertValue(profile.mapPinsToIncludeOriginal)
    profile.dataVersion = 1
    return dataVersion(profile)
end

-- Update Goal values to separate words
local function migrateV2(profile)
    local function convertValue(value)
        if value == "COLLECTRARE" then
            return _BattlePetCompletionist.Enums.Goal.COLLECT_RARE
        elseif value == "COLLECTMAX" then
            return _BattlePetCompletionist.Enums.Goal.COLLECT_MAX
        elseif value == "COLLECTMAXRARE" then
            return _BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE
        else
            return value
        end
    end

    profile.brokerGoal = convertValue(profile.brokerGoal)
    profile.dataVersion = 2
    return dataVersion(profile)
end

function DBModule:MigrateProfile()
    local profile = self:GetProfile()
    local version = dataVersion(profile)
    if version < 1 then
        version = migrateV1(profile)
    end
    if version < 2 then
        version = migrateV2(profile)
    end
end
