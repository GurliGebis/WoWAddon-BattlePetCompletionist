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

BPC_MAP_TOOLTIP_BACKDROP = {
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
}

do
    local mapTooltipHeaderFont
    local cachedFontFile, cachedFontSize, cachedFontFlags
    local TOOLTIP_MAX_WIDTH = 350
    local TOOLTIP_PADDING = 16

    -- Cache font properties at load time to avoid calling GetFont() during
    -- tainted execution (which can return SECRET values in WoW 11.x).
    local function EnsureFontCached()
        if not cachedFontFile then
            cachedFontFile, cachedFontSize, cachedFontFlags = GameFontNormal:GetFont()
            cachedFontSize = cachedFontSize or 12
        end
    end

    function MapModule.Tooltip_Show(anchor, headerLine, collectedLine, sourceLine)
        EnsureFontCached()

        if not mapTooltipHeaderFont then
            mapTooltipHeaderFont = CreateFont("MapModuleHeaderFont")
            mapTooltipHeaderFont:SetFont(cachedFontFile, cachedFontSize + 2, cachedFontFlags)
        end

        -- Remove width constraints initially so we can measure natural widths
        BPCMapTooltip.Header:SetWidth(0)
        BPCMapTooltip.Source:SetWidth(0)
        BPCMapTooltip.Source:SetWordWrap(false)
        BPCMapTooltip.Collected:SetWidth(0)

        BPCMapTooltip.Header:SetFontObject(mapTooltipHeaderFont)
        BPCMapTooltip.Header:SetText(headerLine.text or "")

        if headerLine.color then
            BPCMapTooltip.Header:SetTextColor(headerLine.color.r, headerLine.color.g, headerLine.color.b)
        end

        if collectedLine then
            BPCMapTooltip.Collected:SetText(collectedLine.text or "")

            if collectedLine.color then
                BPCMapTooltip.Collected:SetTextColor(collectedLine.color.r, collectedLine.color.g, collectedLine.color.b)
            end

            BPCMapTooltip.Collected:Show()
            BPCMapTooltip.Source:ClearAllPoints()
            BPCMapTooltip.Source:SetPoint("TOPLEFT", BPCMapTooltip.Collected, "BOTTOMLEFT", 0, -2)
        else
            BPCMapTooltip.Collected:Hide()
            BPCMapTooltip.Source:ClearAllPoints()
            BPCMapTooltip.Source:SetPoint("TOPLEFT", BPCMapTooltip.Header, "BOTTOMLEFT", 0, -2)
        end

        BPCMapTooltip.Source:SetText(sourceLine.text or "")

        if sourceLine.color then
            BPCMapTooltip.Source:SetTextColor(sourceLine.color.r, sourceLine.color.g, sourceLine.color.b)
        end

        -- Measure dimensions dynamically. Determine natural content width, then
        -- clamp to TOOLTIP_MAX_WIDTH. If clamped, enable word wrap on Source so
        -- long zone text wraps instead of overflowing. Use pcall to safely handle
        -- SECRET values from tainted execution contexts.
        local ok, tooltipWidth, totalHeight = pcall(function()
            local headerWidth    = BPCMapTooltip.Header:GetStringWidth()
            local collectedWidth = BPCMapTooltip.Collected:IsShown() and BPCMapTooltip.Collected:GetStringWidth() or 0
            local sourceWidth    = BPCMapTooltip.Source:GetStringWidth()
            local naturalWidth   = math.max(headerWidth, collectedWidth, sourceWidth) + TOOLTIP_PADDING
            local width          = math.min(math.max(140, naturalWidth), TOOLTIP_MAX_WIDTH)

            -- If content exceeds max width, constrain FontStrings and enable wrap
            if naturalWidth > TOOLTIP_MAX_WIDTH then
                local textWidth = width - TOOLTIP_PADDING
                BPCMapTooltip.Header:SetWidth(textWidth)
                BPCMapTooltip.Source:SetWidth(textWidth)
                BPCMapTooltip.Source:SetWordWrap(true)
                BPCMapTooltip.Collected:SetWidth(textWidth)
            end

            local headerHeight    = BPCMapTooltip.Header:GetStringHeight()
            local collectedHeight = BPCMapTooltip.Collected:IsShown() and (BPCMapTooltip.Collected:GetStringHeight() + 2) or 0
            local sourceHeight    = BPCMapTooltip.Source:GetStringHeight()
            local height          = headerHeight + collectedHeight + sourceHeight + 2 + TOOLTIP_PADDING -- +2 for Source top gap

            return width, height
        end)

        if not ok then
            -- Fallback: use max width with wrap and estimated height
            local textWidth = TOOLTIP_MAX_WIDTH - TOOLTIP_PADDING
            BPCMapTooltip.Header:SetWidth(textWidth)
            BPCMapTooltip.Source:SetWidth(textWidth)
            BPCMapTooltip.Source:SetWordWrap(true)
            BPCMapTooltip.Collected:SetWidth(textWidth)

            tooltipWidth = TOOLTIP_MAX_WIDTH
            local headerLineHeight = cachedFontSize + 2 + 4
            local normalLineHeight = cachedFontSize + 4
            local lineCount = 1

            if collectedLine then
                lineCount = lineCount + 1
            end

            lineCount = lineCount + 1
            totalHeight = headerLineHeight + (lineCount - 1) * normalLineHeight + 2 + TOOLTIP_PADDING
        end

        BPCMapTooltip:SetWidth(tooltipWidth)
        BPCMapTooltip:SetHeight(totalHeight)
        BPCMapTooltip:ClearAllPoints()
        BPCMapTooltip:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 10, 0)
        BPCMapTooltip:Show()
    end

    function MapModule:Tooltip_Hide()
        BPCMapTooltip:Hide()
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
