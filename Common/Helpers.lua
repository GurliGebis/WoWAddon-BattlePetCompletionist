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

function BattlePetCompletionist.GetGameEdition()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return _BattlePetCompletionist.Enums.GameEdition.RETAIL
    else
        return _BattlePetCompletionist.Enums.GameEdition.CLASSIC
    end
end

function BattlePetCompletionist.IsOceanic()
    -- This function is to tell if a realm is Oceanic. It uses RealmIDs to be language agnostic.
    -- It was last updated on 2026 10 12
    -- https://warcraft.wiki.gg/wiki/API:GetRealmID | https://warcraft.wiki.gg/wiki/API:GetRealmName
    -- https://github.com/phanx-wow/LibRealmInfo | https://github.com/janekjl/LibRealmInfo
    local Oceanic = {
        [3721] = true, -- Caelestrasz
        [3722] = true, -- Aman'Thul
        [3723] = true, -- Barthilas
        [3724] = true, -- Thaurissan
        [3725] = true, -- Frostmourne
        [3726] = true, -- Khaz'goroth
        [3733] = true, -- Dreadmaul
        [3734] = true, -- Nagrand
        [3735] = true, -- Dath'Remar
        [3736] = true, -- Jubei'Thos
        [3737] = true, -- Gundrak
        [3738] = true, -- Saurfang
        -- these do not appear in realm selection as of 2026 10 12
        --[4667] = true, -- Remulos
        --[4669] = true, -- Arugal
        --[4670] = true, -- Yojamba
        --[4739 = true, -- Felstriker
    }
    local RealmID = GetRealmID()
    if Oceanic[RealmID] then
        return true
    else
        return false
    end
end

