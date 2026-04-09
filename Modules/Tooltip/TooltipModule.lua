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
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local TooltipModule = BattlePetCompletionist:NewModule("TooltipModule")

function TooltipModule:OnEnable()
    hooksecurefunc("BattlePetToolTip_Show", function(speciesID, ...)
        if DBModule:IsPetCageTooltipEnabled() then
            C_Timer.After(0, function()
                if BattlePetTooltip:IsShown() then
                    TooltipModule.ModifyPetTip(speciesID)
                end
            end)
        end
    end)
end

function TooltipModule.ModifyPetTip(speciesID)
    local _, _, _, _, source = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

    if source and source ~= "" then
        BattlePetTooltip:AddLine(" ", 1, 1, 1, false)
        BattlePetTooltip:AddLine(source, 1, 1, 1, true)
    end
end
