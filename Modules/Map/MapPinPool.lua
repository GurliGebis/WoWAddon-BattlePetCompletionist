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

-- Pin pool: pins are acquired once and reused across refreshes. This avoids
-- calling RemoveAllPinsByTemplate (which internally calls Hide() and triggers
-- synchronous mouse-focus recalculation that propagates taint to AreaPOI pins).
local pinPool = {}
local activeCount = 0
local allocIndex = 0

local function HidePin(pin)
    pin:SetAlpha(0)
    pin:EnableMouse(false)
end

function MapModule.WorldMapDataProvider:HideAllPins()
    -- Visually hide all active pins without calling Hide() or releasing them.
    -- SetAlpha(0) is purely visual and does not trigger mouse-focus recalculation.
    for i = 1, activeCount do
        local pin = pinPool[i]

        if pin then
            HidePin(pin)
        end
    end

    activeCount = 0
    allocIndex = 0
end

function MapModule.WorldMapDataProvider:ReleaseAllPins()
    -- Full teardown: release all pooled pins back to the map's pin pool.
    -- Only called on OnDisable when the data provider is removed entirely.
    self:HideAllPins()

    if self:GetMap() then
        self:GetMap():RemoveAllPinsByTemplate("BPetCompletionistWorldMapPinTemplate")
    end

    wipe(pinPool)
end

function MapModule.WorldMapDataProvider:BeginPinAllocation()
    allocIndex = 0
end

function MapModule.WorldMapDataProvider:AcquirePoolPin(x, y, iconpath)
    allocIndex = allocIndex + 1
    local map = self:GetMap()
    local pin = pinPool[allocIndex]

    if not pin then
        -- Acquire a new pin and add it to the pool permanently
        pin = map:AcquirePin("BPetCompletionistWorldMapPinTemplate", x, y, iconpath)
        pinPool[allocIndex] = pin
    else
        -- Reuse existing pin: update position and appearance
        pin:SetPosition(x, y)
        self:SetupPinAppearance(pin, iconpath)
    end

    pin:SetAlpha(1)
    pin:EnableMouse(true)
    return pin
end

function MapModule.WorldMapDataProvider:FinishPinAllocation()
    -- Hide any leftover pins from the previous refresh that weren't reused.
    for i = allocIndex + 1, activeCount do
        local pin = pinPool[i]

        if pin then
            HidePin(pin)
        end
    end

    activeCount = allocIndex
end

function MapModule.WorldMapDataProvider:SetupPinAppearance(pin, iconpath)
    local scale = MapModule:GetMapPinScale()
    local iconSize = 12 * scale
    local borderSize = 24 * scale

    pin:SetSize(iconSize, iconSize)

    local icon = pin.Icon
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetVertexColor(1, 1, 1, 1)
    icon:SetTexture(iconpath)

    local iconBorder = pin.IconBorder
    iconBorder:SetSize(borderSize, borderSize)
end
