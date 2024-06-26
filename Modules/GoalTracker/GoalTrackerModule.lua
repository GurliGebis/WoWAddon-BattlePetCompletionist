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
--local ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")
--local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local AceGUI = LibStub("AceGUI-3.0")
--local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibPetJournal = LibStub("LibPetJournal-2.0")

function GoalTrackerModule:UpdateWindow()
    -- TODO
end

function GoalTrackerModule:RegisterEventHandlers()
    self:RegisterMessage(_BattlePetCompletionist.Events.ZONE_CHANGE, "UpdateWindow")
    LibPetJournal.RegisterCallback(self, "PetListUpdated", "UpdateWindow")
end

function GoalTrackerModule:OnInitialize()
    -- TODO: auto-show on login based on config
    self:RegisterEventHandlers()
    self:InitializeWindow()
end

function GoalTrackerModule:InitializeWindow()
    local profile = DBModule:GetProfile()
    if profile.goalTrackerOpen then
        local window = self:CreateWindow()
        window:Show()
        self:UpdateWindow()
    end
end

function GoalTrackerModule:ToggleWindow()
    local profile = DBModule:GetProfile()
    local window = self:CreateWindow()
    if window.frame:IsShown() then
        profile.goalTrackerOpen = false
        window:Hide()
    else
        profile.goalTrackerOpen = true
        window:Show()
        self:UpdateWindow()
    end
end

function GoalTrackerModule:CreateWindow()
    local profile = DBModule:GetProfile()
    if not self.window then
        -- TODO: load from config
        local pos = profile.goalTrackerPos or {}
        local width = 500
        local height = 320
        local window = AceGUI:Create("Window")
        -- TODO: consider strata
        --window.frame:SetFrameStrata("MEDIUM")
        --window.frame:Raise()
        --window.content:SetFrameStrata("MEDIUM")
        --window.content:Raise()
        window:Hide()
        self.window = window
        window:SetTitle("BattlePets Goal Tracker")
        window:SetCallback("OnClose", function(widget)
            profile.goalTrackerOpen = false
            AceGUI:Release(widget)
            self.window = nil
        end)
        window:SetLayout("Fill")
        window.frame:SetClampedToScreen(true)
        window.pos = pos
        window:SetStatusTable(pos)
        -- TODO: allow resize, and save in settings
        window:EnableResize(false)
        window:SetWidth(width)
        window:SetHeight(height)
        window:SetAutoAdjustHeight(true)

        -- Create the TabGroup
        local tab = AceGUI:Create("TabGroup")
        tab:SetLayout("Flow")
        -- Setup which tabs to show
        tab:SetTabs({{text="One Collected", value="oneCollected"}, {text="Max Rare", value="maxRare"}, {text="All", value="all"}})
        -- Register callback
        tab:SetCallback("OnGroupSelected", function (container, event, group)
            container:ReleaseChildren()
            -- TODO: more modes
            if group == "oneCollected" then
                self:PopulateOneCollectedTab(container)
                --elseif group == "oneRare" then
                --    BrokerModule:PopulateOneRareTab(container)
                --elseif group == "maxCollected" then
                --    BrokerModule:PopulateMaxCollectedTab(container)
            elseif group == "maxRare" then
                self:PopulateMaxRareTab(container)
                -- TODO: level based?
            elseif group == "all" then
                self:PopulateAllTab(container)
            end
        end)
        -- Set initial Tab (this will fire the OnGroupSelected callback)
        -- TODO: select based on config
        tab:SelectTab("oneCollected")

        -- add to the frame container
        window:AddChild(tab)
    end
    return self.window
end

