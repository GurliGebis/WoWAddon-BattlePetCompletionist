BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
BrokerModule = BattlePetCompletionist:NewModule("BrokerModule", "AceEvent-3.0")
DataModule = BattlePetCompletionist:GetModule("DataModule")
LibDataBroker = LibStub("LibDataBroker-1.1")

function BrokerModule:GetDataObject()
    -- TODO: use dataSource
    return self.launcher
end

function BrokerModule:OnInitialize()
    self.launcher = LibDataBroker:NewDataObject("BPCBtn", {
        type = "launcher",
        text = "Battle Pet Completionist",
        icon = "Interface\\Icons\\Inv_Pet_Achievement_CaptureAWildPet",
        OnClick = function(_, button)
            self:OnClick(button)
        end,
        OnTooltipShow = function(tooltip)
            self:OnTooltipShow(tooltip)
        end,
        OnLeave = HideTooltip
    })
end

-- Also used by AddonCompartmentModule
function BrokerModule:OnTooltipShow(tooltip)
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
