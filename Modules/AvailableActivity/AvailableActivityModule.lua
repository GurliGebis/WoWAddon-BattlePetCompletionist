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
    self.dataReady = { calendar = false, covenant = false, pets = false, process = false, }
    self.calendarWaitStarted = false
    self.pendingQuestLoads = {}
    self.pendingQuestCount = 0
    self.callingsData = nil

    self.EventFrame = CreateFrame("Frame")
    self.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.EventFrame:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    self.EventFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    self.EventFrame:RegisterEvent("COVENANT_CALLINGS_UPDATED")
    self.EventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

    self.EventFrame:SetScript("OnEvent", function(selfFrame, event, ...)
        AvailableActivityModule:OnEvent(event, ...)
    end)

    self:RegisterChatCommand("bpcom-activities", "ShowActivityWindow_OnChatCommand")
end

function AvailableActivityModule:ShowActivityWindow_OnChatCommand()
    if InCombatLockdown() then
        self:Print(L["This cannot be used while in combat."])
        return
    end

    if self.dataReady.process then
        self:Print(L["Refresh is in progress, please wait."])
        return
    end

    self:StartProcess(true)
end

function AvailableActivityModule:StartProcess(command)
    if InCombatLockdown() then
        return
    end

    local profile = DBModule:GetProfile()

    self.warnCondition = profile.availableActivityAlerts
    self.today = C_DateAndTime.GetCurrentCalendarTime()

    if not self.today then
        -- Still not ready (can happen if this fires very early, e.g. right on
        -- login). Retry shortly instead of letting the rest of the process
        -- run with a nil self.today, which would error later on.
        C_Timer.After(1, function()
            AvailableActivityModule:StartProcess()
        end)
        return
    end

    self.dataReady.process = true
    self.dataReady.calendar = false
    self.calendarWaitStarted = false

    -- this is a default false that allows for slashcommand override
    self.dataReady.pets = command or false

    -- this tells the system to get the ShadowLands Covenant Callings for the day
    C_CovenantCallings.RequestCallings()

    -- this tells the calendar when we are at to cache this month initially
    -- this prevents a looping issue as sometimes the calendar never figures
    -- out the current month without it.
    C_Calendar.SetAbsMonth(self.today.month, self.today.year)
    C_Calendar.OpenCalendar()

    -- OpenCalendar() only fires CALENDAR_UPDATE_EVENT_LIST when it actually
    -- has to fetch new data. If the calendar data is already cached (e.g. the
    -- player already opened the calendar this session), the event never
    -- fires and we'd wait forever for it. WaitForCalendarReady polls the
    -- actual API state directly, so kick it off immediately as well; the
    -- calendarWaitStarted guard prevents it from running twice if the event
    -- does also fire.
    AvailableActivityModule:BeginCalendarWait()
end

function AvailableActivityModule:BeginCalendarWait()
    if InCombatLockdown() then
        return
    end

    if self.calendarWaitStarted then
        return
    end

    self.calendarWaitStarted = true
    AvailableActivityModule:WaitForCalendarReady()
end

