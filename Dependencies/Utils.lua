-- Use a unique name to avoid conflicts with other addons
GargulAutoRoll_Utils = {
    ROLL = {
        MS = 0,
        OS = 1,
        PASS = 2,
        SEARCH = 3
    }
}

-- Keep backward compatibility reference
local Utils = GargulAutoRoll_Utils

function Utils:IsItemLink(string)
    return string:find("|Hitem:%d+:")
end

function Utils:GetItemIdFromLink(itemLink)
    return tonumber(itemLink.match(itemLink or "", "item:(%d+)")) or tonumber(string.match(itemLink, "(%d+)%D*$"))
end

function Utils:getRuleValue(str)
    if str then
        if str:lower() == "ms" then return Utils.ROLL.MS end
        if str:lower() == "os" then return Utils.ROLL.OS end
        if str:lower() == "pass" then return Utils.ROLL.PASS end
        if str:lower() == "search" then return Utils.ROLL.SEARCH end
    end

    return nil
end

function Utils:getRuleString(num)
    if num == Utils.ROLL.MS then return "ms" end
    if num == Utils.ROLL.OS then return "os" end
    if num == Utils.ROLL.PASS then return "pass" end
    if num == Utils.ROLL.SEARCH then return "search" end

    return nil
end

function Utils:IsChatInputBoxOpen()
    return ChatEdit_GetActiveWindow() ~= nil
end

function Utils:GetItemInfoAsync(itemId, callback)
    if DEBUG then REQUESTED = REQUESTED + 1 end

    if not itemId or itemId == 0 then
        if DEBUG then print(DEBUG_MSG, "[GetItemInfoAsync] Invalid or missing item ID") end
        callback(nil, nil, nil, nil)
        return
    end

    -- Attempt to retrieve item info immediately
    local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)
    if itemLink then
        callback(itemName, itemLink, itemRarity, itemIcon)
        return
    end

    -- Item info not available, set up waiting logic
    local frame = CreateFrame("Frame")
    local timeout = 2 -- Timeout in seconds
    local startTime = GetTime()

    -- Cleanup function
    local function cleanup()
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
    end

    -- Event handler for GET_ITEM_INFO_RECEIVED
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:SetScript("OnEvent", function(_, _, receivedId, success)
        if receivedId == itemId and success then
            itemName, itemLink, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)
            if itemLink then
                callback(itemName, itemLink, itemRarity, itemIcon)
                cleanup()
            end
        end
    end)

    -- Timeout handler
    frame:SetScript("OnUpdate", function()
        if (GetTime() - startTime) > timeout then
            --print(MSG, "The item with ID " .. itemId .. " could not be found.")
            callback(nil, nil, nil, nil)
            cleanup()
        end
    end)
end

function Utils:ProcessItemInfoAsync(itemId, callback)
    Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
        if DEBUG then print(DEBUG_MSG, "[ProcessItemInfoAsync]", itemId) end
        if not itemLink then callback(nil) return end
        callback({
            id = itemId,
            name = itemName,
            link = itemLink,
            rarity = itemRarity,
            icon = itemIcon,
            rule = GargulAutoRollDB.rules[itemId] or Utils.ROLL.SEARCH
        })
    end)
end

function Utils:IsItemUsableByClass(itemId)
    local GameTooltip = CreateFrame("GameTooltip", "ClassCheckTooltip", nil, "GameTooltipTemplate")

    -- Create a hidden tooltip frame for inspection
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:SetItemByID(itemId) -- data is fetched from the local cache

    -- Loop through the tooltip's lines to check for class restrictions
    for i = 1, GameTooltip:NumLines() do
        local text = _G["ClassCheckTooltipTextLeft" .. i]:GetText()
        if text and text:match("Classes:") then
            if text:find(GargulAutoRollDB.playerClass) then
                return true
            else
                return false
            end
        end
    end

    return true
end

function Utils:SetTooltipContentFontSize(tooltip, size)
    -- Save original font sizes for restoration
    local originalFonts = {}

    -- Adjust the title (first line)
    local titleLine = _G[tooltip:GetName() .. "TextLeft1"]
    if titleLine then
        local font, oldSize, flags = titleLine:GetFont()
        originalFonts[1] = {font, oldSize, flags}
        titleLine:SetFont(font, size + 3, flags) -- Title 2 points larger
    end

    -- Adjust content lines (skipping title and last line)
    for i = 2, tooltip:NumLines() - 1 do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        if line then
            local font, oldSize, flags = line:GetFont()
            originalFonts[i] = {font, oldSize, flags}
            line:SetFont(font, size, flags)
        end
        local rightLine = _G[tooltip:GetName() .. "TextRight" .. i]
        if rightLine then
            local font, oldSize, flags = rightLine:GetFont()
            originalFonts["Right" .. i] = {font, oldSize, flags}
            rightLine:SetFont(font, size, flags)
        end
    end

    return originalFonts
end

function Utils:RestoreTooltipFontSize(tooltip, originalFonts)
    for i, fontData in pairs(originalFonts) do
        local line
        if type(i) == "number" then
            line = _G[tooltip:GetName() .. "TextLeft" .. i]
        else
            line = _G[tooltip:GetName() .. "TextRight" .. tonumber(i:match("Right(%d+)"))]
        end
        if line and fontData then
            line:SetFont(unpack(fontData))
        end
    end
end

function Utils:StoreBankItems()
    wipe(GargulAutoRollDB.bankItems)

    -- Check bank bag items
    for bankBagSlot = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bankBagSlot) do
            local itemId = C_Container.GetContainerItemID(bankBagSlot, slot)
            if itemId then
                GargulAutoRollDB.bankItems[itemId] = "bank"
            end
        end
    end

    -- Check generic bank slots
    for bankSlot = 1, NUM_BANKGENERIC_SLOTS do
        local slot = BankButtonIDToInvSlotID(bankSlot)
        local itemId = GetInventoryItemID("player", slot)
        if itemId then
            GargulAutoRollDB.bankItems[itemId] = "bank"
        end
    end
end

function Utils:GetItemLocation(itemId)
    -- Check equipped items
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if GetInventoryItemID("player", slot) == itemId then
            return "equipped", slot
        end
    end

    -- Check bag items
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            if C_Container.GetContainerItemID(bag, slot) == itemId then
                return "bag", bag, slot
            end
        end
    end

    -- Check bank items
    return GargulAutoRollDB.bankItems[itemId] or nil
end

function Utils:CountRules(rules)
    if not rules then return 0 end
    local count = 0
    for _ in pairs(rules) do
        count = count + 1
    end
    return count
end

-- Confirmation that GargulAutoRoll_Utils loaded completely
print("|c00967FD2[GargulAutoRoll]|r Utils module loaded successfully (as GargulAutoRoll_Utils)")