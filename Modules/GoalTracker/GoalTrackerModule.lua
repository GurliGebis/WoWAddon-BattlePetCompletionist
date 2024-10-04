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
local GoalTrackerModule = BattlePetCompletionist:NewModule("GoalTrackerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")
local AceGUI = LibStub("AceGUI-3.0")
local LibPetJournal = LibStub("LibPetJournal-2.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_GoalTracker")

function GoalTrackerModule:UpdateWindow()
    local petData = self:GetZonePetData()

    local collectedSpeciesCount = 0
    local totalSpeciesCount = 0
    local entries = {}
    if petData then
        for speciesId, _ in pairs(petData) do
            local numCollected, _ = C_PetJournal.GetNumCollectedInfo(speciesId)
            totalSpeciesCount = totalSpeciesCount + 1
            if numCollected > 0 then
                collectedSpeciesCount = collectedSpeciesCount + 1
            else
                local speciesName, speciesIconPath = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
                table.insert(entries, {speciesId, speciesName, speciesIconPath})
            end
        end
        function compare(a, b)
            return a[2] < b[2]
        end
        table.sort(entries, compare)
    end

    if (self.content) then
        self.content:ReleaseChildren()
        local heading = AceGUI:Create("Heading")
        heading:SetText(string.format(L["Uncollected"], totalSpeciesCount - collectedSpeciesCount, totalSpeciesCount))
        heading:SetRelativeWidth(1)
        self.content:AddChild(heading)

        for _, entry in pairs(entries) do
            local speciesId = entry[1]
            local speciesName = entry[2]
            local speciesIconPath = entry[3]
            local sourceTypeIconPath = self:TooltipToSourceTypeIcon(speciesId)

            local function openJournalToSpecies()
                if not CollectionsJournal then
                    CollectionsJournal_LoadUI()
                end
                SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
                PetJournal_UpdateAll()
                PetJournal_SelectSpecies(PetJournal, speciesId)
                if RematchFrame and RematchFrame.PetsPanel.Top.SearchBox then
                    RematchFrame.PetsPanel.Top.SearchBox:SetText('"' .. speciesName .. '"')
                    RematchFrame.PetsPanel.Top.SearchBox:OnTextChanged('"' .. speciesName .. '"')
                elseif PetJournalSearchBox then
                    PetJournalSearchBox:SetText('"' .. speciesName .. '"')
                end
            end

            local row = AceGUI:Create("SimpleGroup")
            row:SetLayout("Flow")
            local speciesIcon = AceGUI:Create("Icon")
            speciesIcon:SetImage(speciesIconPath)
            speciesIcon:SetImageSize(16, 16)
            speciesIcon:SetHeight(18)
            speciesIcon:SetWidth(18)
            speciesIcon:SetCallback("OnClick", openJournalToSpecies)
            local sourceTypeIcon = AceGUI:Create("Icon")
            sourceTypeIcon:SetImage(sourceTypeIconPath)
            sourceTypeIcon:SetImageSize(16, 16)
            sourceTypeIcon:SetHeight(18)
            sourceTypeIcon:SetWidth(18)
            sourceTypeIcon:SetCallback("OnClick", openJournalToSpecies)
            local label = AceGUI:Create("InteractiveLabel")
            label:SetText(speciesName)
            label:SetCallback("OnClick", openJournalToSpecies)
            label:SetFont(GameFontNormal:GetFont())
            row:AddChild(speciesIcon)
            row:AddChild(sourceTypeIcon)
            row:AddChild(label)
            self.content:AddChild(row)
        end
        local heading = AceGUI:Create("Heading")
        heading:SetText(string.format(L["Collected"], collectedSpeciesCount, totalSpeciesCount))
        heading:SetRelativeWidth(1)
        self.content:AddChild(heading)
    end
end

function GoalTrackerModule:RegisterEventHandlers()
    self:RegisterMessage(_BattlePetCompletionist.Events.ZONE_CHANGE, "UpdateWindow")
    LibPetJournal.RegisterCallback(self, "PetListUpdated", "UpdateWindow")
end

function GoalTrackerModule:OnInitialize()
    self:RegisterEventHandlers()
    self:InitializeWindow()
end

function GoalTrackerModule:InitializeWindow()
    local profile = DBModule:GetProfile()
    if profile.goalTrackerOpen then
        self:CreateWindow()
        self:UpdateWindow()
    end
end

function GoalTrackerModule:ToggleWindow()
    local profile = DBModule:GetProfile()
    local window = self.window
    if not window then
        window = self:CreateWindow()
    elseif window.frame:IsShown() then
        window:Hide()
    else
        window:Show()
    end
    local isShown = window.frame:IsShown()
    profile.goalTrackerOpen = isShown
    if isShown then
        self:UpdateWindow()
    end
end

function GoalTrackerModule:CreateWindow()
    local profile = DBModule:GetProfile()
    if not self.window then
        local window = AceGUI:Create("Window")
        window:SetStatusTable(profile.goalTrackerStatus)
        window.frame:SetFrameStrata("LOW")
        window.frame:Raise()
        window.content:SetFrameStrata("LOW")
        window.content:Raise()
        self.window = window
        window:SetTitle(L["BattlePets Goal Tracker"])
        window:SetLayout("Fill")
        window.frame:SetClampedToScreen(true)
        window.closebutton:SetScript("OnClick", function()
            profile.goalTrackerOpen = false
            window:Hide()
        end)

        local content = AceGUI:Create("SimpleGroup")
        window:AddChild(content)
        self.content = content
    end
    return self.window
end

-- Get the pets in the current zone.
-- The map determination logic may skip some changes to improve CPU usage.
function GoalTrackerModule:GetZonePetData()
    local mapID = ZoneModule:ResolveZone()
    return DataModule:GetPetsInMap(mapID) or {}
end

function GoalTrackerModule:TooltipToSourceTypeIcon(speciesId)
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
        -- 9 Trading Card Game; no icon assigned
        -- 10 Shop; no icon assigned
        -- 11 Discovery; no icon assigned
        -- 12 Trading Post; no icon assigned
    else -- In case we encounter an unhandled source type
        icon = "Interface/Icons/Inv_misc_questionmark"
    end
    return icon
end