function AvailableActivityModule:GetQuestTitle(questID)
    if InCombatLockdown() then
        return
    end

    -- guard against a bad quest id being passed
    -- (if there's an update we didnt fully implement, etc)
    if not questID then
        return
    end

    local title = C_QuestLog.GetTitleForQuestID(questID)
    if issecretvalue(title) then
        return
    end

    if title then
        return title
    end

    if not self.pendingQuestLoads[questID] then
        self.pendingQuestLoads[questID] = true
        self.pendingQuestCount = self.pendingQuestCount + 1
        C_QuestLog.RequestLoadQuestByID(questID)
    end
end

function AvailableActivityModule:IsAchievementComplete(achievementID)
    if InCombatLockdown() then
        return
    end

    local complete = select(4, GetAchievementInfo(achievementID))

    if issecretvalue(complete) then
        return
    end

    return complete
end

function AvailableActivityModule:IsQuestAvailable(questID, questType)
    if InCombatLockdown() then
        return
    end

    -- guard against a bad quest id being passed
    -- (if there's an update we didnt fully implement, etc)
    if not questID then
        return
    end

    local available = false

    -- note: this uses if/elseif on the chance there are other types,
    -- so that they may be added easier.
    if questType == "world" then
        -- this only returns on world quests.
        available = C_TaskQuest.IsActive(questID)
    elseif questType == "daily" then
        -- this is for daily quests
        if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
            available = true
        end
    end

    if issecretvalue(available) then
        return
    end

    return available
end

function AvailableActivityModule:IsPetSought(petNpcID)
    if InCombatLockdown() then
        return
    end

    local maxAllowed, numPets = C_PetJournal.GetNumPetsInJournal(petNpcID)

    if issecretvalue(maxAllowed) or issecretvalue(numPets) then
        return
    end

    local threshhold = 1

    if self.warnCondition == "NOT_MAX_COLLECTED" then
        threshhold = maxAllowed
    elseif self.warnCondition == "MAX_TWO" then
        if 1 < maxAllowed then
            threshhold = 2
        end
    end

    return numPets < threshhold
end

function AvailableActivityModule:GetPetData(pets, islandID)
    if InCombatLockdown() then
        return
    end

    local results = {}

    -- note: pet data we can get is:
    -- speciesName, speciesIcon, petType, companionID, tooltipSource,
    -- tooltipDescription, isWild, canBattle, isTradeable, isUnique,
    -- obtainable, creatureDisplayID
    islandID = islandID or 0
    pets = pets or {}

    for _,pet in ipairs(pets) do
        if AvailableActivityModule:IsPetSought(pet.petNpcID) then
            local petName, _ = C_PetJournal.GetPetInfoBySpeciesID(pet.petSpeciesID)

            if not issecretvalue(petName) then
                local petLink = "|cff1eff00|Hbattlepet:" .. pet.petSpeciesID .. ":1:3:1:::BattlePet--:|h[" .. petName .. "]|h|r"
                if pet.islands and (islandID > 0) then
                    local first = true
                    for _, mapID in ipairs(pet.islands) do
                        if mapID ~= islandID then
                            if first then
                                petLink = petLink .. L[" also from "] .. C_Map.GetMapInfo(mapID).name
                                first = false
                            else
                                petLink = petLink .. L[", "] .. C_Map.GetMapInfo(mapID).name
                            end
                        end
                    end
                end
                table.insert(results, { petSpeciesID = pet.petSpeciesID, petName = petName, linkValue = petLink, linkType = "battlepet", })
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildIslandQuestList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for mapID, sourceEntry in pairs(dataSource) do
        local title = ""
        if mapID > 0 then
            title = C_Map.GetMapInfo(mapID).name
        elseif mapID == -1 then
            title = "From Any Island Expedition"
        end

        if AvailableActivityModule:tableSize(sourceEntry.pets) == 0 then
            return results
        end

        local links = AvailableActivityModule:GetPetData(sourceEntry.pets, mapID)
        local entry = AvailableActivityModule:BuildActivityEntry("Island Expeditions", title, links)

        if entry then
            table.insert(results, entry)
        end
    end

    return results
end

function AvailableActivityModule:SeasonalPets()
    if InCombatLockdown() then
        return
    end

    --[[
        This function checks for and returns seasonal pets that are based
        on set calendar dates, and not calendar events. Currently known Pets:

        Starts | Ends   | NPCID | PetID | Pet Name
        Jun 21 | Sep 23 | 62256 | 513   | Qiraji Guardling
        Dec 22 | Mar 19 | 7554  | 69    | Snowy Owl
    --]]

    local seasonal = nil
    local links = nil
    local pets = nil
    local md = self.today.month * 100 + self.today.monthDay -- make today look like 1011

    if 620 < md and md < 924 then -- if it's after june 20 (620) and before sep 24 (924) aka WoW Summer
		pets = {{ petNpcID = 62256, petSpeciesID = 513 }}
		links = AvailableActivityModule:GetPetData(pets)
		seasonal = AvailableActivityModule:BuildActivityEntry("Calendar Events", "Summer Season", links)
    elseif md < 320 or 1221 < md then -- if it's after dec 21 (1221) and before mar 20 (320) aka WoW Winter
		pets = {{ petNpcID = 7554, petSpeciesID = 69 }}
		links = AvailableActivityModule:GetPetData(pets)
		seasonal = AvailableActivityModule:BuildActivityEntry("Calendar Events", "Winter Season", links)
    end

    return seasonal
end

function AvailableActivityModule:BuildTimedZoneEventActivityList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for mapID, eventData in pairs(dataSource) do
        if eventData.requireTimer then
            inactiveZone = AvailableActivityModule:InactiveZoneCheck(mapID)

            for zoneName, eventZone in pairs(eventData.events) do
                if inactiveZone ~= eventZone.mapZone then
                    local title = zoneName
                    local links = AvailableActivityModule:GetPetData(eventZone.pets)
                    local entry = AvailableActivityModule:BuildActivityEntry("Timed Zone Event Rares", title, links)

                    if entry then
                        table.insert(results, entry)
                    end
                end
            end
        else
            local mapQuests = C_TaskQuest.GetQuestsOnMap(mapID) -- fails if old zone is active!
            if issecretvalue(mapQuests) then
                return results
            end

            if AvailableActivityModule:tableSize(mapQuests) == 0 then
                local linkTitle = L["Ensure you have the current "] .. C_Map.GetMapInfo(mapID).name .. L[" open & active. Check with"] .. " Zidormi."
                local links = { { petSpeciesID = nil, petName = nil, linkType = nil,
    linkValue = "\124cff0070dd\124Hitem:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0\124h[" .. linkTitle .. "]\124h\124r"
                    } }
                local entry = AvailableActivityModule:BuildActivityEntry("Timed Zone Event Rares", L["Are you a Time Traveler?"], links)
                table.insert(results, entry)
            else
                for _, questData in ipairs(mapQuests) do
                    local activity = nil
                    activity = eventData.events[questData.questID]
                    if activity ~= nil then
                        local title = AvailableActivityModule:GetQuestTitle(questData.questID)
                        local links = AvailableActivityModule:GetPetData(activity.pets)
                        local entry = AvailableActivityModule:BuildActivityEntry("Timed Zone Event Rares", title, links)

                        if entry then
                            table.insert(results, entry)
                        end
                    end
                end
            end
        end
    end

    return results
end

function AvailableActivityModule:InactiveZoneCheck(MapID)
    if InCombatLockdown() then
        return
    end

    local serverTime = (C_DateAndTime.GetServerTimeLocal() + C_DateAndTime.GetSecondsUntilDailyReset())
    if issecretvalue(serverTime) then
        return
    end

    local modMe = floor(serverTime/86400)

    local locations = {
        [1469] = { 1, 2, },
	    [2133] = { 1, 2, 3, 4, }
    }

    local checkme = locations[MapID]
    local modBy = #checkme
    local inactiveID = checkme[(modMe%modBy)+1]

    if MapID == 1469 then
        inactiveID = 1
        if C_TaskQuest.IsActive(57157) then
            inactiveID = 2
        end
    end

    return inactiveID
end

function AvailableActivityModule:MicroHolidays()
    if InCombatLockdown() then
        return
    end

    --[[
        This function checks for and returns microholidays which cannot be tracked
        by traditional means. The list is as follows:
        NPCID | PetID | Pet Name | Holiday | Time Info
        67022 | 1013  | Wanderer's Festival Hatchling | Wanderer's Festival | Sundays from 9 pm to 11 pm
        Reference: https://us.forums.blizzard.com/en/wow/t/wanderers-festival-timing-clarification/2379938
        Reference: https://www.wowhead.com/event=1052/wanderers-festival#comments:id=6241762
        Reference: https://www.wowhead.com/npc=67022/wanderers-festival-hatchling#comments:id=1790187
    --]]

    local micros = nil
    local links = nil
    local pets = nil
    local dow = C_DateAndTime.GetCurrentCalendarTime().weekday

    if dow == 1 then -- if it is sunday
        pets = {{ petNpcID = 67022, petSpeciesID = 1013 }}
        links = AvailableActivityModule:GetPetData(pets)
        local title = "Wanderer's Festival: 9pm to 11pm"
        local region = GetCurrentRegion()
        --[[
            regions: 1 is US & Oceanic (use PT & AET respectively) -- Multiple TZs
            2 is KR which uses Korean Standard Time - No Daylight Savings - One TZ
            3 is EU which uses CET -- Multiple TZs
            4 is TW which uses China Standard Time aka Taipei Time - No Daylight Savings - One TZ
            5 is CN which uses China Standard Time aka Taipei Time - One TZ
        --]]
        if region == 1 then -- Americas & Oceanic
            if BattlePetCompletionist.IsOceanic() then -- Oceanic -> Australian Eastern Time
                title = title .. " AET"
            else -- Americas -> Pacific Time
                title = title .. " PT"
            end
        elseif region == 3 then -- EU
            title = title .. " CET"
        end
        micros = AvailableActivityModule:BuildActivityEntry("Calendar Events", title, links)
    end

    return micros
end

function AvailableActivityModule:BuildActivityEntry(category, title, petLinks, subCategory)
    if InCombatLockdown() then
        return
    end

    if not petLinks or #petLinks == 0 then
        return nil
    end

    local builtEntry = { category = category, title = title, pets = petLinks }

    if subCategory then
        builtEntry.subcategory = subCategory
    end

    return builtEntry
end

function AvailableActivityModule:BuildCalendarEventList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    local numEvents = C_Calendar.GetNumDayEvents(0, self.today.monthDay)

    if issecretvalue(numEvents) then
        return
    end

    for eventNum = 1, numEvents do
        local event = C_Calendar.GetDayEvent(0, self.today.monthDay, eventNum) or nil

        if not issecretvalue(event) then
            local sourceEntry = dataSource[event.eventID]
            if sourceEntry then
                local title = event.title

                -- Pet Battle Week is a special case.
                -- It uses an Item ID instead of Pet ID as it rewards a
                -- Battle Pet Levelling Stone, and thus is always of interest
                local links

                if 565 == event.eventID then -- pet battle week
                    links = { {
                        petSpeciesID = 122457, petName = "Ultimate Battle-Training Stone", linkType = "item",
                        linkValue = "|cffa335ee|Hitem:122457::::::::90:::::|h[Ultimate Battle-Training Stone]|h|r"
                    } }
                else -- regular event
                    links = AvailableActivityModule:GetPetData(sourceEntry.pets)
                end

                local entry = AvailableActivityModule:BuildActivityEntry("Calendar Events", title, links)

                if entry then
                    table.insert(results, entry)
                end
            end
        end
    end

    local seasonal = AvailableActivityModule:SeasonalPets()
	if seasonal then
        table.insert(results, seasonal)
    end

    local micros = AvailableActivityModule:MicroHolidays()
    if micros then
        table.insert(results, micros)
    end

    return results
end

function AvailableActivityModule:BuildBountyQuestList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}
    local bounties = C_QuestLog.GetBountiesForMapID(627)
    if issecretvalue(bounties) then
        return
    end

    for _,bountyData in ipairs(bounties) do
        local sourceEntry = dataSource[bountyData]
        if sourceEntry ~= nil then
            local title = AvailableActivityModule:GetQuestTitle(bountyData.questID)
            local links = AvailableActivityModule:GetPetData(sourceEntry.pets)
            local entry = AvailableActivityModule:BuildActivityEntry("Bounty Quests", title, links)

            if entry then
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildCovenantQuestList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}
    local unlocked = C_CovenantCallings.AreCallingsUnlocked()
    if issecretvalue(unlocked) then
        return
    end
    if not unlocked then
        local linkTitle = L["You need to unlock Covenants"]
        results = { { category = "Covenant Callings", title = L["Covenants Not Unlocked"],
            pets = { { petSpeciesID = nil, petName = nil, linkType = nil,
    linkValue = "\124cff0070dd\124Hitem:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0\124h[" .. linkTitle .. "]\124h\124r"
        } } } }
    end

    local aligned = C_Covenants.GetActiveCovenantID()
    if issecretvalue(aligned) then
        return
    end
    if not aligned or aligned <= 0 then
        local linkTitle = L["You need to choose a Covenant"]
        results = { { category = "Covenant Callings", title = L["No Covenant Chosen"],
            pets = { { petSpeciesID = nil, petName = nil, linkType = nil,
    linkValue = "\124cff0070dd\124Hitem:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0\124h[" .. linkTitle .. "]\124h\124r"
        } } } }
    end

    -- protective and possibly not necessary. here for safety.
    if self.callingsData == nil then
        return
    end

    for _,callingData in ipairs(self.callingsData) do
        local sourceEntry = dataSource[callingData.questID]
        if sourceEntry ~= nil then
            local title = AvailableActivityModule:GetQuestTitle(callingData.questID)
            local links = AvailableActivityModule:GetPetData(sourceEntry.pets)
            local entry = AvailableActivityModule:BuildActivityEntry("Covenant Callings", title, links)

            if entry then
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildParagonEventActivityList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for repID, repData in pairs(dataSource) do
        repInfo = C_Reputation.GetFactionDataByID(repID)
        if issecretvalue(repInfo) then
            repInfo = nil
        end

	    if repInfo ~= nil then
            local title = repInfo.name
            local links = AvailableActivityModule:GetPetData(repData.pets)
            local entry = AvailableActivityModule:BuildActivityEntry("Paragon Reputations", title, links)

            if entry then
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildDailyQuestList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for questID, sourceEntry in pairs(dataSource) do
        if AvailableActivityModule:IsQuestAvailable(questID, "daily") then
            local title = AvailableActivityModule:GetQuestTitle(questID)
            local links = AvailableActivityModule:GetPetData(sourceEntry.pets)
            local entry = AvailableActivityModule:BuildActivityEntry("Daily Quests", title, links)

            if entry then
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildWorldQuestList(dataSource)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for questID, sourceEntry in pairs(dataSource) do
        if AvailableActivityModule:IsQuestAvailable(questID, "world") then
            local title = AvailableActivityModule:GetQuestTitle(questID)
            local links = AvailableActivityModule:GetPetData(sourceEntry.pets)
            local entry = AvailableActivityModule:BuildActivityEntry("World Quests", title, links)

            if entry then
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:AchievementCriteriaCheck(achievementID, questType, seenQuestIDs, criteriaToQuestMap)
    if InCombatLockdown() then
        return
    end

    local criteriaTitle, criteriaType, criteriaComplete, assetID, criteriaID, numCriteria
    local necessaryCriteria = {}
    local criteriaToQuestMap = criteriaToQuestMap or {}
    local seenQuestIDs = seenQuestIDs or {}
    local numCriteria = GetAchievementNumCriteria(achievementID)

    if issecretvalue(numCriteria) then
        return
    end

    for criteriaIndex = 1, numCriteria do
        criteriaTitle,criteriaType,criteriaComplete,_,_,_,_,assetID,_,criteriaID = GetAchievementCriteriaInfo(achievementID,criteriaIndex)

        if not (issecretvalue(criteriaTitle) or issecretvalue(criteriaType) or issecretvalue(criteriaComplete) or issecretvalue(assetID) or issecretvalue(criteriaID)) then
            if not criteriaComplete then
                if criteriaType == 8 then  -- subcriteria is an achievement
                    local subCriteria = AvailableActivityModule:AchievementCriteriaCheck(assetID, questType, seenQuestIDs, criteriaToQuestMap)

                    for _, data in ipairs(subCriteria) do
                        table.insert(necessaryCriteria, data)
                    end
                elseif criteriaType == 27 then -- this is a quest & we need the quest. verify availability
                    if AvailableActivityModule:IsQuestAvailable(assetID, questType) and not seenQuestIDs[assetID] then
                        seenQuestIDs[assetID] = true
                        table.insert(necessaryCriteria, { questTitle = criteriaTitle, questID = assetID })
                    end
                elseif criteriaType == 158 then -- this is an npc we need to move to a quest
                    local qID = criteriaToQuestMap[criteriaID]
                    local title = AvailableActivityModule:GetQuestTitle(qID)

                    if AvailableActivityModule:IsQuestAvailable(qID, questType) and not seenQuestIDs[qID] then
                        seenQuestIDs[qID] = true
                        table.insert(necessaryCriteria, { questTitle = title, questID = qID })
                elseif criteriaType == 0 then -- this is a "monster" we need to move to a quest
                    local qID = criteriaToQuestMap[criteriaID]
                    local title = AvailableActivityModule:GetQuestTitle(qID)

                    if AvailableActivityModule:IsQuestAvailable(qID, questType) and not seenQuestIDs[qID] then
                        seenQuestIDs[qID] = true
                        table.insert(necessaryCriteria, { questTitle = title, questID = qID })
                    end
                    end
                end
            end
        end
    end

    return necessaryCriteria