function GoalTrackerModule:PopulateOneCollectedTab(container)
    --local petData = self:GetZonePetData()
    --
    --if not petData then
    --    local label = AceGUI:Create("InteractiveLabel")
    --    label:SetText("No pets found for current zone")
    --    container:AddChild(label)
    --    return
    --end
    --
    --local scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    --scrollContainer:SetFullWidth(true)
    --scrollContainer:SetFullHeight(true) -- probably?
    --scrollContainer:SetLayout("Fill") -- important!
    --
    --container:AddChild(scrollContainer)
    --
    --local scroll = AceGUI:Create("ScrollFrame")
    --scroll:SetLayout("Flow") -- probably?
    --scrollContainer:AddChild(scroll)
    --
    ---- TODO: handle no pets situation (no petData)
    ---- TODO: sort
    --
    --local collectedSpeciesCount = 0
    --local totalSpeciesCount = 0
    --for speciesId, _ in pairs(petData) do
    --    local speciesName, speciesIconPath, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
    --    local numCollected, _ = C_PetJournal.GetNumCollectedInfo(speciesId)
    --
    --    totalSpeciesCount = totalSpeciesCount + 1
    --    if numCollected > 0 then
    --        collectedSpeciesCount = collectedSpeciesCount + 1
    --    else
    --        local function openJournalToSpecies()
    --            if not CollectionsJournal then
    --                CollectionsJournal_LoadUI()
    --            end
    --            SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
    --            PetJournal_UpdateAll()
    --            PetJournal_SelectSpecies(PetJournal, speciesId)
    --            if RematchFrame.PetsPanel.Top.SearchBox then
    --                RematchFrame.PetsPanel.Top.SearchBox:SetText('"' .. speciesName .. '"')
    --                RematchFrame.PetsPanel.Top.SearchBox:OnTextChanged('"' .. speciesName .. '"')
    --            elseif PetJournalSearchBox then
    --                PetJournalSearchBox:SetText('"' .. speciesName .. '"')
    --            end
    --        end
    --
    --        local sourceTypeIconPath = self:TooltipToSourceTypeIcon(speciesId)
    --        local speciesIcon = AceGUI:Create("Icon")
    --        speciesIcon:SetImage(speciesIconPath)
    --        speciesIcon:SetImageSize(16, 16)
    --        speciesIcon:SetHeight(18)
    --        speciesIcon:SetWidth(18)
    --        speciesIcon:SetCallback("OnClick", openJournalToSpecies)
    --        local sourceTypeIcon = AceGUI:Create("Icon")
    --        sourceTypeIcon:SetImage(sourceTypeIconPath)
    --        sourceTypeIcon:SetImageSize(16, 16)
    --        sourceTypeIcon:SetHeight(18)
    --        sourceTypeIcon:SetWidth(18)
    --        local label = AceGUI:Create("InteractiveLabel")
    --        label:SetText(speciesName)
    --        label:SetCallback("OnClick", openJournalToSpecies)
    --        local line = AceGUI:Create("SimpleGroup")
    --        line:SetAutoAdjustHeight(true)
    --        line:SetFullWidth(true)
    --        line:SetLayout("Flow")
    --        line:AddChild(speciesIcon)
    --        line:AddChild(sourceTypeIcon)
    --        line:AddChild(label)
    --
    --        scroll:AddChild(line)
    --    end
    --end
    --local label = AceGUI:Create("InteractiveLabel")
    --label:SetText(string.format("%d/%d Complete", collectedSpeciesCount, totalSpeciesCount))
    --
    --local line = AceGUI:Create("SimpleGroup")
    --line:SetAutoAdjustHeight(true)
    --line:SetFullWidth(true)
    --line:SetLayout("Flow")
    --line:AddChild(label)
    --
    --scroll:AddChild(line)
end

