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
local BrokerModule = BattlePetCompletionist:GetModule("BrokerModule")

function BattlePetCompletionist_OnAddonCompartmentClick(addonName, button)
    BrokerModule:OnClick(button)
end

function BattlePetCompletionist_OnAddonCompartmentEnter(addonName, button)
    GameTooltip:SetOwner(AddonCompartmentFrame)
    BrokerModule:OnTooltipShow(GameTooltip, false)
    GameTooltip:Show()
end

function BattlePetCompletionist_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide()
end