end

function AvailableActivityModule:ProcessAchievementEntry(achievementID, achievementData, questType, subcategory, category, criteriaToQuestMap)
    if InCombatLockdown() then
        return
    end

    if AvailableActivityModule:IsAchievementComplete(achievementID) then
        return nil
    end

    local necessaryQuests = AvailableActivityModule:AchievementCriteriaCheck(achievementID, questType, {}, criteriaToQuestMap)
    local petLinks = AvailableActivityModule:GetPetData(achievementData.petReward)
    local achievementList = {}

    for _, questNeeded in ipairs(necessaryQuests) do
        local entry = AvailableActivityModule:BuildActivityEntry(category, questNeeded.questTitle, petLinks, subcategory)

        if entry then
            table.insert(achievementList, entry)
        end
    end

    return achievementList
end

function AvailableActivityModule:BuildDailyQuestAchievementList(dataSource, criteriaToQuestMap)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for achievementID, achievementData in pairs(dataSource) do
        local achievementTitle = select(2, GetAchievementInfo(achievementID))
        local entries = AvailableActivityModule:ProcessAchievementEntry(achievementID, achievementData, "daily", achievementTitle, "Achievements From Daily Quests", criteriaToQuestMap)
        if entries then
            for _, entry in ipairs(entries) do
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:BuildWorldQuestAchievementList(dataSource, criteriaToQuestMap)
    if InCombatLockdown() then
        return
    end

    local results = {}

    for achievementID, achievementData in pairs(dataSource) do
        local achievementTitle = select(2, GetAchievementInfo(achievementID))
        local entries = AvailableActivityModule:ProcessAchievementEntry(achievementID, achievementData, "world", achievementTitle, "Achievements From World Quests", criteriaToQuestMap)
        if entries then
            for _, entry in ipairs(entries) do
                table.insert(results, entry)
            end
        end
    end

    return results
