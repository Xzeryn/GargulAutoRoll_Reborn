GargulAutoRoll.Search = {}

-- Reference to our Utils (avoid conflicts with other addons)
local Utils = GargulAutoRoll_Utils

local lastSearchTime = 0
local throttleTimer = nil

local function IsThrottled(lastSearchTime)
    local currentTime = GetTime()
    local remainingTime = 1 - (currentTime - lastSearchTime)
    return remainingTime > 0, remainingTime
end

local function GetValidSearchText()
    return GargulAutoRoll.inputBox:GetText():gsub("%s+$", ""):lower()
end

local function AsyncSearchByItemId(itemId)
    Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
        if DEBUG then print(DEBUG_MSG, "[AsyncSearchByItemId]", itemId) end
        if itemLink then
            local searchResults = {}
            searchResults[itemId] = {
                id = itemId,
                name = itemName,
                link = itemLink,
                rarity = itemRarity,
                icon = itemIcon,
                rule = GargulAutoRollDB.rules[itemId] or Utils.ROLL.SEARCH
            }
            GargulAutoRoll.Interface:RefreshWithItems(searchResults)
            GargulAutoRoll.addButton:Enable()
        else
            if DEBUG then print(DEBUG_MSG, "[AsyncSearchByItemId] NOT FOUND:", itemId) end
        end
    end)
end

local function IsItemAlreadyAdded(itemId)
    return GargulAutoRoll.List.Entries[itemId] ~= nil
end

local function SearchByItemId(itemId)
    if IsItemAlreadyAdded(itemId) then
        GargulAutoRoll.Interface:ShowItem(itemId)
        return
    end

    AsyncSearchByItemId(itemId)
end

local function AsyncSearchByName(searchText, atlasLootItems)
    local searchResults = {}
    local requests = 0
    local notFounds = 0

    if DEBUG then print(DEBUG_MSG, "[AddAtlasLootItems]") end
    for raidName, bosses in pairs(atlasLootItems) do
        for bossName, itemIds in pairs(bosses) do
            for _, itemId in pairs(itemIds) do
                Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
                    requests = requests + 1
                    if DEBUG then REQUESTED = REQUESTED + 1 end
                    if itemName and itemName:lower():find(searchText) then
                        searchResults[itemId] = {
                            id = itemId,
                            name = itemName,
                            link = itemLink,
                            rarity = itemRarity,
                            icon = itemIcon,
                            rule = GargulAutoRollDB.rules[itemId] or Utils.ROLL.SEARCH,
                            raid = raidName,
                            boss = bossName
                        }
                    end
                end)
            end
        end
    end

    if DEBUG then print(DEBUG_MSG, "[AsyncSearchByName] Requested", requests, "items") end
    if DEBUG then print(DEBUG_MSG, "[AsyncSearchByName] Failures", notFounds) end
    if DEBUG then print(DEBUG_MSG, "[AsyncSearchByName] Results", Utils:CountRules(searchResults)) end

    GargulAutoRoll.Interface:RefreshWithItems(searchResults)
end

local function AddTokenRewards(searchText, searchResults)
    -- AddTokenRewards
    if DEBUG then print(DEBUG_MSG, "[AddTokenRewards] Requesting token rewards") end
    for tokenId, rewardIds in pairs(GargulAutoRoll.Tokens) do
        if rewardIds then
            for _, itemId in ipairs(rewardIds) do
                Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
                    if itemName and itemName:lower():find(searchText) then
                        if Utils:IsItemUsableByClass(itemId) then
                            searchResults[itemId] = {
                                id = itemId,
                                name = itemName,
                                link = itemLink,
                                rarity = itemRarity,
                                icon = itemIcon,
                                rule = GargulAutoRollDB.rules[itemId] or Utils.ROLL.SEARCH
                            }
                        end
                    end
                end)
            end
        end
    end
end

local function PerformSearch(searchText)
    if DEBUG then print(DEBUG_MSG, "[PerformSearch] " .. "'" .. searchText .. "'") end
    local atlasLootItems = GargulAutoRoll.Items.GetItems()
    local itemId = Utils:GetItemIdFromLink(searchText)

    if itemId then
        SearchByItemId(itemId)
    elseif atlasLootItems then
        AsyncSearchByName(searchText, atlasLootItems)
    end

    if DEBUG then print(DEBUG_MSG, "[PerformSearch] Finished") end
end

function GargulAutoRoll:Search()
    local isThrottled, delay = IsThrottled(lastSearchTime)
    local searchText = GetValidSearchText()

    if #searchText == 0 then
        if DEBUG then print(DEBUG_MSG, "[Search] Empty") end
        GargulAutoRoll.Interface:RefreshEntries()
        return
    elseif #searchText < 3 then -- Cancel any scheduled throttled search if input is too short
        if throttleTimer then
            throttleTimer:Cancel()
            throttleTimer = nil
        end
        return
    end

    if isThrottled then
        -- Schedule the search to execute after the throttling period expires
        if not throttleTimer then
            throttleTimer = C_Timer.NewTimer(delay, function()
                PerformSearch(searchText)
                 -- Clear the timer reference after execution
                throttleTimer = nil
            end)
        end
    else
        -- Execute the search immediately if not throttled
        lastSearchTime = GetTime()
        PerformSearch(searchText)
    end
end