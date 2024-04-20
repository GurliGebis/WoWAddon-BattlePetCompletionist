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

local defaultOptions = {
    profile = {
        petCageTooltipEnabled = true,
        petBattleUnknownNotifyEnabled = true,
        mapPinSize = "S1",
        mapPinsToInclude = _BattlePetCompletionist.Enums.MapPinFilter.T1ALL,
        mapPinsToIncludeOriginal = _BattlePetCompletionist.Enums.MapPinFilter.T1ALL,
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