end

function AvailableActivityModule:VerifyDataIsReady()
    if InCombatLockdown() then
        return false
    end

    local achievementVerificationID = 416 -- https://www.wowhead.com/achievement=416/scarab-lord
    local questVerificationID = 12515 -- https://www.wowhead.com/quest=12515/nice-hat

    local achievementVerified = select(2, GetAchievementInfo(achievementVerificationID)) ~= nil
    local questVerified = AvailableActivityModule:GetQuestTitle(questVerificationID) ~= nil

    -- note: we don't check against a curated list of specific calendar event
    -- IDs here, since which events are actually scheduled for "today" varies
    -- day to day (e.g. PvP Brawl rotation) and cannot be relied upon to
    -- always match. Instead we just confirm the Calendar API has returned at
    -- least one fully-populated event for today, which is enough to prove
    -- the data has loaded.
    local calendarVerified = false
    local numEvents = C_Calendar.GetNumDayEvents(0, self.today.monthDay)
    for eventNum = 1, numEvents do
        local event = C_Calendar.GetDayEvent(0, self.today.monthDay, eventNum) or nil
        if not issecretvalue(event) and event and event.eventID and event.title then
            calendarVerified = true
            break
        end
    end

    return achievementVerified and questVerified and calendarVerified
end

function AvailableActivityModule:tableSize(myTable)
    if InCombatLockdown() then
        return 0
    end

    local count = 0
    for _ in pairs(myTable) do count = count + 1 end
    return count
