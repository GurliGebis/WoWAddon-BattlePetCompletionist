local BattlePetCompletionist = LibStub("AceAddon-3.0"):GetAddon("BattlePetCompletionist")
local BrokerModule = BattlePetCompletionist:GetModule("BrokerModule")

function BattlePetCompletionist_OnAddonCompartmentClick(addonName, button)
    BrokerModule:OnClick(button)
end

function BattlePetCompletionist_OnAddonCompartmentEnter(addonName, button)
    GameTooltip:SetOwner(AddonCompartmentFrame)
    BrokerModule:OnTooltipShow(GameTooltip, false)
    GameTooltip:Show()
end

function BattlePetCompletionist_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide()
end
