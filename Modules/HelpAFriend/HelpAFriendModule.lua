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
local HelpAFriendModule = BattlePetCompletionist:NewModule("HelpAFriendModule", "AceEvent-3.0", "AceComm-3.0")
local ConfigModule = BattlePetCompletionist:GetModule("ConfigModule")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local AceSerializer = LibStub("AceSerializer-3.0")

local messagePrefixes = {
    ANNOUNCE_PETS = "BPC_ANNOUNCE",
    I_NEED_PETS   = "BPC_INEEDPETS",
    OFFER_PETS    = "BPC_OFFERPETS",
    ACCEPT_OFFER  = "BPC_ACCEPTOFFER",
    DECLINE_OFFER = "BPC_DECLINEOFFER"
}

local offerSentTo = ""

function HelpAFriendModule:OnEnable()
    if TomTom == nil then
        -- TomTom is required for this functionality to work.
        return
    end

    self:RegisterEvent("PET_BATTLE_OPENING_START", "BattleHasStarted")

    self:RegisterComm(messagePrefixes.ANNOUNCE_PETS, "OnReceivedAnnounce")
    self:RegisterComm(messagePrefixes.I_NEED_PETS, "OnReceivedINeedPets")
    self:RegisterComm(messagePrefixes.OFFER_PETS, "OnReceivedOfferPets")
    self:RegisterComm(messagePrefixes.ACCEPT_OFFER, "OnReceivedAcceptOffer")
    self:RegisterComm(messagePrefixes.DECLINE_OFFER, "OnReceivedDeclineOffer")
end

local function CanWeFindPlayerPosition()
    local mapId = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapId, "player")

    -- In some cases, we cannot get the player position, so there is no coordinates to share.
    return position ~= nil
end

