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
local BrokerModule = BattlePetCompletionist:NewModule("BrokerModule", "AceEvent-3.0")
local ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local GoalTrackerModule = BattlePetCompletionist:GetModule("GoalTrackerModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibPetJournal = LibStub("LibPetJournal-2.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_Broker")

-- Also used by MinimapModule
function BrokerModule:GetDataObject()
    return self.dataSource
end

function BrokerModule:RefreshData()
    local count = 0
    local totalCount = 0
    local petData = self:GetZonePetData()
    local profile = DBModule:GetProfile()
    local goal = profile.brokerGoal
    local goalTextEnabled = profile.brokerGoalTextEnabled
    for speciesId, _ in pairs(petData) do
        totalCount = totalCount + 1
        if self:MetGoal(goal, self:GetNumCollectedInfo(speciesId)) then
            count = count + 1
        end
    end
    local suffix
    if goalTextEnabled then
        suffix = " " .. self:GetSuffixForGoal(goal)
    else
        suffix = ""
    end
    self.dataSource.text = string.format("%d/%d%s", count, totalCount, suffix)
end

function BrokerModule:RegisterEventHandlers()
    self:RegisterMessage(_BattlePetCompletionist.Events.ZONE_CHANGE, "RefreshData")
    LibPetJournal.RegisterCallback(self, "PetListUpdated", "RefreshData")
end

-- Get the pets in the current zone.
-- The map determination logic may skip some changes to improve CPU usage.
function BrokerModule:GetZonePetData()
    local mapID = ZoneModule:ResolveZone()
    return DataModule:GetPetsInMap(mapID) or {}
end

function BrokerModule:OnInitialize()
    self.dataSource = LibDataBroker:NewDataObject(addonName, {
        type = "data source",
        label = L["Battle Pets"],
        icon = "Interface\\Icons\\Inv_Pet_Achievement_CaptureAWildPet",
        OnClick = function(_, button)
            self:OnClick(button)
        end,
        OnTooltipShow = function(tooltip)
            self:OnTooltipShow(tooltip, tooltip ~= LibDBIconTooltip)
        end,
        OnLeave = HideTooltip
    })
    self:RegisterEventHandlers()
end

function BrokerModule:QualityToColorCode(quality)
    if quality and quality >= 1 then
        return ITEM_QUALITY_COLORS[quality - 1].hex
    else
        return RED_FONT_COLOR_CODE
    end
end

function BrokerModule:TooltipToSourceTypeIcon(speciesId)
    local sourceType = DataModule:GetPetSource(speciesId)
    local icon
    if sourceType == BATTLE_PET_SOURCE_1 then -- Drop
        icon = "Interface/WorldMap/TreasureChest_64"
    elseif sourceType == BATTLE_PET_SOURCE_2 then -- Quest
        icon = "Interface/GossipFrame/AvailableQuestIcon"
    elseif sourceType == BATTLE_PET_SOURCE_3 then -- Vendor
        icon = "Interface/Minimap/Tracking/Banker"
    elseif sourceType == BATTLE_PET_SOURCE_4 then -- Profession
        icon = "Interface/Archeology/Arch-Icon-Marker"
    elseif sourceType == BATTLE_PET_SOURCE_5 then -- Pet Battle
        icon = "Interface/Icons/Tracking_WildPet"
    -- 6 Achievement; no icon assigned
    elseif sourceType == BATTLE_PET_SOURCE_7 then -- World Event
        icon = "Interface/GossipFrame/DailyQuestIcon"
    elseif sourceType == BATTLE_PET_SOURCE_8 then -- Promotion
        icon = "Interface/Minimap/Tracking/Banker"
    elseif sourceType == BATTLE_PET_SOURCE_9 then -- Trading Card Game
        icon = "Interface/Icons/inv_misc_hearthstonecard_legendary"
    elseif sourceType == BATTLE_PET_SOURCE_10 then -- Shop
        icon = "Interface/Icons/item_shop_giftbox01"
    elseif sourceType == BATTLE_PET_SOURCE_11 then -- Discovery
        icon = "Interface/Icons/Garrison_Building_MageTower"
    elseif sourceType == BATTLE_PET_SOURCE_12 then -- Trading Post
        icon = "Interface/Icons/TradingPostCurrency"
    else -- In case we encounter an unhandled source type
        icon = "Interface/Icons/Inv_misc_questionmark"
    end
    return icon
end

-- Also used by AddonCompartmentModule
function BrokerModule:OnTooltipShow(tooltip, includeDetails)
    tooltip:AddLine(L["Battle Pet Completionist"])
    tooltip:AddLine(L["Left Click to toggle goal tracker"])
    tooltip:AddLine(L["Right Click for options"])

    if not includeDetails then
        return
    end

    tooltip:AddLine(" ")
    local goal = DBModule:GetProfile().brokerGoal
    local metGoalCount = 0
    local totalCount = 0
    local petData = self:GetZonePetData()
    local detailEntries = {}
    for speciesId, _ in pairs(petData) do
        totalCount = totalCount + 1
        local numCollected, numRareCollected, limit = self:GetNumCollectedInfo(speciesId)
        local metGoal = self:MetGoal(goal, numCollected, numRareCollected, limit)
        if metGoal then
            metGoalCount = metGoalCount + 1
        else
            local speciesName, speciesIcon = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
            local myPets = DataModule:GetOwnedPets(speciesId) or {}
            local petStrings = {}
            for _, myPetInfo in ipairs(myPets) do
                local petLevel, petQuality = myPetInfo[1], myPetInfo[2]
                table.insert(petStrings, self:QualityToColorCode(petQuality) .. "L" .. petLevel .. FONT_COLOR_CODE_CLOSE)
            end
            while #petStrings < limit do
                table.insert(petStrings, RED_FONT_COLOR_CODE .. "L0" .. FONT_COLOR_CODE_CLOSE)
            end
            local petSummary = table.concat(petStrings, "/")
            local sourceTypeIcon = self:TooltipToSourceTypeIcon(speciesId)
            local iconCode = string.format("|T%s:16:16|t|T%s:12:12:0:0|t", speciesIcon, sourceTypeIcon)
            table.insert(detailEntries, { iconCode, speciesName, petSummary })
        end
    end
    -- Sort by species name
    table.sort(detailEntries, function(a, b) return a[2] < b[2] end)
    for _, entry in ipairs(detailEntries) do
        tooltip:AddLine(table.concat(entry, " "))
    end
    if not petData then
        tooltip:AddLine(L["No pets found for current zone"])
    else
        tooltip:AddLine(string.format(L["Met goal"], metGoalCount, totalCount))
    end
end

-- Also used by AddonCompartmentModule
function BrokerModule:OnClick(button)
    if button == "LeftButton" then
        GoalTrackerModule:ToggleWindow()
    elseif button == "RightButton" then
        self:ToggleConfig()
    end
end

function BrokerModule:ToggleConfig()
    local optionsFrame = ConfigModule.OptionsFrame
    local categoryId = ConfigModule.CategoryId
    if optionsFrame then
        if SettingsPanel:IsShown() then
            SettingsPanel:Hide()
        else
            Settings.OpenToCategory(categoryId)
        end
    end
end

function BrokerModule:GetSuffixForGoal(goal)
    if goal == _BattlePetCompletionist.Enums.Goal.COLLECT then
        return L["Suffix - Collected"]
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_RARE then
        return L["Suffix - Rare"]
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_MAX then
        return L["Suffix - Max Collected"]
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE then
        return L["Suffix - Max Rare"]
    else
        return ""
    end
end

function BrokerModule:MetGoal(goal, numCollected, numRareCollected, limit)
    if goal == _BattlePetCompletionist.Enums.Goal.COLLECT then
        return numCollected > 0
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_RARE then
        return numRareCollected > 0
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_MAX then
        return numCollected >= limit
    elseif goal == _BattlePetCompletionist.Enums.Goal.COLLECT_MAX_RARE then
        return numRareCollected >= limit
    else
        return false
    end
end

function BrokerModule:GetNumCollectedInfo(speciesId)
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
    local myPets = DataModule:GetOwnedPets(speciesId) or {}
    local numRareCollected = 0
    for _, myPetInfo in ipairs(myPets) do
        local petQuality = myPetInfo[2]
        if petQuality >= _BattlePetCompletionist.Constants.PET_QUALITY_RARE then
            numRareCollected = numRareCollected + 1
        end
    end
    return numCollected, numRareCollected, limit
end
