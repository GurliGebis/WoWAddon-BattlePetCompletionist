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
local ObjectiveTrackerModule = BattlePetCompletionist:NewModule("ObjectiveTrackerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_ObjectiveTracker")

-- Detect KalielsTracker and resolve tracker-specific globals.
-- KT completely disables Blizzard's ObjectiveTrackerManager, so we must use
-- KT's own mixin, templates, enums, and colors when it is active.
local isKTLoaded = C_AddOns.IsAddOnLoaded("!KalielsTracker")

local baseMixin      = isKTLoaded and KT_ObjectiveTrackerModuleMixin or ObjectiveTrackerModuleMixin
local moduleTemplate = isKTLoaded and "KT_ObjectiveTrackerModuleTemplate" or "ObjectiveTrackerModuleTemplate"
local blockTemplate  = isKTLoaded and "KT_ObjectiveTrackerAnimBlockTemplate" or "ObjectiveTrackerAnimBlockTemplate"
local lineTemplate   = isKTLoaded and "KT_ObjectiveTrackerAnimLineTemplate" or "ObjectiveTrackerAnimLineTemplate"
local lineStateEnum  = isKTLoaded and KT_ObjectiveTrackerAnimLineState or ObjectiveTrackerAnimLineState
local trackerColor   = isKTLoaded and KT_OBJECTIVE_TRACKER_COLOR or OBJECTIVE_TRACKER_COLOR
local dashStyleHide  = isKTLoaded and KT_OBJECTIVE_DASH_STYLE_HIDE or OBJECTIVE_DASH_STYLE_HIDE

local settings = {
	headerText = L["Battle Pets"],
	events = { "PET_JOURNAL_LIST_UPDATE", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" },
	blockTemplate = blockTemplate,
	lineTemplate = lineTemplate,
    uiOrder = 50
};

BattlePetCompletionistObjectiveTrackerMixin = CreateFromMixins(baseMixin, settings);

-- Replicates KT:SetModuleHeader() which is private to the KT addon.
-- KT hides the default right-side MinimizeButton and replaces it with a
-- left-side icon texture, making the entire header clickable for collapse.
-- Without this, our module header looks like a Blizzard header inside KT.
local function ApplyKTHeaderStyle(module)
    local header = module.Header
    if not header then
        return
    end

    -- Lock header text position to LEFT and prevent it from being moved
    header.Text.ClearAllPoints = function() end
    header.Text:SetPoint("LEFT", 10, 1)
    header.Text.SetPoint = function() end

    -- Disable header add animation
    header.PlayAddAnimation = function() end

    -- Hide the right-side MinimizeButton permanently
    header.MinimizeButton:SetShown(false)
    header.MinimizeButton.SetShown = function() end

    -- Collapse icon matching KT's SetModuleHeader() style.
    -- Expanded/collapsed are horizontally adjacent in KT's sprite sheet.
    local expandedCoords = { 0.5, 1, 0.75, 1 }
    local collapsedCoords = { 0, 0.5, 0.75, 1 }

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetTexture("Interface\\AddOns\\!KalielsTracker\\Media\\UI-KT-HeaderButtons")
    icon:SetTexCoord(unpack(expandedCoords))
    icon:SetPoint("LEFT", -6, 2)
    icon:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
    header.Icon = icon

    -- Make the entire header clickable to toggle collapse
    header:SetScript("OnMouseUp", function()
        module:ToggleCollapsed()
        if module:IsCollapsed() then
            icon:SetTexCoord(unpack(collapsedCoords))
        else
            icon:SetTexCoord(unpack(expandedCoords))
        end
    end)
end

function BattlePetCompletionistObjectiveTrackerMixin:InitModule()
    -- KT's mixin does not have Init(), only Blizzard's does
    if not isKTLoaded then
	    self:Init();
    else
        ApplyKTHeaderStyle(self)
    end

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

    -- Sort the filtered pets by species name
    table.sort(filteredPets, function(a, b)
        if a.speciesName and b.speciesName then
            return a.speciesName < b.speciesName
        elseif a.speciesName then
            return true
        elseif b.speciesName then
            return false
        else
            return a.speciesId < b.speciesId
        end
    end)

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

    local objectiveKey = "battlepet-" .. petInfo.speciesId

    if petInfo.numCollected == 0 then
        local line = block:AddObjective(objectiveKey, petInfo.speciesName, nil, true)

        line:SetState(lineStateEnum.Present)
    else
        local color = trackerColor["Complete"]

        local line = block:AddObjective(objectiveKey, petInfo.speciesName, nil, true, dashStyleHide, color)

        if line.state == lineStateEnum.Present then
            line:SetState(lineStateEnum.Completing)
        elseif line.state == lineStateEnum.Completing then
            line:SetState(lineStateEnum.Completed)
        else
            line:SetState(lineStateEnum.Completed)
        end
    end
end

-- Create the module frame dynamically since the template depends on which tracker is active.
-- XML cannot conditionally select a template, so we use CreateFrame here instead.
local frame = CreateFrame("Frame", "BattlePetCompletionistObjectiveTracker", nil, moduleTemplate)
Mixin(frame, BattlePetCompletionistObjectiveTrackerMixin)
frame:OnLoad()

do
    function ObjectiveTrackerModule:OnPlayerEnteringWorld()
        -- Avoid calling protected SetSize functions during movies or combat
        if InCombatLockdown() or (MovieFrame and MovieFrame:IsShown()) then 
            return 
        end

        if isKTLoaded then
            if KT_ObjectiveTrackerFrame and KT_ObjectiveTrackerFrame.AddModule then
                KT_ObjectiveTrackerFrame:AddModule(BattlePetCompletionistObjectiveTracker)
            end
        else
            if ObjectiveTrackerManager and ObjectiveTrackerManager.SetModuleContainer then
                ObjectiveTrackerManager:SetModuleContainer(BattlePetCompletionistObjectiveTracker, ObjectiveTrackerFrame)
            end
        end
    end

    function ObjectiveTrackerModule:OnInitialize()
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
        self:RegisterEvent("PET_JOURNAL_LIST_UPDATE", "OnPetEvent")
    end

    function ObjectiveTrackerModule:OnPetEvent(event, ...)
        if self.Mixin then
            self.Mixin:OnEvent(event, ...)
        end
    end
end
