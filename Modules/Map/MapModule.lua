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
local MapModule = BattlePetCompletionist:NewModule("MapModule", "AceConsole-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_Map")

MapModule.WorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin)

function MapModule.WorldMapDataProvider:OnCanvasScaleChanged()
    local map = self:GetMap()

    if not map then
        return
    end

    -- OnCanvasScaleChanged fires on every frame while the map is open. Only
    -- refresh when the zoom level value actually changes, so we rebuild pins
    -- at each distinct zoom level without hammering every frame.
    local currentZoom = map:GetCanvasZoomPercent()

    if currentZoom ~= self._lastZoom then
        self._lastZoom = currentZoom
        self:RefreshAllData()
    end
end

function MapModule.WorldMapDataProvider:RemoveAllData()
    self:HideAllPins()
end

function MapModule.WorldMapDataProvider:RefreshAllData()
    if not self:GetMap() then
        return
    end

    -- Defer refresh if GameTooltip is currently shown to avoid running pin
    -- updates while Blizzard's tooltip code is active, which can cause taint
    -- to propagate into the tooltip rendering pipeline.
    if GameTooltip:IsShown() then
        C_Timer.After(0.1, function()
            if self:GetMap() then
                self:RefreshAllData()
            end
        end)
        return
    end

    if not DataModule:HasAnyDataLoaded() then
        C_Timer.After(0, function()
            StaticPopup_Show("BATTLEPETCOMPLETIONIST_NO_DATA")
        end)
        return
    end

    self:LoadMapData(self:GetMap():GetMapID())
end

function MapModule.WorldMapDataProvider:LoadMapData(mapId)
    self:BeginPinAllocation()

    if not self:GetMap() then
        self:FinishPinAllocation()
        return
    end

    if not mapId then
        self:FinishPinAllocation()
        return
    end

    local function IsTooCloseToExistingPin(placedPositions, x, y, threshold)
        for _, pos in ipairs(placedPositions) do
            if math.abs(pos[1] - x) < threshold and math.abs(pos[2] - y) < threshold then
                return true
            end
        end

        return false
    end

    local petData = DataModule:GetPetsInMap(mapId)
    local map = self:GetMap()

    if petData == nil then
        self:FinishPinAllocation()
        return
    end

    local function GetMapZoomPercent(map)
        if not map or not map.ScrollContainer or not map.ScrollContainer.HasZoomLevels or not map.GetCanvasZoomPercent then
            return 0
        end

        return map.ScrollContainer:HasZoomLevels() and map:GetCanvasZoomPercent() or 0
    end

    local petIconType = DBModule:GetProfile().mapPinIconType

    for pet, locations in pairs(petData) do
        if DataModule:ShouldPetBeShown(pet) then
            local _, speciesIcon, petType = C_PetJournal.GetPetInfoBySpeciesID(pet)

            if petIconType == _BattlePetCompletionist.Enums.MapPinIconType.FAMILY then
                speciesIcon = _BattlePetCompletionist.Constants.PET_TYPE_ICONS[petType]
            end

            local placedPositions = {}
            local zoomPercent = GetMapZoomPercent(map)
            local threshold = (0.01 * MapModule:GetMapPinScale()) / (1 + zoomPercent * 3)

            for x, y in gmatch(locations, "(%d%d%d)(%d%d%d)") do
                local realX = (tonumber(x) / 1000)
                local realY = (tonumber(y) / 1000)

                if not IsTooCloseToExistingPin(placedPositions, realX, realY, threshold) then
                    local pin = self:AcquirePoolPin(realX, realY, speciesIcon)
                    pin.PetSpeciesID = pet
                    pin.MapId = mapId

                    table.insert(placedPositions, { realX, realY })
                end
            end
        end
    end

    self:FinishPinAllocation()
end

BattlePetCompletionistWorldMapPinMixin = CreateFromMixins(MapCanvasPinMixin)

function BattlePetCompletionistWorldMapPinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_HIGHLIGHT")
    self:SetMovable(true)
    self:SetScalingLimits(1, 1.0, 1.2)
end

function BattlePetCompletionistWorldMapPinMixin:OnAcquired(x, y, iconpath)
    self:SetPosition(x, y)
    MapModule.WorldMapDataProvider:SetupPinAppearance(self, iconpath)
    self:SetAlpha(1)
    self:EnableMouse(true)
end