end

function AvailableActivityModule:CreateDataObject()
    if InCombatLockdown() then
        return
    end

    local dataObject = {}
    local activitiesData = DataModule:GetActivitiesData()

    -- protect against data module not loading
    if activitiesData == nil then
        return {}
    end

    if not AvailableActivityModule:VerifyDataIsReady() then
        return {}
    end

    dataObject = {
        bountyPetEvents                = AvailableActivityModule:BuildBountyQuestList(activitiesData.bountyPetData),
        calendarPetEvents              = AvailableActivityModule:BuildCalendarEventList(activitiesData.calendarEventPetData),
        covenantPetEvents              = AvailableActivityModule:BuildCovenantQuestList(activitiesData.covenantPetData),
        dailyQuestPetAchievementEvents = AvailableActivityModule:BuildDailyQuestAchievementList(activitiesData.dailyQuestAchievementPetData, activitiesData.criteriaToQuestMap),
        dailyQuestPetEvents            = AvailableActivityModule:BuildDailyQuestList(activitiesData.dailyQuestPetData),
        islandPetEvents                = AvailableActivityModule:BuildIslandQuestList(activitiesData.islandPetData),
        paragonPetEvents               = AvailableActivityModule:BuildParagonEventActivityList(activitiesData.paragonPetData),
        timedZonePetEvents             = AvailableActivityModule:BuildTimedZoneEventActivityList(activitiesData.TimedZoneActivityPetData),
        worldQuestPetAchievementEvents = AvailableActivityModule:BuildWorldQuestAchievementList(activitiesData.worldQuestAchievementPetData, activitiesData.criteriaToQuestMap),
        worldQuestPetEvents            = AvailableActivityModule:BuildWorldQuestList(activitiesData.worldQuestPetData),
    }

    return dataObject
