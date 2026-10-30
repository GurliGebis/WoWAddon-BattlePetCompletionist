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

    -----------------------------------------------------------------------

    This File is for Battle Pet Completionist.
    It is meant to help brainstorm the Implementation of the FR "Calendar
    Reminders" ...     FR Link:
    https://github.com/GurliGebis/WoWAddon-BattlePetCompletionist/issues/86

    This ties into the Data Folder Data Files. Uses the Example on seeing
    the number we have and max in there
--]]

local addonName, _ = ...
local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon(addonName)
local DBModule = BattlePetCompletionist:GetModule("DBModule")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local AvailableActivityModule = BattlePetCompletionist:NewModule("AvailableActivityModule", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName .. "_AvailableActivity")

function AvailableActivityModule:OnInitialize()
    self.dataReady = { calendar = false, pets = false, process = false, }
    self.calendarWaitStarted = false
    self.pendingQuestLoads = {}
    self.pendingQuestCount = 0

    self.EventFrame = CreateFrame("Frame")
    self.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.EventFrame:SetScript("OnEvent", function(selfFrame, event, ...)
        AvailableActivityModule:OnEvent(event, ...)
    end)

    self:RegisterChatCommand("bpcom-activities", "ShowActivityWindow_OnChatCommand")
end

function AvailableActivityModule:ShowActivityWindow_OnChatCommand()
    self:Print(L["Module not currently supported in this WoW version."])
    self:Print(L["If you would like to use it in this version, please open a Feature Request at "] .. "https://github.com/GurliGebis/WoWAddon-BattlePetCompletionist/issues")
end
