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
local CaptureModule = BattlePetCompletionist:NewModule("CaptureModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local DBModule = BattlePetCompletionist:GetModule("DBModule")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_Capture")

function CaptureModule:OnEnable()
    self:RegisterEvent("PET_BATTLE_OPENING_START", "BattleHasStarted")
end

function CaptureModule:BattleHasStarted()
    if not DBModule:IsPetBattleUnknownNotifyEnabled() then
        return
    end

    if not DataModule:CanWeCapturePets() then
        return
    end

    local notOwnedPets = DataModule:GetEnemyPetsInBattle()

    if (#notOwnedPets > 0) then
        self:CreateUncollectPetsDialog(notOwnedPets)
    end
end

function CaptureModule:CreateUncollectPetsDialog(pets)
    local frame = CreateFrame("Frame", nil, UIParent, "SimplePanelTemplate")
    frame:SetPoint("TOP", 0, -100)
    frame:SetSize(240, 95 + (#pets * 35))
    frame:SetResizable(false)
    frame:SetMovable(false)
    frame:SetClampedToScreen(true)

    local header = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")

    if (#pets == 1) then
        header:SetText(L["Uncollected pet found"])
    else
        header:SetText(L["Uncollected pets found"])
    end

    header:SetPoint("TOPLEFT", frame, 16, -40)

    for i = 1, #pets do
        local pet = pets[i]

        local speciesName, speciesIcon = C_PetJournal.GetPetInfoBySpeciesID(pet[1])
        local qualityIndex = pet[2] - 1
        local color = ITEM_QUALITY_COLORS[qualityIndex].hex

        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(speciesIcon)
        icon:SetSize(32, 32)
        icon:SetPoint("TOPLEFT", header, -4, 12 -(i * 36))

        local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        text:SetText(color .. speciesName .. "|r")
        text:SetPoint("LEFT", icon, 40, 0)
    end

    frame:Show()

    C_Timer.After(5, function()
        frame:Hide()
    end)
end