end

function AvailableActivityModule:DisplayActivityWindow(dataObject)
    if InCombatLockdown() then
        return
    end

    --[[ structure reminder note
    dataObject = {
        bountyPetEvents                = { { category = category, title = title, pets = petLinks } }
        calendarPetEvents              = { { category = category, title = title, pets = petLinks } }
        covenantPetEvents              = { { category = category, title = title, pets = petLinks } }
        dailyQuestPetAchievementEvents = { { category = category, subcategory = subcategory, title = title, pets = petLinks } }
        dailyQuestPetEvents            = { { category = category, title = title, pets = petLinks } }
        islandPetEvents                = { { category = category, title = title, pets = petLinks } }
        paragonPetEvents               = { { category = category, title = title, pets = petLinks } }
        timedZonePetEvents             = { { category = category, title = title, pets = petLinks } }
        worldQuestPetAchievementEvents = { { category = category, subcategory = subcategory, title = title, pets = petLinks } }
        worldQuestPetEvents            = { { category = category, title = title, pets = petLinks } }
    }
    --]]

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(L["Battle Pet Completionist Available Activity Notice"])
    frame:SetLayout("Fill")
    frame:SetWidth(600)
    frame:SetHeight(400)
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)

    local tree = {}
    local categoryNodes = {}
    local subcategoryNodes = {}
    local eventLookup = {}
    local leafCounter = 0

    local function getCategoryNode(category)
        local node = categoryNodes[category]

        if not node then
            node = { value = category, text = category, children = {} }
            categoryNodes[category] = node
            table.insert(tree, node)
        end

        return node
    end

    local function getSubcategoryNode(category, subcategory)
        local key = category .. "|" .. subcategory
        local node = subcategoryNodes[key]

        if not node then
            node = { value = key, text = subcategory, children = {} }
            subcategoryNodes[key] = node
            table.insert(getCategoryNode(category).children, node)
        end

        return node
    end

    local function addEvent(eventData)
        local parentNode = eventData.subcategory
            and getSubcategoryNode(eventData.category, eventData.subcategory)
            or getCategoryNode(eventData.category)

        leafCounter = leafCounter + 1
        local leafValue = "event" .. leafCounter
        eventLookup[leafValue] = eventData
        table.insert(parentNode.children, { value = leafValue, text = eventData.title })
    end

    local function sortTree(nodes)
        table.sort(nodes, function(a, b)
            return a.text:lower() < b.text:lower()
        end)

        for _, node in ipairs(nodes) do
            if node.children and #node.children > 0 then
                sortTree(node.children)
            end
        end
    end

    for _, eventArray in pairs(dataObject) do
        for _, eventData in ipairs(eventArray) do
            addEvent(eventData)
        end
    end

    sortTree(tree)

    -- maintainers: this is the adjustment when no notices are needed
    if #tree == 0 then
        frame:SetLayout("Flow")
        local label = AceGUI:Create("Label")
        label:SetText(L["There are currently no pets to collect from events"])
        label:SetFullWidth(true)
        label:SetFontObject(GameFontHighlightLarge)
        label:SetJustifyH("CENTER")
        frame:AddChild(label)
        self.dataReady.process = false
        return
    end

    frame:SetLayout("Fill")
    frame:SetStatusText(L["Need more information? Try"] .. " WarCraftPets.com")
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetLayout("Fill")
    treeGroup:SetFullWidth(true)
    treeGroup:SetFullHeight(true)

    treeGroup:SetCallback("OnGroupSelected", function(container, event, group)
        -- maintainers: the next line removes a control character and extra data Ace3 adds
        local node = group:match("[^\001]+$")
        local eventData = eventLookup[node]
        if not eventData then
            return
        end

        container:ReleaseChildren()
        local scrollContainer = AceGUI:Create("ScrollFrame")
        scrollContainer:SetLayout("List")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetFullHeight(true)
        container:AddChild(scrollContainer)
        for _, pet in ipairs(eventData.pets) do
            local linkLabel = AceGUI:Create("InteractiveLabel")
            linkLabel:SetText(pet.linkValue)
            linkLabel:SetFullWidth(true)
            linkLabel:SetFontObject(GameFontHighlight)
            linkLabel:SetCallback("OnClick", function()
                local firstValue = pet.linkValue:match("|H([^|]+)|h")
                SetItemRef(firstValue, pet.linkValue, "LeftButton")
            end)
            linkLabel:SetCallback("OnEnter", function(widget)
                GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink(pet.linkValue)
                GameTooltip:Show()
            end)
            linkLabel:SetCallback("OnLeave", function()
                GameTooltip:Hide()
            end)
            scrollContainer:AddChild(linkLabel)
        end
    end)

    treeGroup:SetTree(tree)
    frame:AddChild(treeGroup)

    local path = { tree[1].value }
    local node = tree[1]
    while node.children and node.children[1] do
        node = node.children[1]
        table.insert(path, node.value)
    end

    treeGroup:SelectByPath(unpack(path))

    self.dataReady.process = false
