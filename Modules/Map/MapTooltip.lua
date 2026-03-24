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

do
    local mapTooltip
    local mapTooltipHeaderFont

    function MapModule.Tooltip_Show(anchor, lines)
        if not mapTooltipHeaderFont then
            local fontFile, fontSize, fontFlags = GameFontNormal:GetFont()
            mapTooltipHeaderFont = CreateFont("MapModuleHeaderFont")
            mapTooltipHeaderFont:SetFont(fontFile, fontSize + 2, fontFlags)
        end

        if not mapTooltip then
            mapTooltip = CreateFrame("Frame", "BPCMapTooltip", UIParent, "BackdropTemplate")
            mapTooltip:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            mapTooltip:SetBackdropColor(0, 0, 0, 0.9)
            mapTooltip:SetFrameStrata("TOOLTIP")
            mapTooltip.lines = {}
        end

        for i, line in ipairs(lines) do
            local fs = mapTooltip.lines[i]

            if not fs then
                fs = mapTooltip:CreateFontString(nil, "ARTWORK")
                fs:SetJustifyH("LEFT")
                mapTooltip.lines[i] = fs
            end

            if line.fontObject then
                fs:SetFontObject(line.fontObject)
            elseif i == 1 then
                fs:SetFontObject(mapTooltipHeaderFont)
            else
                fs:SetFontObject(GameFontNormal)
            end

            fs:SetText(line.text or "")

            if line.color then
                fs:SetTextColor(line.color.r, line.color.g, line.color.b)
            end

            fs:Show()

            if i == 1 then
                fs:SetPoint("TOPLEFT", mapTooltip, "TOPLEFT", 8, -8)
            else
                fs:SetPoint("TOPLEFT", mapTooltip.lines[i-1], "BOTTOMLEFT", 0, -2)
            end
        end

        for i = #lines + 1, #mapTooltip.lines do
            mapTooltip.lines[i]:Hide()
        end

        local maxWidth = 0
        local totalHeight = 0

        for i = 1, #lines do
            local fs = mapTooltip.lines[i]
            local w = fs:GetStringWidth()

            if w > maxWidth then
                maxWidth = w
            end

            totalHeight = totalHeight + fs:GetStringHeight() + 2
        end

        mapTooltip:SetWidth(math.max(140, maxWidth + 16))
        mapTooltip:SetHeight(totalHeight + 16)
        mapTooltip:ClearAllPoints()
        mapTooltip:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 10, 0)
        mapTooltip:Show()
    end

    function MapModule:Tooltip_Hide()
        if mapTooltip then
            mapTooltip:Hide()
        end
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
end