function GoalTrackerModule:PopulateMaxRareTab(container)
    --local petData = self:GetZonePetData()
    --
    --if not petData then
    --    local label = AceGUI:Create("InteractiveLabel")
    --    label:SetText("No pets found for current zone")
    --    container:AddChild(label)
    --    return
    --end
    --
    --local scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    --scrollContainer:SetFullWidth(true)
    --scrollContainer:SetFullHeight(true) -- probably?
    --scrollContainer:SetLayout("Fill") -- important!
    --
    --container:AddChild(scrollContainer)
    --
    --local scroll = AceGUI:Create("ScrollFrame")
    --scroll:SetLayout("Flow") -- probably?
    --scrollContainer:AddChild(scroll)
    --
    ---- TODO: handle no pets situation (no petData)
    ---- TODO: sort
    --
    --local maxRareCollectedCount = 0
    --local totalSpeciesCount = 0
    --for speciesId, _ in pairs(petData) do
    --    local speciesName, speciesIconPath, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
    --    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
    --    local myPets = DataModule:GetOwnedPets(speciesId)
    --    local rareQuality = 4
    --    local rareCollected = 0
    --    local maxQuality = -1
    --    local petStrings = {}
    --    local petSummary
    --    if myPets ~= nil then
    --        for _, myPetInfo in ipairs(myPets) do
    --            local petLevel, petQuality = myPetInfo[1], myPetInfo[2]
    --            table.insert(petStrings, self:QualityToColorCode(petQuality) .. "L" .. petLevel .. FONT_COLOR_CODE_CLOSE)
    --            if petQuality > maxQuality then
    --                maxQuality = petQuality
    --            end
    --            if petQuality >= rareQuality then
    --                rareCollected = rareCollected + 1
    --            end
    --        end
    --    end
    --    while #petStrings < limit do
    --        table.insert(petStrings, RED_FONT_COLOR_CODE .. "L0" .. FONT_COLOR_CODE_CLOSE)
    --    end
    --    petSummary = table.concat(petStrings, "/")
    --    totalSpeciesCount = totalSpeciesCount + 1
    --    if rareCollected >= limit then
    --        maxRareCollectedCount = maxRareCollectedCount + 1
    --    else
    --        local function openJournalToSpecies()
    --            if not CollectionsJournal then
    --                CollectionsJournal_LoadUI()
    --            end
    --            SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
    --            PetJournal_UpdateAll()
    --            PetJournal_SelectSpecies(PetJournal, speciesId)
    --            if RematchFrame.PetsPanel.Top.SearchBox then
    --                RematchFrame.PetsPanel.Top.SearchBox:SetText('"' .. speciesName .. '"')
    --                RematchFrame.PetsPanel.Top.SearchBox:OnTextChanged('"' .. speciesName .. '"')
    --            elseif PetJournalSearchBox then
    --                PetJournalSearchBox:SetText('"' .. speciesName .. '"')
    --            end
    --        end
    --        local sourceTypeIconPath = self:TooltipToSourceTypeIcon(speciesId)
    --        local speciesIcon = AceGUI:Create("Icon")
    --        speciesIcon:SetImage(speciesIconPath)
    --        speciesIcon:SetImageSize(16, 16)
    --        speciesIcon:SetHeight(18)
    --        speciesIcon:SetWidth(18)
    --        speciesIcon:SetCallback("OnClick", openJournalToSpecies)
    --        local sourceTypeIcon = AceGUI:Create("Icon")
    --        sourceTypeIcon:SetImage(sourceTypeIconPath)
    --        sourceTypeIcon:SetImageSize(16, 16)
    --        sourceTypeIcon:SetHeight(18)
    --        sourceTypeIcon:SetWidth(18)
    --        local label = AceGUI:Create("InteractiveLabel")
    --        label:SetText(speciesName .. " " .. petSummary) -- TODO: more styling
    --        label:SetCallback("OnClick", openJournalToSpecies)
    --        local line = AceGUI:Create("SimpleGroup")
    --        line:SetAutoAdjustHeight(true)
    --        line:SetFullWidth(true)
    --        line:SetLayout("Flow")
    --        line:AddChild(speciesIcon)
    --        line:AddChild(sourceTypeIcon)
    --        line:AddChild(label)
    --
    --        scroll:AddChild(line)
    --    end
    --end
    --local label = AceGUI:Create("InteractiveLabel")
    --label:SetText(string.format("%d/%d Complete", maxRareCollectedCount, totalSpeciesCount))
    --
    --local line = AceGUI:Create("SimpleGroup")
    --line:SetAutoAdjustHeight(true)
    --line:SetFullWidth(true)
    --line:SetLayout("Flow")
    --line:AddChild(label)
    --
    --scroll:AddChild(line)