end

function AvailableActivityModule:TryRefresh()
    if InCombatLockdown() then
        return
    end

    if not self.dataReady.calendar then
        return
    end

    if not self.dataReady.covenant then
        return
    end

    if not self.dataReady.pets then
        return
    end

    if self.pendingQuestCount > 0 then
        return
    end

    local displayData = AvailableActivityModule:CreateDataObject()

    if self.pendingQuestCount > 0 then
        return
    end

    if AvailableActivityModule:tableSize(displayData) == 0 then
        return
    end

    AvailableActivityModule:DisplayActivityWindow(displayData)

    self.dataReady.process = false
end

-- Retries for up to one minute in total, using a sliding sleep window that
-- grows between retries (starting at 0.25s, capped at 2s) to avoid hammering
-- the calendar API while it loads.
local CALENDAR_READY_TIMEOUT = 60
local CALENDAR_READY_MIN_INTERVAL = 0.25
local CALENDAR_READY_MAX_INTERVAL = 2
local CALENDAR_READY_BACKOFF_FACTOR = 1.5

function AvailableActivityModule:WaitForCalendarReady(startTime, interval)
    startTime = startTime or GetTime()
    interval = interval or CALENDAR_READY_MIN_INTERVAL

    local function retry()
        if GetTime() - startTime >= CALENDAR_READY_TIMEOUT then
            return
        end

        local nextInterval = math.min(interval * CALENDAR_READY_BACKOFF_FACTOR, CALENDAR_READY_MAX_INTERVAL)

        C_Timer.After(interval, function()
            AvailableActivityModule:WaitForCalendarReady(startTime, nextInterval)
        end)
    end

    local info = C_Calendar.GetMonthInfo(0)

    if not info or info.month ~= self.today.month or info.year ~= self.today.year then
        retry()
        return
    end

    local hasEvents = C_Calendar.GetNumDayEvents(0, self.today.monthDay)
    if hasEvents == 0 then
        retry()
        return
    end

    -- Verify every event has a populated structure.
    for i = 1, hasEvents do
        local event = C_Calendar.GetDayEvent(0, self.today.monthDay, i)
        if not event or not event.eventID then
            retry()
            return
        end
    end

    self.dataReady.calendar = true
    AvailableActivityModule:TryRefresh()
