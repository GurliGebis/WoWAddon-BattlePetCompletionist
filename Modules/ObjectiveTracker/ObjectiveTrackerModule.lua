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
local ObjectiveTrackerModule = BattlePetCompletionist:NewModule("ObjectiveTrackerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_ObjectiveTracker")

local settings = {
	headerText = L["Battle Pets"],
	events = { "PET_JOURNAL_LIST_UPDATE", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" },
	timedCriteria = { },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
    uiOrder = 50
};

if KT_ObjectiveTrackerManager then
    settings.blockTemplate = "KT_ObjectiveTrackerAnimBlockTemplate"
    settings.lineTemplate = "KT_ObjectiveTrackerAnimLineTemplate"
end

BattlePetCompletionistObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function BattlePetCompletionistObjectiveTrackerMixin:InitModule()
	self:Init();

    ObjectiveTrackerModule.Mixin = self
end

function BattlePetCompletionistObjectiveTrackerMixin:OnEvent(event, ...)
    self:MarkDirty()
end

function BattlePetCompletionistObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
    if mouseButton == "LeftButton" then
        if not CollectionsJournal or not CollectionsJournal:IsShown() then
            ToggleCollectionsJournal()
        end

        CollectionsJournal_SetTab(CollectionsJournal, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
    end
end

function BattlePetCompletionistObjectiveTrackerMixin:LayoutContents()
    local profile = DBModule:GetProfile()
    if not profile.objectiveTrackerEnabled then
        return
    end

    local mapID = ZoneModule:ResolveZone()

    if not mapID then
        return
    end

    local pets = DataModule:GetPetsInMap(mapID) or {}

    if not next(pets) then
        return
    end

    local anyMissingPets = false
    local filteredPets = {}
    for speciesId in pairs(pets) do
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesId)

        if numCollected == 0 then
            anyMissingPets = true
        end

        local speciesName = C_PetJournal.GetPetInfoBySpeciesID(speciesId)

        tinsert(filteredPets, { speciesId = speciesId, numCollected = numCollected, speciesName = speciesName })
    end

    if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and anyMissingPets == false then
        return
    end

    local mapInfo = C_Map.GetMapInfo(mapID)
    local zoneName = mapInfo and mapInfo.name or L["current zone"]

    local block = self:GetBlock("battlepets")
    block:SetHeader(string.format(L["Battle Pets in %s"], zoneName))

    for _, petInfo in ipairs(filteredPets) do
        if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.ALL or (profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and petInfo.numCollected == 0) then
            self:AddBattlePet(block, petInfo)
        end
    end

    self:LayoutBlock(block);
end

function BattlePetCompletionistObjectiveTrackerMixin:AddBattlePet(block, petInfo)
    if not petInfo.speciesName then
        return
    end

    if petInfo.numCollected == 0 then
        local line = block:AddObjective(petInfo.speciesName, petInfo.speciesName, nil, true)

        line:SetState(ObjectiveTrackerAnimLineState.Present)
    else
        local color

        if KT_ObjectiveTrackerManager then
            color = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
        else
            color = OBJECTIVE_TRACKER_COLOR["Complete"]
        end

        local line = block:AddObjective(petInfo.speciesName, petInfo.speciesName, nil, true, OBJECTIVE_DASH_STYLE_HIDE, color)

        if line.state == ObjectiveTrackerAnimLineState.Present then
            line:SetState(ObjectiveTrackerAnimLineState.Completing)
        elseif line.state == ObjectiveTrackerAnimLineState.Completing then
            line:SetState(ObjectiveTrackerAnimLineState.Completed)
        else
            line:SetState(ObjectiveTrackerAnimLineState.Completed)
        end
    end
end

do
    function ObjectiveTrackerModule:OnPlayerEnteringWorld()
        local ObjectiveTrackerManager = KT_ObjectiveTrackerManager or ObjectiveTrackerManager
        local ObjectiveTrackerFrame = KT_ObjectiveTrackerFrame or ObjectiveTrackerFrame

        ObjectiveTrackerManager:SetModuleContainer(BattlePetCompletionistObjectiveTracker, ObjectiveTrackerFrame)
    end

    function ObjectiveTrackerModule:OnInitialize()
        self:RegisterEventHandlers()
    end

    -- We need to forward events to the mixin instance
    function ObjectiveTrackerModule:OnEvent(event, ...)
        if self.Mixin then
            self.Mixin:OnEvent(event, ...)
        end
    end

    function ObjectiveTrackerModule:RegisterEventHandlers()
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    end
end