function HelpAFriendModule:BattleHasStarted()
    if ConfigModule:IsHelpAFriendEnabled() == false then
        return
    end

    if CanWeFindPlayerPosition() == false then
        -- We are inside an instance (or the WoD garrison), so we cannot get our position.
        -- This means that we have nothing to share, so no need to continue.
        return
    end

    if DataModule:CanWeCapturePets() == false then
        -- We cannot capture any pets in this battle, so nothing to share.
        return
    end

    local notOwnedPets, ownedPets = DataModule.GetEnemyPetsInBattle()

    if (#notOwnedPets > 0) then
        -- There are one or more uncollected pets, so we shouldn't do anything.
        -- We prioritize ourselves first.
        return
    end

    -- If we end up here, the "Help a Friend" setting is enabled, we are in a pet battle, and we have already captured all the pets found.
    -- So we announce in the party addon channel, what we have, in case someone might need anything.
    self:SendCommMessage(messagePrefixes.ANNOUNCE_PETS, AceSerializer:Serialize(ownedPets), "PARTY")
end

function HelpAFriendModule:OnReceivedAnnounce(_, msg, _, sender)
    local myName = UnitName("player")

    if sender == myName then
        return
    end

    local success, pets = AceSerializer:Deserialize(msg)

    if success == false then
        return
    end

    -- We received an announce from a party member.
    -- We check if the pets they have found are already captured by us.
    local notOwnedPets = {}

    for i = 1, #pets do
        local speciesId = pets[i][1]

        if DataModule:GetOwnedPets(speciesId) == nil then
            table.insert(notOwnedPets, speciesId)
        end
    end

    if #notOwnedPets == 0 then
        -- We have all the pets they have found, so we don't reply.
        return
    end

    -- The sender is in a battle with some pets, and we are missing them, so we tell the sender.
    self:SendCommMessage(messagePrefixes.I_NEED_PETS, AceSerializer:Serialize(notOwnedPets), "WHISPER", sender)
end

function HelpAFriendModule:OnReceivedINeedPets(_, msg, _, sender)
    local myName = UnitName("player")

    if sender == myName then
        -- We should never get this from ourselves, but just in case it might happen, we handle it.
        return
    end

    local success, pets = AceSerializer:Deserialize(msg)

    if success == false then
        return
    end

    -- Someone in our party has reported that they are missing some of the pets - first we find the names of the pets.
    local petNames = {}

    for i = 1, #pets do
        local speciesName = C_PetJournal.GetPetInfoBySpeciesID(pets[i])
        table.insert(petNames, speciesName)
    end

    -- Now we find our own position.
    local mapId = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    local x, y = position:GetXY()

    local message = {
        ["mapId"] = mapId,
        ["mapX"] = string.format("%.2f", x * 100),
        ["mapY"] = string.format("%.2f", y * 100),
        ["petNames"] = petNames
    }

    local dialogMessage = "Someone (" .. sender .. ") in your party needs one or more pets you are battling.|n|nDo you want to offer them these pets and send your location?|n|nNeeded pets: " .. table.concat(petNames, ", ")

    -- Ask the player if they want to notify the party member.
    _G.StaticPopupDialogs[messagePrefixes.I_NEED_PETS] = {
        text = dialogMessage,
        OnAccept = function()
            -- We do, so we store their name and sent the offer.
            offerSentTo = sender
            self:SendCommMessage(messagePrefixes.OFFER_PETS, AceSerializer:Serialize(message), "WHISPER", sender)
        end,

        timeout = 10,
        button1 = _G.YES,
        button2 = _G.NO
    }

    _G.StaticPopup_Show(messagePrefixes.I_NEED_PETS)
end

function HelpAFriendModule:OnReceivedOfferPets(_, msg, _, sender)
    local myName = UnitName("player")

    if sender == myName then
        -- We should never get this from ourselves, but just in case it might happen, we handle it.
        return
    end

    local success, message = AceSerializer:Deserialize(msg)

    if success == false then
        return
    end

    -- We have received an offer for some pets from a party member.
    -- First we find out which map the user is on and ask the player if they want the pets.
    local mapInfo = C_Map.GetMapInfo(tonumber(message["mapId"]))
    local dialogMessage = "Someone (" .. sender .. " - in zone: " .. mapInfo["name"] .. ") in your party is offering you the following battle pets.|n|nBy clicking Accept, a TomTom waypoint will be created, and a notifaction will be sent.|n|nNeeded pets: " .. table.concat(message["petNames"], ", ")

    _G.StaticPopupDialogs[messagePrefixes.OFFER_PETS] = {
        text = dialogMessage,
        OnAccept = function()
            -- We have accepted the offer, so we create a TomTom waypoint
            local icon = "Interface\\icons\\inv_pet_achievement_captureawildpet"

            local options = {
                title = "Battle Pet Completionist friend - " .. sender,
                minimap_icon = icon,
                worldmap_icon = icon
            }

            TomTom:AddWaypoint(tonumber(message["mapId"]), tonumber(message["mapX"]) / 100, tonumber(message["mapY"] / 100), options)

            -- And send the accept message.
            self:SendCommMessage(messagePrefixes.ACCEPT_OFFER, AceSerializer.Serialize(message), "WHISPER", sender)
        end,
        OnCancel = function()
            -- We have declined, so we send the decline message.
            self:SendCommMessage(messagePrefixes.DECLINE_OFFER, AceSerializer.Serialize(message), "WHISPER", sender)
        end,

        button1 = _G.ACCEPT,
        button2 = _G.DECLINE
    }

    _G.StaticPopup_Show(messagePrefixes.OFFER_PETS)
end

function HelpAFriendModule:OnReceivedAcceptOffer(_, msg, _, sender)
    local myName = UnitName("player")

    if sender == myName then
        -- We should never get this from ourselves, but just in case it might happen, we handle it.
        return
    end

    if sender ~= offerSentTo then
        -- Someone is sending us an accept, but we haven't send them an offer, so we just return.
        return
    end

    local success = AceSerializer:Deserialize(msg)

    if success == false then
        return
    end

    -- The other player accepted our offer.
    offerSentTo = ""
    local dialogMessage = sender .. " has accepted your offer|n|nPlease wait for them before forfeiting."

    _G.StaticPopupDialogs[messagePrefixes.ACCEPT_OFFER] = {
        text = dialogMessage,

        timeout = 10,
        button1 = _G.OKAY
    }

    _G.StaticPopup_Show(messagePrefixes.ACCEPT_OFFER)
end

function HelpAFriendModule:OnReceivedDeclineOffer(_, msg, _, sender)
    local myName = UnitName("player")

    if sender == myName then
        -- We should never get this from ourselves, but just in case it might happen, we handle it.
        return
    end

    if sender ~= offerSentTo then
        -- Someone is sending us an accept, but we haven't send them an offer, so we just return.
        return
    end

    local success = AceSerializer:Deserialize(msg)

    if success == false then
        return
    end

    -- The other player declined our offer.
    offerSentTo = ""
    local dialogMessage = sender .. " has declined your offer."

    _G.StaticPopupDialogs[messagePrefixes.DECLINE_OFFER] = {
        text = dialogMessage,

        timeout = 10,
        button1 = _G.OKAY
    }

    _G.StaticPopup_Show(messagePrefixes.DECLINE_OFFER)
end