end

function AvailableActivityModule:OnEvent(event, arg1, ...)
    if event == "PLAYER_ENTERING_WORLD" and arg1 then
        -- WOW_PROJECT_MAINLINE only had arguments added in 8.0.1
        -- full details: https://warcraft.wiki.gg/wiki/PLAYER_ENTERING_WORLD
        -- arg1 is logging in from the character select screen
        if DBModule:GetProfile().activitiesEnabled then
            AvailableActivityModule:StartProcess()
        end

    elseif event == "CALENDAR_UPDATE_EVENT_LIST" and self.dataReady.process then
        -- as per https://warcraft.wiki.gg/wiki/API_C_Calendar.OpenCalendar
        -- we need to fire after fully loading. the pop up will cause the
        -- client to be loaded as it is interactive.
        AvailableActivityModule:BeginCalendarWait()

    elseif event == "PET_JOURNAL_LIST_UPDATE" and self.dataReady.process then
        self.dataReady.pets = true
        AvailableActivityModule:TryRefresh()

    elseif event == "COVENANT_CALLINGS_UPDATED" and arg1 and self.dataReady.process then
        self.callingsData = arg1
        self.dataReady.covenant = true
        AvailableActivityModule:TryRefresh()

    elseif event == "QUEST_DATA_LOAD_RESULT" and self.dataReady.process then
        local questID = arg1, ...

        if self.pendingQuestLoads[questID] then
            self.pendingQuestLoads[questID] = nil
            self.pendingQuestCount = self.pendingQuestCount - 1
        end

        if self.pendingQuestCount == 0 then
            AvailableActivityModule:TryRefresh()
        end
    end
end
