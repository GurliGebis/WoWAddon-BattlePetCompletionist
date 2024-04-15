local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
local BrokerModule = BattlePetCompletionist:NewModule("BrokerModule", "AceEvent-3.0")
local DataModule = BattlePetCompletionist:GetModule("DataModule")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibPetJournal = LibStub("LibPetJournal-2.0")

function BrokerModule:GetDataObjectName()
    return BattlePetCompletionist:GetName()
end

-- Also used by MinimapModule
function BrokerModule:GetDataObject()
    return self.dataSource
end

function BrokerModule:RegisterEventHandlers()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "RefreshData")
    LibPetJournal.RegisterCallback(self, "PetListUpdated", "RefreshData")
end

function BrokerModule:GetZonePetData()
    local mapId = C_Map.GetBestMapForUnit("player")
    return DataModule:GetPetsInMap(mapId) or {}
end

function BrokerModule:OnInitialize()
    self.dataSource = LibDataBroker:NewDataObject(self:GetDataObjectName(), {
        type = "data source",
        label = "BattlePets",
        icon = "Interface\\Icons\\Inv_Pet_Achievement_CaptureAWildPet",
        OnClick = function(_, button)
            self:OnClick(button)
        end,
        OnTooltipShow = function(tooltip)
            self:OnTooltipShow(tooltip)
        end,
        OnLeave = HideTooltip
    })
    self:RegisterEventHandlers()
end

-- Also used by AddonCompartmentModule
function BrokerModule:OnTooltipShow(tooltip)
    -- TODO: left vs. right click instructions
    tooltip:AddLine("Battle Pet Completionist")
    tooltip:AddLine("|cffffff00Click|r to open the options dialog.")
end

-- Also used by AddonCompartmentModule
function BrokerModule:OnClick(button)
    if button == "LeftButton" then
        -- TODO: show new window
        InterfaceOptionsFrame_OpenToCategory(ConfigModule.OptionsFrame)
    elseif button == "RightButton" then
        InterfaceOptionsFrame_OpenToCategory(ConfigModule.OptionsFrame)
    end
end

function BrokerModule:GetNumCollectedInfo(speciesId)
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
    local myPets = DataModule:GetOwnedPets(speciesId)
    local rareQuality = 4
    local numRareCollected = 0
    if myPets ~= nil then
        for _, myPetInfo in ipairs(myPets) do
            local petQuality = myPetInfo[2]
            if petQuality >= rareQuality then
                numRareCollected = numRareCollected + 1
            end
        end
    end
    return numCollected, numRareCollected, limit
end

function BrokerModule:RefreshData()
    local count = 0
    local totalCount = 0
    local petData = self:GetZonePetData()
    local goal = ConfigModule.AceDB.profile.brokerGoal
    local goalTextEnabled = ConfigModule.AceDB.profile.brokerGoalTextEnabled
    for speciesId, _ in pairs(petData) do
        totalCount = totalCount + 1
        local numCollected, numRareCollected, limit = self:GetNumCollectedInfo(speciesId)
        if goal == "G1COLLECT" then
            if numCollected > 0 then count = count + 1 end
        elseif goal == "G2COLLECTRARE" then
            if numRareCollected > 0 then count = count + 1 end
        elseif goal == "G3COLLECTMAX" then
            if numCollected >= limit then count = count + 1 end
        elseif goal == "G4COLLECTMAXRARE" then
            if numRareCollected >= limit then count = count + 1 end
        end
    end
    local suffix
    if not goalTextEnabled then
        suffix = ""
    elseif goal == "G1COLLECT" then
        suffix = " Collected"
    elseif goal == "G2COLLECTRARE" then
        suffix = " Rare"
    elseif goal == "G3COLLECTMAX" then
        suffix = " Max Collected"
    elseif goal == "G4COLLECTMAXRARE" then
        suffix = " Max Rare"
    end
    self.dataSource.text = string.format("%d/%d%s", count, totalCount, suffix)
end
