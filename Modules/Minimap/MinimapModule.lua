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

local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
local MinimapModule = BattlePetCompletionist:NewModule("MinimapModule")
local ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")
local BrokerModule = BattlePetCompletionist:GetModule("BrokerModule")
local LibDBIcon = LibStub("LibDBIcon-1.0")

function MinimapModule:GetMinimapName()
    return BattlePetCompletionist:GetName()
end

function MinimapModule:IsMinimapIconEnabled()
    return ConfigModule.AceDB.profile.minimapIconEnabled
end

function MinimapModule:InitializeMinimapConfig()
    ConfigModule.AceDB.global.minimap = ConfigModule.AceDB.global.minimap or {}
    return ConfigModule.AceDB.global.minimap
end

function MinimapModule:OnInitialize()
    self:UpdateMinimap()
end

function MinimapModule:ShowIcon()
    if not LibDBIcon:IsRegistered(self:GetMinimapName()) then
        LibDBIcon:Register(self:GetMinimapName(), BrokerModule:GetDataObject(), self:InitializeMinimapConfig())
    end
    LibDBIcon:Show(self:GetMinimapName())
end

function MinimapModule:HideIcon()
    LibDBIcon:Hide(self:GetMinimapName())
end

function MinimapModule:UpdateMinimap()
    if self:IsMinimapIconEnabled() then
        self:ShowIcon()
    else
        self:HideIcon()
    end
end
