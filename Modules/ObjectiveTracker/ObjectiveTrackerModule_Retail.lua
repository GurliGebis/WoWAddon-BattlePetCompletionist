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

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local ObjectiveTrackerModule = BattlePetCompletionist:GetModule("ObjectiveTrackerModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_ObjectiveTracker")

local settings = {
	headerText = L["Battle Pets"],
	events = { "PET_JOURNAL_LIST_UPDATE", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
    uiOrder = 50
};

BattlePetCompletionistObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function BattlePetCompletionistObjectiveTrackerMixin:InitModule()
	self:Init();
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
    local filteredPets, mapID = ObjectiveTrackerModule:GetFilteredPetList()
    if not filteredPets then
        return
    end

    local mapInfo = C_Map.GetMapInfo(mapID)
    local zoneName = mapInfo and mapInfo.name or L["current zone"]

    local block = self:GetBlock("battlepets")
    block:SetHeader(string.format(L["Battle Pets in %s"], zoneName))

    for _, petInfo in ipairs(filteredPets) do
        self:AddBattlePet(block, petInfo)
    end

    self:LayoutBlock(block);
end

function BattlePetCompletionistObjectiveTrackerMixin:AddBattlePet(block, petInfo)
    if not petInfo.speciesName then
        return
    end

    local objectiveKey = "battlepet-" .. petInfo.speciesId

    if petInfo.numCollected == 0 then
        local line = block:AddObjective(objectiveKey, petInfo.speciesName, nil, true)

        line:SetState(ObjectiveTrackerAnimLineState.Present)
    else
        local color = OBJECTIVE_TRACKER_COLOR["Complete"]

        local line = block:AddObjective(objectiveKey, petInfo.speciesName, nil, true, OBJECTIVE_DASH_STYLE_HIDE, color)

        if line.state == ObjectiveTrackerAnimLineState.Present then
            line:SetState(ObjectiveTrackerAnimLineState.Completing)
        elseif line.state == ObjectiveTrackerAnimLineState.Completing then
            line:SetState(ObjectiveTrackerAnimLineState.Completed)
        else
            line:SetState(ObjectiveTrackerAnimLineState.Completed)
        end
    end
end


local frame = CreateFrame("Frame", "BattlePetCompletionistObjectiveTracker", nil, "ObjectiveTrackerModuleTemplate")
Mixin(frame, BattlePetCompletionistObjectiveTrackerMixin)
frame:OnLoad()

do
    function ObjectiveTrackerModule:OnPlayerEnteringWorld()
        -- Avoid calling protected SetSize functions during movies or combat
        if InCombatLockdown() or (MovieFrame and MovieFrame:IsShown()) then
            return
        end

        if ObjectiveTrackerManager and ObjectiveTrackerManager.SetModuleContainer then
            ObjectiveTrackerManager:SetModuleContainer(BattlePetCompletionistObjectiveTracker, ObjectiveTrackerFrame)
        end
    end

    function ObjectiveTrackerModule:OnInitialize()
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
        self:RegisterEvent("PET_JOURNAL_LIST_UPDATE", "OnPetEvent")
        self:RegisterMessage(_BattlePetCompletionist.Events.ZONE_CHANGE, "OnPetEvent")
    end

    function ObjectiveTrackerModule:OnPetEvent(event, ...)
        if self.Mixin then
            self.Mixin:OnEvent(event, ...)
        end
    end
end