end

function GoalTrackerModule:PopulateAllTab(container)
    --local petData = self:GetZonePetData()
    --
    --if not petData then
    --    local label = AceGUI:Create("InteractiveLabel")
    --    label:SetText("No pets found for current zone")
    --    container:AddChild(label)
    --    return
    --end
    --
    --local scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    --scrollContainer:SetFullWidth(true)
    --scrollContainer:SetFullHeight(true) -- probably?
    --scrollContainer:SetLayout("Fill") -- important!
    --
    --container:AddChild(scrollContainer)
    --
    --local scroll = AceGUI:Create("ScrollFrame")
    --scroll:SetLayout("Flow") -- probably?
    --scrollContainer:AddChild(scroll)
    --
    ---- TODO: handle no pets situation (no petData)
    ---- TODO: sort
    --
    --for speciesId, _ in pairs(petData) do
    --    local speciesName, speciesIconPath, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
    --    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
    --    local myPets = DataModule:GetOwnedPets(speciesId)
    --    local rareQuality = 4
    --    local rareCollected = 0
    --    local maxQuality = -1
    --    local petStrings = {}
    --    local petSummary
    --    if myPets ~= nil then
    --        for _, myPetInfo in ipairs(myPets) do
    --            local petLevel, petQuality = myPetInfo[1], myPetInfo[2]
    --            table.insert(petStrings, self:QualityToColorCode(petQuality) .. "L" .. petLevel .. FONT_COLOR_CODE_CLOSE)
    --            if petQuality > maxQuality then
    --                maxQuality = petQuality
    --            end
    --            if petQuality >= rareQuality then
    --                rareCollected = rareCollected + 1
    --            end
    --        end
    --    end
    --    while #petStrings < limit do
    --        table.insert(petStrings, RED_FONT_COLOR_CODE .. "L0" .. FONT_COLOR_CODE_CLOSE)
    --    end
    --    petSummary = table.concat(petStrings, "/")
    --    local function openJournalToSpecies()
    --        if not CollectionsJournal then
    --            CollectionsJournal_LoadUI()
    --        end
    --        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
    --        PetJournal_UpdateAll()
    --        PetJournal_SelectSpecies(PetJournal, speciesId)
    --        if RematchFrame.PetsPanel.Top.SearchBox then
    --            RematchFrame.PetsPanel.Top.SearchBox:SetText('"' .. speciesName .. '"')
    --            RematchFrame.PetsPanel.Top.SearchBox:OnTextChanged('"' .. speciesName .. '"')
    --        elseif PetJournalSearchBox then
    --            PetJournalSearchBox:SetText('"' .. speciesName .. '"')
    --        end
    --    end
    --    local sourceTypeIconPath = self:TooltipToSourceTypeIcon(speciesId)
    --    local speciesIcon = AceGUI:Create("Icon")
    --    speciesIcon:SetImage(speciesIconPath)
    --    speciesIcon:SetImageSize(16, 16)
    --    speciesIcon:SetHeight(18)
    --    speciesIcon:SetWidth(18)
    --    speciesIcon:SetCallback("OnClick", openJournalToSpecies)
    --    local sourceTypeIcon = AceGUI:Create("Icon")
    --    sourceTypeIcon:SetImage(sourceTypeIconPath)
    --    sourceTypeIcon:SetImageSize(16, 16)
    --    sourceTypeIcon:SetHeight(18)
    --    sourceTypeIcon:SetWidth(18)
    --    local label = AceGUI:Create("InteractiveLabel")
    --    label:SetText(speciesName .. " " .. petSummary) -- TODO: more styling
    --    label:SetCallback("OnClick", openJournalToSpecies)
    --    local line = AceGUI:Create("SimpleGroup")
    --    line:SetAutoAdjustHeight(true)
    --    line:SetFullWidth(true)
    --    line:SetLayout("Flow")
    --    line:AddChild(speciesIcon)
    --    line:AddChild(sourceTypeIcon)
    --    line:AddChild(label)
    --
    --    scroll:AddChild(line)
    --end
end
