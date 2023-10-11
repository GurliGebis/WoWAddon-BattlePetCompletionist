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

BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
MinimapModule = BattlePetCompletionist:NewModule("MinimapModule")
ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")

local MinimapIcon = nil

function MinimapModule:OnInitialize()
    if ConfigModule.AceDB.profile.minimapIconEnabled then
        MinimapModule:CreateMinimapIcon()
    end

    MinimapModule:UpdateMinimap()
end

function MinimapModule:ShowIcon()
    if MinimapIcon == nil then
        self:CreateMinimapIcon()
    end

    MinimapIcon:Show("BattlePetCompletionist")
end

function MinimapModule:HideIcon()
    if MinimapIcon == nil then
        return
    end

    MinimapIcon:Hide("BattlePetCompletionist")
end

function MinimapModule:UpdateMinimap()
    if ConfigModule.AceDB.profile.minimapIconEnabled then
        MinimapModule:ShowIcon()
    else
        MinimapModule:HideIcon()
    end
end

local function IconOrCompartmentClicked()
    InterfaceOptionsFrame_OpenToCategory(ConfigModule.OptionsFrame)
end

function MinimapModule:CreateMinimapIcon()
    local LibDataBroker = LibStub("LibDataBroker-1.1", true)
    MinimapIcon = LibDataBroker and LibStub("LibDBIcon-1.0", true)

    if LibDataBroker == nil then
        return
    end

    local minimapButton = LibDataBroker:NewDataObject("BPCBtn", {
        type = "launcher",
        text = "Battle Pet Completionist",
        icon = "Interface\\Icons\\Inv_Pet_Achievement_CaptureAWildPet",
        OnClick = function(_, button)
            if button == "LeftButton" then
                IconOrCompartmentClicked()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Battle Pet Completionist")
            tooltip:AddLine("|cffffff00Click|r to open the options dialog.")
        end,
        OnLeave = HideTooltip
    })

    if MinimapIcon then
        ConfigModule.AceDB.global.minimap = ConfigModule.AceDB.global.minimap or {}
        MinimapIcon:Register("BattlePetCompletionist", minimapButton, ConfigModule.AceDB.global.minimap)
    end
end

function BattlePetCompletionist_OnAddonCompartmentClick(addonName, button)
    IconOrCompartmentClicked()
end

function BattlePetCompletionist_OnAddonCompartmentEnter(addonName, button)
    GameTooltip:SetOwner(AddonCompartmentFrame)
    GameTooltip:AddLine("Battle Pet Completionist")
    GameTooltip:AddLine("|cffffff00Click|r to open the options dialog.")
    GameTooltip:Show()
end

function BattlePetCompletionist_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide()
end
