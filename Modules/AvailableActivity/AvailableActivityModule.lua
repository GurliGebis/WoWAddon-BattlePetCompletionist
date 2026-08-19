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
    self.EventFrame:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        self.EventFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    end
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

function AvailableActivityModule:GetPetData(pets)
    if InCombatLockdown() then
        return
    end

    local results = {}

    -- note: pet data we can get is:
    -- speciesName, speciesIcon, petType, companionID, tooltipSource,
    -- tooltipDescription, isWild, canBattle, isTradeable, isUnique,
    -- obtainable, creatureDisplayID
    pets = pets or {}
    for _,pet in ipairs(pets) do
        if AvailableActivityModule:IsPetSought(pet.petNpcID) then
            local petName, _ = C_PetJournal.GetPetInfoBySpeciesID(pet.petSpeciesID)

            if not issecretvalue(petName) then
                local petLink = "|cff1eff00|Hbattlepet:" .. pet.petSpeciesID .. ":1:3:1:::BattlePet--:|h[" .. petName .. "]|h|r"
                table.insert(results, { petSpeciesID = pet.petSpeciesID, petName = petName, linkValue = petLink, linkType = "battlepet", })
            end
        end
    end

    return results
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
        calendarPetEvents              = AvailableActivityModule:BuildCalendarEventList(activitiesData.calendarEventPetData),
        dailyQuestPetEvents            = AvailableActivityModule:BuildDailyQuestList(activitiesData.dailyQuestPetData),
        worldQuestPetEvents            = AvailableActivityModule:BuildWorldQuestList(activitiesData.worldQuestPetData),
        dailyQuestPetAchievementEvents = AvailableActivityModule:BuildDailyQuestAchievementList(activitiesData.dailyQuestAchievementPetData, activitiesData.criteriaToQuestMap),
        worldQuestPetAchievementEvents = AvailableActivityModule:BuildWorldQuestAchievementList(activitiesData.worldQuestAchievementPetData, activitiesData.criteriaToQuestMap),
    }

    return dataObject
end

function AvailableActivityModule:DisplayActivityWindow(dataObject)
    if InCombatLockdown() then
        return
    end

    --[[ structure reminder note
    dataObject = {
        calendarPetEvents              = { { category = category, title = title, pets = petLinks } }
        dailyQuestPetEvents            = { { category = category, title = title, pets = petLinks } }
        worldQuestPetEvents            = { { category = category, title = title, pets = petLinks } }
        dailyQuestPetAchievementEvents = { { category = category, subcategory = subcategory, title = title, pets = petLinks } }
        worldQuestPetAchievementEvents = { { category = category, subcategory = subcategory, title = title, pets = petLinks } }
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

    for _, eventArray in pairs(dataObject) do
        for _, eventData in ipairs(eventArray) do
            addEvent(eventData)
        end
    end

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
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        return
    end

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
