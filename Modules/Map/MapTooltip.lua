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
local MapModule = BattlePetCompletionist:GetModule("MapModule")

--region Helpers

local function AddLine(text, color)
    local c = color or NORMAL_FONT_COLOR
    BPCMapTooltip:AddLine(text or "", c.r, c.g, c.b, true)
end

function MapModule.WrapTextWithColor(color, text)
    if not color or text == nil then
        return text
    end

    local r = math.floor((color.r or 1) * 255 + 0.5)
    local g = math.floor((color.g or 1) * 255 + 0.5)
    local b = math.floor((color.b or 1) * 255 + 0.5)

    return string.format("|cff%02x%02x%02x%s|r", r, g, b, text)
end

--endregion

--region Tooltip Show/Hide

function MapModule.Tooltip_Show(anchor, lines)
    BPCMapTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    BPCMapTooltip:ClearLines()

    for _, line in ipairs(lines) do
        AddLine(line.text, line.color)
    end

    BPCMapTooltip:ClearAllPoints()
    BPCMapTooltip:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 10, 0)
    BPCMapTooltip:Show()
end

function MapModule:Tooltip_Hide()
    BPCMapTooltip:Hide()
end

--endregion