function BattlePetCompletionistWorldMapPinMixin:OnMouseEnter()
    local speciesName, speciesIcon, _, _, tooltipSource = C_PetJournal.GetPetInfoBySpeciesID(self.PetSpeciesID)

    local ownedPets = DataModule:GetOwnedPets(self.PetSpeciesID)

    local iconDimensions = 20
    local headline = "|T" .. speciesIcon .. ":" .. iconDimensions .. ":" .. iconDimensions .. ":-2:0|t " .. speciesName
    local headerLine = { text = headline, color = HIGHLIGHT_FONT_COLOR }

    local collectedLine = nil

    if ownedPets ~= nil then
        local ownedPetTexts = {}

        for _, v in ipairs(ownedPets) do
            -- Array index is 0 based, which quality index for pets is 1 based, so subtract 1
            local qualityIndex = v[2] - 1
            local color = ITEM_QUALITY_COLORS[qualityIndex].hex

            table.insert(ownedPetTexts, color .. v[1] .. "|r")
        end

        collectedLine = { text = string.format(L["Collected"], table.concat(ownedPetTexts, ", ")), color = NORMAL_FONT_COLOR }
    end

    local sourceLine = { text = MapModule.WrapTextWithColor(HIGHLIGHT_FONT_COLOR, tooltipSource) }

    MapModule.Tooltip_Show(self, headerLine, collectedLine, sourceLine)
end

function BattlePetCompletionistWorldMapPinMixin:OnMouseLeave()
    MapModule:Tooltip_Hide()
end

function BattlePetCompletionistWorldMapPinMixin:OnMouseClickAction(button)
    if button ~= "LeftButton" then
        return
    end

    if IsShiftKeyDown() then
        if TomTom and DBModule:GetProfile().tomtomIntegration then
            local x, y = self:GetPosition()
            local mapId = self.MapId
            local speciesName = C_PetJournal.GetPetInfoBySpeciesID(self.PetSpeciesID)
            local icon = "Interface\\icons\\inv_pet_achievement_captureawildpet"

            local options = {
                title = speciesName,
                minimap_icon = icon,
                worldmap_icon = icon
            }

            TomTom:AddWaypoint(mapId, x, y, options)
        end
    else
        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
        PetJournal_SelectSpecies(PetJournal, self.PetSpeciesID)
    end
end

function MapModule:UpdateWorldMap()
    MapModule.WorldMapDataProvider:RefreshAllData()
end

function MapModule:BattlePetToggle_GetStatus()
    return DBModule:GetProfile().mapPinsToInclude ~= _BattlePetCompletionist.Enums.MapPinFilter.NONE
end

function MapModule:BattlePetToggle_OnClick()
    local profile = DBModule:GetProfile()

    if profile.mapPinsToInclude == _BattlePetCompletionist.Enums.MapPinFilter.NONE then
        profile.mapPinsToInclude = profile.mapPinsToIncludeOriginal
        MapModule:Print(L["Tracking enabled"])
    else
        profile.mapPinsToIncludeOriginal = profile.mapPinsToInclude
        profile.mapPinsToInclude = _BattlePetCompletionist.Enums.MapPinFilter.NONE
        MapModule:Print(L["Tracking disabled"])
    end

    MapModule:UpdateWorldMap()
end

function MapModule:InitializeDropDown()
    Menu.ModifyMenu("MENU_WORLD_MAP_TRACKING", function(_, rootDescription)
		rootDescription:CreateDivider()
		rootDescription:CreateTitle(L["Dropdown Headline"])
		rootDescription:CreateCheckbox(L["Show Battle Pets"], MapModule.BattlePetToggle_GetStatus, MapModule.BattlePetToggle_OnClick)
    end)
end

function MapModule:OnEnable()
    WorldMapFrame:AddDataProvider(MapModule.WorldMapDataProvider)
    MapModule:InitializeDropDown()

    self:UpdateWorldMap()
end

function MapModule:OnDisable()
    if WorldMapFrame.dataProviders[MapModule.WorldMapDataProvider] then
        MapModule.WorldMapDataProvider:ReleaseAllPins()
        WorldMapFrame:RemoveDataProvider(MapModule.WorldMapDataProvider)
    end
end

function MapModule:GetMapPinScale()
    local scaleMap = {
        [_BattlePetCompletionist.Enums.MapPinSize.X_SMALL] = 0.8,
        [_BattlePetCompletionist.Enums.MapPinSize.SMALL] = 1.0,
        [_BattlePetCompletionist.Enums.MapPinSize.MEDIUM] = 1.2,
        [_BattlePetCompletionist.Enums.MapPinSize.LARGE] = 1.4,
    }

    return scaleMap[DBModule:GetProfile().mapPinSize] or 1.0
end

function MapModule:OnInitialize()
    MapModule:RegisterChatCommand("bpcom-toggle", "BattlePetToggle_OnClick")
end

_G.StaticPopupDialogs["BATTLEPETCOMPLETIONIST_NO_DATA"] = {
    text = L["No pet data loaded! Please install the Battle Pet Completionist data addon BattlePetCompletionist_PetData or disable this addon."],
    button1 = _G.OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
