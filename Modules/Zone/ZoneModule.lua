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
local ZoneModule = BattlePetCompletionist:NewModule("ZoneModule", "AceEvent-3.0")

function ZoneModule:OnInitialize()
    self:RegisterEventHandlers()
end


function ZoneModule:RegisterEventHandlers()
    self:RegisterEvent("ZONE_CHANGED", "ResolveZone")
    self:RegisterEvent("ZONE_CHANGED_INDOORS", "ResolveZone")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ResolveZone")
    self:RegisterEvent("NEW_WMO_CHUNK", "ResolveZone")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ResolveZone")
end

-- We store the mapID rather than calling the API every time, so that we can detect changes.
-- This allows skipping updates when nothing we care about has changed, improving CPU usage.
-- This function fires an event if the resolved zone has changed, and returns the current zone's map ID.
function ZoneModule:ResolveZone()
    -- If we wanted to exclude certain sub-zones from being eligible for selection, we could do so using data from
    -- C_Map.GetMapInfo, such as parentMapID.  However, this appears sufficient for now.
    local mapID = C_Map.GetBestMapForUnit("player")
    -- self.mapID will be nil on first check
    if mapID ~= self.mapID then
        self.mapID = mapID
        self:SendMessage(_BattlePetCompletionist.Events.ZONE_CHANGE, mapID)
    end
    return self.mapID
end
