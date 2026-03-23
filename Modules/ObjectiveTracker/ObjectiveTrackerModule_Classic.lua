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

-- MoP Classic objective tracker integration.
-- Uses the WatchFrame / WATCHFRAME_OBJECTIVEHANDLERS system instead of the
-- Retail ObjectiveTrackerModuleMixin block-based API.

if WOW_PROJECT_ID ~= WOW_PROJECT_MISTS_CLASSIC then return end

-- WatchFrame dash constants are locals in WatchFrame.lua, so we redeclare
-- the values we need here.
local BPC_DASH_NONE = 0
local BPC_DASH_SHOW = 1

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local ObjectiveTrackerModule = BattlePetCompletionist:NewModule("ObjectiveTrackerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local ZoneModule = BattlePetCompletionist:GetModule("ZoneModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_ObjectiveTracker")

-- Lines owned by this module so we can release them on the next redraw.
local bpcLines = {}
local bpcLineCount = 0

-- Acquire a fresh line from the WatchFrame pool, tracking it for later release.
local function AcquireLine()
    local line = WatchFrame.linePool:Acquire()
    line:Reset()
    bpcLineCount = bpcLineCount + 1
    bpcLines[bpcLineCount] = line
    return line
end

-- Release all lines acquired during the previous draw pass.
local function ReleaseLines()
    for i = 1, bpcLineCount do
        WatchFrame.linePool:Release(bpcLines[i])
        bpcLines[i] = nil
    end
    bpcLineCount = 0
end

-- Build the sorted, filtered pet list for the current zone.
-- Returns nil when nothing should be displayed.
local function GetPetList()
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
    local filteredPets = {}
    for speciesId in pairs(pets) do
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesId)
        if numCollected == 0 then
            anyMissing = true
        end
        local speciesName = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
        tinsert(filteredPets, { speciesId = speciesId, numCollected = numCollected, speciesName = speciesName })
    end

    -- Sort by species name, fall back to species ID for unnamed entries.
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

    if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and not anyMissing then
        return nil
    end

    return filteredPets, mapID, anyMissing
end

-- Called by WatchFrame_Update for every registered objective handler.
-- Signature: handler(lineFrame, nextAnchor, maxHeight, frameWidth)
--   -> nextAnchor, maxWidth, numObjectives, numPopUps
local function BPC_DisplayBattlePets(lineFrame, nextAnchor, maxHeight, frameWidth)
    -- Release lines from the previous draw pass first.
    ReleaseLines()

    local filteredPets, mapID = GetPetList()
    if not filteredPets then
        return nextAnchor, 0, 0, 0
    end

    local profile = DBModule:GetProfile()

    -- Determine which pets to actually render based on the filter setting.
    local petsToShow = {}
    for _, petInfo in ipairs(filteredPets) do
        if profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.ALL
            or (profile.objectiveTrackerFilter == _BattlePetCompletionist.Enums.MapPinFilter.MISSING and petInfo.numCollected == 0)
        then
            if petInfo.speciesName then
                tinsert(petsToShow, petInfo)
            end
        end
    end

    if not next(petsToShow) then
        return nextAnchor, 0, 0, 0
    end

    local mapInfo = C_Map.GetMapInfo(mapID)
    local zoneName = mapInfo and mapInfo.name or L["current zone"]

    local maxWidth = 0
    local lastLine = nil

    -- Header line (styled like a quest title: gold colour).
    local headerLine = AcquireLine()
    local headerText = string.format(L["Battle Pets in %s"], zoneName)
    WatchFrame_SetLine(headerLine, lastLine, -WATCHFRAME_QUEST_OFFSET, true --[[isHeader]], headerText, BPC_DASH_NONE)
    if not nextAnchor then
        headerLine:SetPoint("RIGHT", lineFrame, "RIGHT", 0, 0)
        headerLine:SetPoint("LEFT",  lineFrame, "LEFT",  0, 0)
        headerLine:SetPoint("TOP",   lineFrame, "TOP",   0, -WATCHFRAME_INITIAL_OFFSET)
    else
        headerLine:SetPoint("RIGHT", lineFrame,    "RIGHT", 0, 0)
        headerLine:SetPoint("LEFT",  lineFrame,    "LEFT",  0, 0)
        headerLine:SetPoint("TOP",   nextAnchor, "BOTTOM", 0, -WATCHFRAME_TYPE_OFFSET)
    end
    headerLine:Show()
    maxWidth = math.max(maxWidth, headerLine.text:GetStringWidth())
    lastLine = headerLine

    -- One objective line per pet.
    for _, petInfo in ipairs(petsToShow) do
        local line = AcquireLine()

        -- Collected pets are shown dimmed (grey-ish text already default in
        -- WatchFrame_SetLine for non-header lines); uncollected are white.
        -- We don't have easy access to coloured text outside the standard
        -- WatchFrame flow, so we just pass the text through and let the
        -- default styling apply.  Collected pets get a checkmark prefix to
        -- make them visually distinct.
        local displayName
        if petInfo.numCollected > 0 then
            displayName = "|cff00ff00" .. petInfo.speciesName .. "|r"
        else
            displayName = petInfo.speciesName
        end

        WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, false --[[isHeader]], displayName, BPC_DASH_SHOW)
        line:Show()

        maxWidth = math.max(maxWidth, line.text:GetStringWidth() + line.dash:GetWidth())
        lastLine = line

        -- Stop if we've run out of vertical space.
        local bottom = lastLine:GetBottom()
        if bottom and bottom < WatchFrame:GetBottom() then
            break
        end
    end

    return lastLine, maxWidth, #petsToShow, 0
end

do
    function ObjectiveTrackerModule:OnInitialize()
        -- Register for events that should trigger a WatchFrame refresh.
        self:RegisterEvent("PET_JOURNAL_LIST_UPDATE", "OnPetEvent")
        self:RegisterEvent("ZONE_CHANGED",            "OnPetEvent")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA",   "OnPetEvent")
        self:RegisterEvent("PLAYER_ENTERING_WORLD",   "OnPetEvent")
    end

    function ObjectiveTrackerModule:OnEnable()
        WatchFrame_AddObjectiveHandler(BPC_DisplayBattlePets)
    end

    function ObjectiveTrackerModule:OnDisable()
        WatchFrame_RemoveObjectiveHandler(BPC_DisplayBattlePets)
        ReleaseLines()
        WatchFrame_Update()
    end

    function ObjectiveTrackerModule:OnPetEvent(event, ...)
        WatchFrame_Update()
    end

    -- Called by ConfigModule when the user changes tracker settings.
    function ObjectiveTrackerModule:OnEvent(event, ...)
        WatchFrame_Update()
    end
end
