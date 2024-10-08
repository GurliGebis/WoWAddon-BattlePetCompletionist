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
local MapModule = BattlePetCompletionist:NewModule("MapModule", "AceConsole-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local AceHook = LibStub("AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_Map")

MapModule.WorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin)

function MapModule.WorldMapDataProvider:RemoveAllData()
    if self:GetMap() then
        self:GetMap():RemoveAllPinsByTemplate("BPetCompletionistWorldMapPinTemplate")
    end
end

function MapModule.WorldMapDataProvider:RefreshAllData()
    if not self:GetMap() then
        return
    end

    self:RemoveAllData()

    self:LoadMapData(self:GetMap():GetMapID())
end

function MapModule.WorldMapDataProvider:LoadMapData(mapId)
    if not self:GetMap() then
        return
    end

    if not mapId then
        return
    end

    local petData = DataModule:GetPetsInMap(mapId)
    local map = self:GetMap()

    if petData == nil then
        return
    end

    local petIconType = DBModule:GetProfile().mapPinIconType
    for pet, locations in pairs(petData) do
        if DataModule:ShouldPetBeShown(pet) then
            local _, speciesIcon, petType = C_PetJournal.GetPetInfoBySpeciesID(pet)

            if petIconType == _BattlePetCompletionist.Enums.MapPinIconType.FAMILY then
                local typeIcons = {
                    "Interface\\icons\\Icon_PetFamily_Humanoid",
                    "Interface\\icons\\Icon_PetFamily_Dragon",
                    "Interface\\icons\\Icon_PetFamily_Flying",
                    "Interface\\icons\\Icon_PetFamily_Undead",
                    "Interface\\icons\\Icon_PetFamily_Critter",
                    "Interface\\icons\\Icon_PetFamily_Magical",
                    "Interface\\icons\\Icon_PetFamily_Elemental",
                    "Interface\\icons\\Icon_PetFamily_Beast",
                    "Interface\\icons\\Icon_PetFamily_Water",
                    "Interface\\icons\\Icon_PetFamily_Mechanical"
                }

                speciesIcon = typeIcons[petType]
            end

            for x, y in gmatch(locations, "(%d%d%d)(%d%d%d)") do
                local realX = (tonumber(x) / 1000)
                local realY = (tonumber(y) / 1000)

                local pin = map:AcquirePin("BPetCompletionistWorldMapPinTemplate", realX, realY, speciesIcon)
                pin.PetSpeciesID = pet
                pin.MapId = mapId
            end
        end
    end
end

BattlePetCompletionistWorldMapPinMixin = CreateFromMixins(MapCanvasPinMixin)

function BattlePetCompletionistWorldMapPinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_HIGHLIGHT")
    self:SetMovable(true)
    self:SetScalingLimits(1, 1.0, 1.2);
end

-- hack to avoid error in combat in 10.1.5
BattlePetCompletionistWorldMapPinMixin.SetPassThroughButtons = function() end

function BattlePetCompletionistWorldMapPinMixin:OnAcquired(x, y, iconpath)
    self:SetPosition(x, y)

    local scale = MapModule:GetMapPinScale()

    local iconSize = 12 * scale
    local borderSize = 24 * scale

    self:SetSize(iconSize, iconSize)
    self:SetAlpha(1)

    local icon = self.Icon
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetVertexColor(1, 1, 1, 1)
    icon:SetTexture(iconpath)

    local iconBorder = self.IconBorder
    iconBorder:SetSize(borderSize, borderSize)
end

function BattlePetCompletionistWorldMapPinMixin:OnMouseEnter()
    local speciesName, speciesIcon, _, _, tooltipSource = C_PetJournal.GetPetInfoBySpeciesID(self.PetSpeciesID)

    local ownedPets = DataModule:GetOwnedPets(self.PetSpeciesID)

    local iconDimensions = 20
    local headline = "|T" .. speciesIcon .. ":" .. iconDimensions .. ":" .. iconDimensions .. ":-2:0|t " .. speciesName

    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:SetText(headline, 1, 1, 1)

    if ownedPets ~= nil then
        local ownedPetTexts = {}

        for _, v in ipairs(ownedPets) do
            -- Array index is 0 based, which quality index for pets is 1 based, so subtract 1
            local qualityIndex = v[2] - 1
            local color = ITEM_QUALITY_COLORS[qualityIndex].hex

            table.insert(ownedPetTexts, color .. v[1] .. "|r")
        end

        GameTooltip:AddLine(string.format(L["Collected"], table.concat(ownedPetTexts, ", ")))
    end

    GameTooltip:AddLine(tooltipSource, 1, 1, 1, true)
    GameTooltip:Show()
end

function BattlePetCompletionistWorldMapPinMixin:OnMouseLeave()
    GameTooltip:Hide()
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
        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
        PetJournal_SelectSpecies(PetJournal, self.PetSpeciesID);
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

    return scaleMap[DBModule:GetProfile().mapPinSize]
end

function MapModule:OnInitialize()
    MapModule:RegisterChatCommand("bpcom-toggle", "BattlePetToggle_OnClick")
end