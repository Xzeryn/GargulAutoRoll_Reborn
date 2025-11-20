GargulAutoRoll.Interface = {}

-- Reference to our Utils (avoid conflicts with other addons)
local Utils = GargulAutoRoll_Utils

local function CleanupFrame(frame)
    if frame then
        frame:Hide() -- Hide the frame
        frame:SetParent(nil) -- Detach it from the UI hierarchy
        frame:ClearAllPoints() -- Clear positioning
        frame:UnregisterAllEvents() -- Unregister events (optional if no events are used)
    end
end

function GargulAutoRoll.Interface:Initialize()
    -- Setup addon frame
    GargulAutoRoll:SetFrameStrata("HIGH")
    GargulAutoRoll:SetSize(GargulAutoRollDB.width, GargulAutoRollDB.height)
    GargulAutoRoll:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    GargulAutoRoll:EnableMouse(true)
    GargulAutoRoll:SetMovable(true)
    GargulAutoRoll:RegisterForDrag("LeftButton")
    GargulAutoRoll:SetScript("OnDragStart", GargulAutoRoll.StartMoving)
    GargulAutoRoll:SetScript("OnDragStop", GargulAutoRoll.StopMovingOrSizing)
    GargulAutoRoll:SetScript("OnShow", function() PlaySound(808) end)
    GargulAutoRoll:SetScript("OnHide", function() PlaySound(808) end)

    -- Make frame closable with ESC
    table.insert(UISpecialFrames, "AutoRollMainFrame")

    GargulAutoRoll.title = GargulAutoRoll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    GargulAutoRoll.title:SetPoint("TOPLEFT", GargulAutoRoll.TitleBg, "TOPLEFT", 5, -3)
    GargulAutoRoll.title:SetText("GargulAutoroll |c00967FD2" .. ADDON_VERSION .. "|r")

    -- Create the Help button
    GargulAutoRoll.helpButton = CreateFrame("Button", nil, GargulAutoRoll, "UIPanelButtonTemplate")
    GargulAutoRoll.helpButton:SetPoint("RIGHT", GargulAutoRoll.TitleBg, "RIGHT", 0, 1)
    GargulAutoRoll.helpButton:SetSize(50, 18)
    GargulAutoRoll.helpButton:SetText("Help")

    GargulAutoRoll.helpButton:SetScript("OnClick", function()
        GargulAutoRoll:PrintHelp()
    end)

    GargulAutoRoll.helpButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()

        -- Header line
        GameTooltip:AddLine("How to add/remove items?")
        GameTooltip:AddLine("Click Help to show in chat more commands", 0.5, 0.5, 0.5)

        GameTooltip:AddLine("\nAdd one item:")
        GameTooltip:AddLine("|cffffffffUse the Search box or shift-click [item-links]|r", 1, 1, 1)
        GameTooltip:AddLine("|cffffffff/gar ms [item-link]|r", 1, 1, 1)
        GameTooltip:AddLine("|cffffffff/gar os [item-link]|r", 1, 1, 1)
        GameTooltip:AddLine("|cffffffff/gar pass [item-link]|r", 1, 1, 1)

        GameTooltip:AddLine("\nRemove one item:")
        GameTooltip:AddLine("|cffffffffClick twice on PASS|r", 1, 1, 1)
        GameTooltip:AddLine("|cffffffff/gar remove [item-link]|r", 1, 1, 1)

        GameTooltip:Show()
    end)

    GargulAutoRoll.helpButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Create the Status button (Enabled/Disabled)
    GargulAutoRoll.statusButton = CreateFrame("Button", nil, GargulAutoRoll, "UIPanelButtonTemplate")
    GargulAutoRoll.statusButton:SetPoint("RIGHT", GargulAutoRoll.helpButton, "LEFT", 0, 0)
    GargulAutoRoll.statusButton:SetSize(80, 18)

    GargulAutoRoll.statusButton:SetScript("OnClick", function()
        if GargulAutoRollDB.enabled then
            GargulAutoRoll:DisableRollListener()
        else
            GargulAutoRoll:EnableRollListener()
        end
    end)

    GargulAutoRoll.statusButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to Enable/Disable rolling for the items automatically")
        GameTooltip:Show()
    end)

    GargulAutoRoll.statusButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    ------------------------------------- 
    -- INPUT BOX
    ------------------------------------- 

    -- Create Input Field for Adding Items
    GargulAutoRoll.inputBox = CreateFrame("EditBox", nil, GargulAutoRoll, "InputBoxTemplate")
    GargulAutoRoll.inputBox:SetSize(290, 20)
    GargulAutoRoll.inputBox:SetPoint("TOPLEFT", GargulAutoRoll, "TOPLEFT", 18, -35)
    GargulAutoRoll.inputBox:SetAutoFocus(false)
    GargulAutoRoll.inputBox:SetTextInsets(14, 5, 1, 0)
    local font, size, flags = GargulAutoRoll.inputBox:GetFont()
    GargulAutoRoll.inputBox:SetFont(font, size - 2, flags)

    -- Create Magnifying Glass Icon (Static, No Functionality)
    GargulAutoRoll.inputBox.magnifyingGlass = CreateFrame("Frame", nil, GargulAutoRoll.inputBox)
    GargulAutoRoll.inputBox.magnifyingGlass:SetSize(14, 14)
    GargulAutoRoll.inputBox.magnifyingGlass:SetPoint("LEFT", GargulAutoRoll.inputBox, "LEFT", 0, -2)
    GargulAutoRoll.inputBox.magnifyingGlass.texture = GargulAutoRoll.inputBox.magnifyingGlass:CreateTexture(nil, "ARTWORK")
    GargulAutoRoll.inputBox.magnifyingGlass.texture:SetAllPoints()
    GargulAutoRoll.inputBox.magnifyingGlass.texture:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    GargulAutoRoll.inputBox.magnifyingGlass.texture:SetVertexColor(0.5, 0.5, 0.5, 1)

    -- Create Placeholder Text
    GargulAutoRoll.inputBox.placeholder = GargulAutoRoll.inputBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    GargulAutoRoll.inputBox.placeholder:SetPoint("LEFT", GargulAutoRoll.inputBox, "LEFT", 15, 0)
    GargulAutoRoll.inputBox.placeholder:SetText("Search here or shift-click an item to add it")
    GargulAutoRoll.inputBox.placeholder:SetTextColor(0.3, 0.3, 0.3, 1)
    local font, size, flags = GargulAutoRoll.inputBox.placeholder:GetFont()
    GargulAutoRoll.inputBox.placeholder:SetFont(font, size - 2, flags)

    -- Create Clear Button (X Icon)
    GargulAutoRoll.inputBox.clearButton = CreateFrame("Button", nil, GargulAutoRoll.inputBox)
    GargulAutoRoll.inputBox.clearButton:SetSize(16, 16)
    GargulAutoRoll.inputBox.clearButton:SetPoint("RIGHT", GargulAutoRoll.inputBox, "RIGHT", -5, 0)
    GargulAutoRoll.inputBox.clearButton.texture = GargulAutoRoll.inputBox.clearButton:CreateTexture(nil, "ARTWORK")
    GargulAutoRoll.inputBox.clearButton.texture:SetAllPoints()
    GargulAutoRoll.inputBox.clearButton.texture:SetTexture("Interface\\Buttons\\UI-StopButton")
    GargulAutoRoll.inputBox.clearButton:Hide()
    GargulAutoRoll.inputBox.clearButton:SetScript("OnEnter", function(self) self.texture:SetVertexColor(1, 0.5, 0.5) end)
    GargulAutoRoll.inputBox.clearButton:SetScript("OnLeave", function(self) self.texture:SetVertexColor(1, 1, 1) end)

    function GargulAutoRoll.inputBox:Clear()
        if DEBUG then print(DEBUG_MSG, "[Clear]") end
        self:SetText("") -- Triggers OnTextChanged
        self:ClearFocus()
        self.placeholder:Show()
        self.clearButton:Hide()
        GargulAutoRoll.addButton:Disable()
        self.magnifyingGlass.texture:SetVertexColor(0.5, 0.5, 0.5, 1)
    end

    function GargulAutoRoll.inputBox:Focus()
        self:SetFocus()
        self.placeholder:Hide()
        self.clearButton:Show()
        self.magnifyingGlass.texture:SetVertexColor(1, 1, 1, 1)
    end

    GargulAutoRoll.inputBox.clearButton:SetScript("OnClick", function()
        if DEBUG then print(DEBUG_MSG, "[OnClick]") end
        GargulAutoRoll.inputBox:Clear()
        GargulAutoRoll.Interface:RefreshEntries()
    end)

    GargulAutoRoll.inputBox:SetScript("OnMouseDown", function(self)
        if DEBUG then print(DEBUG_MSG, "[OnMouseDown]") end
        GargulAutoRoll.inputBox:Focus()
    end)

    GargulAutoRoll.inputBox:SetScript("OnEscapePressed", function(self)
        if DEBUG then print(DEBUG_MSG, "[OnEscapePressed]") end
        GargulAutoRoll.inputBox:Clear()
        GargulAutoRoll.Interface:RefreshEntries()
        self:ClearFocus()
    end)

    GargulAutoRoll.inputBox:SetScript("OnTextChanged", function(self)
        if DEBUG then print(DEBUG_MSG, "[OnTextChanged]") end
        if GargulAutoRoll:IsShown() and GargulAutoRoll.inputBox:HasFocus() then
            GargulAutoRoll:Search()
        end
    end)

    ------------------------------------- 
    -- ADD FEATURE
    ------------------------------------- 
    local function AddItemFromInput()
        if DEBUG then print(DEBUG_MSG, "[AddItemFromInput]") end
        local string = GargulAutoRoll.inputBox:GetText()

        if Utils:IsItemLink(string) then
            GargulAutoRoll:SaveRuleAsync(string, "ms")
        else
            GargulAutoRoll.addButton:Disable()
        end
    end

    GargulAutoRoll.inputBox:SetScript("OnEnterPressed", AddItemFromInput)

    -- Create the "Add" button
    GargulAutoRoll.addButton = CreateFrame("Button", nil, GargulAutoRoll, "UIPanelButtonTemplate")
    GargulAutoRoll.addButton:SetPoint("LEFT", GargulAutoRoll.inputBox, "RIGHT", 5, 0)
    GargulAutoRoll.addButton:SetSize(50, 20)
    GargulAutoRoll.addButton:SetText("Add")
    GargulAutoRoll.addButton:Disable()
    GargulAutoRoll.addButton:SetScript("OnClick", AddItemFromInput)

    ------------------------------------- 
    -- SHIFT-CLICK FEATURE
    ------------------------------------- 
    local OriginalChatEdit_InsertLink = ChatEdit_InsertLink

    function ChatEdit_InsertLink(link)
        if link then
            if DEBUG then print(DEBUG_MSG, "[ChatEdit_InsertLink]") end
            if GargulAutoRoll:IsVisible() and not ChatEdit_GetActiveWindow() then
                GargulAutoRoll.inputBox:SetText(link)
                GargulAutoRoll.inputBox:Focus()
                GargulAutoRoll.addButton:Enable()
                return true
            end
        end
        return OriginalChatEdit_InsertLink(link)
    end

    ------------------------------------- 
    -- SCROLL FEATURE
    ------------------------------------- 

    -- Make Scroll Frame
    GargulAutoRoll.scrollFrame = CreateFrame("ScrollFrame", "AutoRollScrollFrame", GargulAutoRoll, "UIPanelScrollFrameTemplate")
    GargulAutoRoll.scrollFrame:SetPoint("TOPLEFT", GargulAutoRoll, "TOPLEFT", 10, -60)
    GargulAutoRoll.scrollFrame:SetPoint("BOTTOMRIGHT", GargulAutoRoll, "BOTTOMRIGHT", -35, 10)

    -- Content frame inside the scroll frame (this is the frame that will scroll)
    GargulAutoRoll.List = CreateFrame("Frame", "AutoRollcontent", GargulAutoRoll.scrollFrame)
    GargulAutoRoll.List:SetSize(GargulAutoRollDB.width, GargulAutoRollDB.height)
    GargulAutoRoll.scrollFrame:SetScrollChild(GargulAutoRoll.List)

    -- We will store the item results here
    GargulAutoRoll.List.Entries = {}
    -- We will store the raid headers here
    GargulAutoRoll.List.Headers = {}

    -------------------------
    --- RESIZABLE
    -------------------------
    GargulAutoRoll:SetResizable(true)

    -- Enforce horizontal resizing only and constraints
    local minHeight, maxHeight = 390, 625
    local minWidth, maxWidth = 400, 500

    -- Add a resize handle
    local resizeHandle = CreateFrame("Frame", nil, GargulAutoRoll)
    resizeHandle:SetSize(16, 16)
    resizeHandle:SetPoint("BOTTOMRIGHT")
    resizeHandle:EnableMouse(true)

    -- Add a texture to simulate a backdrop
    local texture = resizeHandle:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    texture:SetVertexColor(1, 1, 1, 0.8)

    -- Add a highlight effect on mouseover
    resizeHandle:SetScript("OnEnter", function()
        texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    end)

    resizeHandle:SetScript("OnLeave", function()
        texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    end)

    -- Allow resizing when the handle is dragged
    resizeHandle:SetScript("OnMouseDown", function()
        GargulAutoRoll:StartSizing("BOTTOMRIGHT")
    end)
    resizeHandle:SetScript("OnMouseUp", function()
        GargulAutoRoll:StopMovingOrSizing()
    end)

    GargulAutoRoll:SetScript("OnSizeChanged", function(self, width, height)
        if height < minHeight then
            self:SetHeight(minHeight)
            GargulAutoRollDB.height = height
        elseif height > maxHeight then
            self:SetHeight(maxHeight)
            GargulAutoRollDB.height = height
        end

        if width < minWidth then
            self:SetWidth(minWidth)
            GargulAutoRollDB.width = width
        elseif width > maxWidth then
            self:SetWidth(maxWidth)
            GargulAutoRollDB.width = width
        end
    end)
end

------------------------------------- 
-- ROLL MS
------------------------------------- 

function GargulAutoRoll.Interface:HighlightNeedButton(itemId)
    if not GargulAutoRoll.List.Entries[itemId] then return end
    GargulAutoRoll.List.Entries[itemId].itemFrame.needButton:GetNormalTexture():SetVertexColor(1, 1, 1)
    GargulAutoRoll.List.Entries[itemId].itemFrame.greedButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.passButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
end

function GargulAutoRoll.Interface:HighlightGreedButton(itemId)
    if not GargulAutoRoll.List.Entries[itemId] then return end
    GargulAutoRoll.List.Entries[itemId].itemFrame.needButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.greedButton:GetNormalTexture():SetVertexColor(1, 1, 1)
    GargulAutoRoll.List.Entries[itemId].itemFrame.passButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
end

function GargulAutoRoll.Interface:HighlightPassButton(itemId)
    if not GargulAutoRoll.List.Entries[itemId] then return end
    GargulAutoRoll.List.Entries[itemId].itemFrame.needButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.greedButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.passButton:GetNormalTexture():SetVertexColor(1, 1, 1)
end

function GargulAutoRoll.Interface:HighlightNone(itemId)
    if not GargulAutoRoll.List.Entries[itemId] then return end
    GargulAutoRoll.List.Entries[itemId].itemFrame.needButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.greedButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    GargulAutoRoll.List.Entries[itemId].itemFrame.passButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
end

-------------------------
--- RAID HEADERS
-------------------------
local function CreateHeader(raidHeader, lastWidget)
    local headerFrame = CreateFrame("Frame", nil, GargulAutoRoll.List)
    headerFrame:SetSize(GargulAutoRollDB.width, 24)
    headerFrame.text = headerFrame:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText")
    headerFrame.text:SetText(raidHeader)
    headerFrame.text:SetPoint("LEFT", headerFrame, "LEFT", 10, 0)
    headerFrame.text:SetTextColor(1.0, 0.819, 0.0, 1)

    headerFrame:ClearAllPoints()
    if lastWidget == GargulAutoRoll.List then
        headerFrame:SetPoint("TOPLEFT", GargulAutoRoll.List, "TOPLEFT", 0, -5)
    else
        headerFrame:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -5)
    end

    table.insert(GargulAutoRoll.List.Headers, headerFrame)

    return headerFrame
end

local function ClearAllHeaders()
    for _, header in ipairs(GargulAutoRoll.List.Headers) do
        CleanupFrame(header)
    end

    wipe(GargulAutoRoll.List.Headers) -- `wipe` is a WoW Lua utility to clear tables

    if DEBUG then print(DEBUG_MSG, "[ClearAllHeaders]") end
end

--------------------------------------------------
--- SHOW RESULTS
--------------------------------------------------
local raidPriorityOrder = {
    "Naxxramas",
    "Temple of Ahn'Qiraj",
    "Ruins of Ahn'Qiraj",
    "Ahn'Qiraj Formulas",
    "Nightmare Grove",
    "Blackwing Lair",
    "Zul'Gurub",
    "Molten Core",
    "Onyxia",
    "World Bosses",
    "Unknown"
}

local function GenerateRaidPriorityOrder()
    -- Create a fresh copy of the priority order to avoid modifying the original
    local priorityOrder = {}
    for i, raidName in ipairs(raidPriorityOrder) do
        priorityOrder[i] = raidName
    end
    
    -- Map instance names (from GetInstanceInfo) to raid names (in items database)
    local instanceToRaidMap = {
        ["Onyxia's Lair"] = "Onyxia",
        ["Ahn'Qiraj"] = "Temple of Ahn'Qiraj",
        -- Add other mappings if needed (most raids have matching names)
    }
    
    -- Get the actual raid name to prioritize
    local raidToMove = instanceToRaidMap[GargulAutoRoll.playerInstance] or GargulAutoRoll.playerInstance
    
    -- Find and move the matching raid to the top
    if raidToMove then
        for i = #priorityOrder, 1, -1 do
            if priorityOrder[i] == raidToMove then
                table.remove(priorityOrder, i)
                table.insert(priorityOrder, 1, raidToMove)
                break
            end
        end
    end
    
    GargulAutoRoll.raidPriorityOrder = priorityOrder
    return priorityOrder
end

local function SortRaidsByPriority(entry)
    local raidPriorityOrder = GenerateRaidPriorityOrder()
    local priorityMap = {}

    for index, raidName in ipairs(raidPriorityOrder) do
        priorityMap[raidName] = index
    end

    table.sort(entry.raids, function(a, b)
        local priorityA = priorityMap[a] or math.huge -- Default to low priority if not in the map
        local priorityB = priorityMap[b] or math.huge
        return priorityA < priorityB
    end)
end

local ShortenNames = {
    ["AQ opening"] = "AQ Opening",
    ["Ahn'Qiraj bosses"] = "AQ Bosses",
    ["Ahn'Qiraj enchants"] = "Enchants",
    ["Ahn'Qiraj scarabs"] = "Scarabs",
    ["Class books"] = "Books",
    -- Ruins of Ahn'Qiraj
    ["Kurinnaxx"] = "Kurinnaxx",
    ["General Rajaxx"] = "Rajaxx",
    ["Moam"] = "Moam",
    ["Buru the Gorger"] = "Buru",
    ["Ayamiss the Hunter"] = "Ayamiss",
    ["Ossirian the Unscarred"] = "Ossirian",
    ["Bonus chest"] = "Bonus chest",
    -- Temple of Ahn'Qiraj
    ["Trash"] = "Trash",
    ["Shared Loot"] = "Shared loot",
    ["The Prophet Skeram"] = "Skeram",
    ["Battleguard Sartura"] = "Sartura",
    ["Fankriss the Unyielding"] = "Fankriss",
    ["Viscidus"] = "Viscidus",
    ["Princess Huhuran"] = "Huhuran",
    ["Twin Emperors"] = "Emperors",
    ["Ouro"] = "Ouro",
    ["C'Thun"] = "C'Thun",
    ["Vem Dies Last"] = "Vem Dies Last",
    ["Kri Dies Last"] = "Kri Dies Last",
    ["Yauj Dies Last"] = "Yauj Dies Last",
    ["Bug Trio"] = "Bug Trio",
    -- Blackwing Lair
    ["Razorgore the Untamed"] = "Razorgore",
    ["Vaelastrasz the Corrupt"] = "Vaelastrasz",
    ["Broodlord Lashlayer"] = "Broodlord",
    ["Tier 2 Tokens"] = "Tier 2 Tokens",
    -- Zul'Gurub
    ["High Priest Venoxis"] = "Venoxis",
    ["High Priestess Jeklik"] = "Jeklik",
    ["High Priestess Mar'li"] = "Mar'li",
    ["High Priest Thekal"] = "Thekal",
    ["High Priestess Arlokk"] = "Arlokk",
    ["Hakkar, the Soulflayer"] = "Hakkar",
    ["Bloodlord Mandokir"] = "Mandokir",
    ["Jin'do the Hexxer"] = "Jin'do",
    ["Edge of Madness"] = "Madness",
    ["Gahz'ranka"] = "Gahz'ranka",
    -- Molten Core
    ["Lucifron"] = "Lucifron",
    ["Magmadar"] = "Magmadar",
    ["Gehennas"] = "Gehennas",
    ["Garr"]= "Garr",
    ["Shazzrah"] = "Shazzrah",
    ["Baron Geddon"] = "Baron",
    ["Golemagg the Incinerator"] = "Golemagg",
    ["Sulfuron Harbinger"] = "Sulfuron",
    ["Majordomo Executus"] = "Majordomo",
    ["Ragnaros"] = "Ragnaros",
    ["The Molten Core"] = "The Molten Core",
    ["All bosses"] = "All bosses",
    -- Onyxia
    ["Onyxia"] = "Onyxia",
}

local function ShortenName(name)
    if ShortenNames[name] then
        return ShortenNames[name]
    else
        return name:match("^[^%s]+") or name -- Default to the first word
    end
end

local function ShortenBossNames(entry)
    for i, boss in ipairs(entry.bosses) do
        entry.bosses[i] = ShortenName(boss)
    end
end

local function TruncateString(bossString, maxWidth, font)
    local ellipsis = "..."
    local tempString = bossString

    local tempFontString = UIParent:CreateFontString(nil, "ARTWORK", font)

    while tempFontString do
        tempFontString:SetText(tempString)

        if tempFontString:GetStringWidth() <= maxWidth then
            break
        end

        local lastComma = tempString:match(".*(),")
        if not lastComma then
            tempFontString:Hide()
            return ellipsis
        end

        tempString = tempString:sub(1, lastComma - 1):gsub(",%s*$", "")
    end

    tempFontString:Hide()

    if tempString ~= bossString then
        return tempString .. ellipsis
    end

    return tempString
end

local function GetDungeonPriority(raidHeader, raidPriority)
    local lowestPriority = math.huge -- Initialize with the lowest priority
    local isCombinedHeader = raidHeader:find(",") ~= nil

    -- Split combined headers (e.g., "Blackwing Lair, World Bosses") by comma
    for part in raidHeader:gmatch("[^,]+") do
        part = part:gsub("^%s*(.-)%s*$", "%1")
        for raidName, priority in pairs(raidPriority) do
            if part == raidName then
                lowestPriority = math.min(lowestPriority, priority)
            end
        end
    end

    -- Add a slight offset for combined headers to prioritize singular ones
    if isCombinedHeader then
        lowestPriority = lowestPriority + 0.1
    end

    return lowestPriority
end

local function GroupItemsByRaidHeader(entries)
    local groupedItems = {}
    for itemId, entry in pairs(entries) do
        if entry.itemFrame:IsShown() then
            local raidHeader = entry.raidHeader and entry.raidHeader ~= "" and entry.raidHeader or "Unknown"
            groupedItems[raidHeader] = groupedItems[raidHeader] or {}
            table.insert(groupedItems[raidHeader], {
                itemId = itemId,
                itemFrame = entry.itemFrame,
                itemName = entry.itemName,
                itemRarity = entry.itemRarity,
            })
        end
    end
    return groupedItems
end

local function SortShownResults()
    -- Step 1: Clear existing headers
    ClearAllHeaders()

    -- Step 2: Generate priority order
    local raidPriorityOrder = GenerateRaidPriorityOrder()
    local raidPriority = {}
    for index, raidName in ipairs(raidPriorityOrder) do
        raidPriority[raidName] = index
    end

    -- Step 3: Group items by raidHeader
    local groupedItems = GroupItemsByRaidHeader(GargulAutoRoll.List.Entries)

    -- Step 4: Sort items within each raidHeader group
    for raidHeader, items in pairs(groupedItems) do
        table.sort(items, function(a, b)
            if a.itemRarity ~= b.itemRarity then
                return a.itemRarity > b.itemRarity
            end
            return a.itemName < b.itemName
        end)
    end

    -- Step 5: Sort raidHeaders by priority
    local sortedDungeonHeaders = {}
    for raidHeader in pairs(groupedItems) do
        table.insert(sortedDungeonHeaders, raidHeader)
    end
    table.sort(sortedDungeonHeaders, function(a, b)
        return GetDungeonPriority(a, raidPriority) < GetDungeonPriority(b, raidPriority)
    end)

    -- Step 6: Render items grouped by raidHeader
    local lastWidget = GargulAutoRoll.List
    for _, raidHeader in ipairs(sortedDungeonHeaders) do
        lastWidget = CreateHeader(raidHeader, lastWidget)

        for _, item in ipairs(groupedItems[raidHeader]) do
            local frame = item.itemFrame
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -5)
            lastWidget = frame
        end
    end

    -- Step 7: Reset scroll position
    GargulAutoRoll.scrollFrame:SetVerticalScroll(0)

    if DEBUG then print(DEBUG_MSG, "[SortShownResults] Items sorted and displayed.") end
end


--------------------------------------------------
--- RESET RESULTS
--------------------------------------------------
local function HideAllEntries()
    if DEBUG then print(DEBUG_MSG, "[HideAllEntries]", Utils:CountRules(GargulAutoRoll.List.Entries), "hidden") end
    for _, entry in pairs(GargulAutoRoll.List.Entries) do
        entry.itemFrame:Hide()
    end
    GargulAutoRoll.scrollFrame:SetVerticalScroll(0)
end

local function RemoveEntry(itemId)
    local itemFrame = GargulAutoRoll.List.Entries[itemId].itemFrame
    if itemFrame then
        CleanupFrame(itemFrame)
        GargulAutoRoll.List.Entries[itemId] = nil
    end
    SortShownResults()
end

--------------------------------------------------
--- NEED BUTTON
--------------------------------------------------
local function CreateNeedButton(itemFrame, itemId, itemLink, rule)
    local needButton = CreateFrame("Button", nil, itemFrame)
    needButton:SetSize(20, 20)
    needButton:SetPoint("LEFT", itemFrame, "LEFT", 5, 0)
    needButton:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Dice-Up")
    needButton:SetPushedTexture("Interface/Buttons/UI-GroupLoot-Dice-Down")

    if Utils:getRuleString(rule) ~= "ms" then
        needButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    end

    needButton:SetScript("OnClick", function()
        GargulAutoRoll:SaveRule(itemLink, "ms")
    end)

    needButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to Roll MS for " .. itemLink)
        GameTooltip:Show()
    end)

    needButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return needButton
end

--------------------------------------------------
--- GREED BUTTON
--------------------------------------------------
local function CreateGreedButton(itemFrame, itemId, itemLink, rule)
    local greedButton = CreateFrame("Button", nil, itemFrame)
    greedButton:SetSize(20, 20)
    greedButton:SetPoint("LEFT", itemFrame, "LEFT", 26, 0)
    greedButton:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Coin-Up")
    greedButton:SetPushedTexture("Interface/Buttons/UI-GroupLoot-Coin-Down")

    if Utils:getRuleString(rule) ~= "os" then
        greedButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    end

    greedButton:SetScript("OnClick", function()
        GargulAutoRoll:SaveRule(itemLink, "os")
    end)

    greedButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to Roll OS for " .. itemLink)
        GameTooltip:Show()
    end)

    greedButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return greedButton
end

--------------------------------------------------
--- PASS BUTTON
--------------------------------------------------
local function CreatePassButton(itemFrame, itemId, itemLink, rule)
    local passButton = CreateFrame("Button", nil, itemFrame)
    passButton:SetSize(16, 16)
    passButton:SetPoint("LEFT", itemFrame, "LEFT", 47, 2)
    passButton:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Pass-Up")
    passButton:SetPushedTexture("Interface/Buttons/UI-GroupLoot-Pass-Down")

    if Utils:getRuleString(rule) ~= "pass" then
        passButton:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
    end

    passButton:SetScript("OnClick", function()
        if GargulAutoRollDB.rules[itemId] == Utils.ROLL.PASS then
            GargulAutoRoll:SaveRule(itemLink, nil)
            GargulAutoRoll.inputBox:Clear()
            RemoveEntry(itemId)
        else
            GargulAutoRoll:SaveRule(itemLink, "pass")
        end
    end)

    passButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if rule == "pass" then
            GameTooltip:SetText("Click to remove " .. itemLink)
        else
            GameTooltip:SetText("Click to PASS for " .. itemLink)
        end
        GameTooltip:Show()
    end)

    passButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return passButton
end

--------------------------------------------------
--- ITEM BUTTON
--------------------------------------------------\
local function AddBossHeader(entry, rowItem, rowIcon, rowLink)
    if entry.bossHeader and entry.bossHeader ~= "" then
        rowLink:SetPoint("TOPLEFT", rowIcon, "TOPRIGHT", 5, 0)

        local rowBoss = rowItem:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
        rowBoss:SetJustifyH("LEFT")
        rowBoss:SetPoint("TOPLEFT", rowLink, "BOTTOMLEFT", 0, -1)

        rowBoss:SetText("|cff808080" .. TruncateString(entry.bossHeader, rowLink:GetStringWidth(), "GameFontNormalTiny") .. "|r")

        rowBoss:SetScript("OnEnter", function()
            GameTooltip:SetOwner(rowBoss, "ANCHOR_CURSOR")
            GameTooltip:AddLine(entry.bossHeader:gsub(",%s*", "\n"), 1, 1, 1, true)
            OriginalFonts = Utils:SetTooltipContentFontSize(GameTooltip, 10)
            GameTooltip:Show()
        end)
        rowBoss:SetScript("OnLeave", function()
            Utils:RestoreTooltipFontSize(GameTooltip, OriginalFonts)
            GameTooltip:Hide()
        end)
    end
end

local function CreateItemButton(entry, itemLink, itemIcon)

    local rowItem = CreateFrame("Button", nil, entry.itemFrame)
    rowItem:SetSize(24, 24)
    rowItem:SetPoint("LEFT", entry.itemFrame, "LEFT", 68, 0)

    local rowIcon = rowItem:CreateTexture(nil, "ARTWORK")
    rowIcon:SetSize(24, 24)
    rowIcon:SetTexture(itemIcon)
    rowIcon:SetPoint("LEFT", rowItem, "LEFT", 2, 0)

    local rowLink = rowItem:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowLink:SetJustifyH("LEFT")
    rowLink:SetPoint("LEFT", rowIcon, "RIGHT", 5, 0)
    rowLink:SetText(itemLink)
    rowItem:SetSize(rowLink:GetStringWidth() + 10 + 22, 20)

    AddBossHeader(entry, rowItem, rowIcon, rowLink)

    -- Add Tooltip functionality
    rowItem:SetScript("OnEnter", function()
        GameTooltip:SetOwner(rowItem, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
    rowItem:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Set up click functionality
    rowItem:SetScript("OnMouseUp", function(_, button)
        -- Shift-click to paste item link in chat
        if IsShiftKeyDown() and button == "LeftButton" then
            if not ChatEdit_GetActiveWindow() then
                GargulAutoRoll.inputBox:Focus()
            end
            HandleModifiedItemClick(itemLink)
        -- Ctrl-click to view item in Dressing Room
        elseif IsControlKeyDown() and button == "LeftButton" then
            DressUpItemLink(itemLink)
        -- Alt-click to paste item ID in chat
        elseif DEBUG and IsAltKeyDown() and button == "LeftButton" then
            local itemID = GetItemInfoInstant(itemLink)
            if itemID then
                local chatEditBox = ChatEdit_ChooseBoxForSend()
                if chatEditBox then
                    ChatEdit_ActivateChat(chatEditBox)
                    chatEditBox:Insert(itemID)
                end
            end
        end
    end)

    return rowItem
end

------------------------
--- LOOTED ITEM BUTTON
------------------------
local function CreateLootButton(parent, itemLink, itemIcon, itemCount, itemLocation)
    --if DEBUG then print(DEBUG_MSG, "[CreateLootButton]", itemLink, itemIcon, itemCount, itemLocation) end

    local button = CreateFrame("Button", nil, parent)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -1, -2)
    button.text:SetText(tostring(itemCount))
    button.text:SetTextColor(1, 1, 1)

    button:SetSize(16, 16)
    button:SetPoint("LEFT", parent, "RIGHT", 4 + button.text:GetStringWidth(), 0)
    button:SetNormalTexture(itemIcon)
    button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local itemId = Utils:GetItemIdFromLink(itemLink)

        if itemLocation == "equipped" then
            for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
                if GetInventoryItemID("player", slot) == itemId then
                    GameTooltip:SetInventoryItem("player", slot)
                    GameTooltip:AddLine("\n|c00967FD2Currently Equipped|r", 1, 1, 1, true)
                end
            end
        elseif itemLocation == "bag" then
            for bag = 0, NUM_BAG_SLOTS do
                for slot = 1, C_Container.GetContainerNumSlots(bag) do
                    if C_Container.GetContainerItemID(bag, slot) == itemId then
                        GameTooltip:SetBagItem(bag, slot)
                        GameTooltip:AddLine("\n|c00967FD2Currently in your Bags|r", 1, 1, 1, true)
                    end
                end
            end
        elseif itemLocation == "bank" then
            local isSaved = GargulAutoRollDB.bankItems[itemId] or nil
            if isSaved then
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:AddLine("\n|c00967FD2Currently in your Bank|r", 1, 1, 1, true)
            end
        else
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:AddLine("\n|c00967FD2Currently unknown|r", 1, 1, 1, true)
        end

        OriginalFonts = Utils:SetTooltipContentFontSize(GameTooltip, 10)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        Utils:RestoreTooltipFontSize(GameTooltip, OriginalFonts)
        GameTooltip:Hide()
    end)

    return button
end

------------------------
--- SHOW RESULTS
------------------------
function GargulAutoRoll.Interface:ShowItem(itemId)
    if DEBUG then print(DEBUG_MSG, "[ShowItem]", itemId) end
    for _, entry in pairs(GargulAutoRoll.List.Entries) do
        entry.itemFrame:Hide()
    end
    GargulAutoRoll.List.Entries[itemId].itemFrame:Show()
    SortShownResults()
end

function GargulAutoRoll.Interface:RefreshEntries()
    HideAllEntries()
    if DEBUG then print(DEBUG_MSG, "[RefreshEntries]", Utils:CountRules(GargulAutoRollDB.rules), "refreshed") end
    for itemId, _ in pairs(GargulAutoRollDB.rules) do
        if GargulAutoRoll.List.Entries[itemId] then
            GargulAutoRoll.List.Entries[itemId].itemFrame:Show()
        end
    end
    SortShownResults()
end

function GargulAutoRoll.Interface:ShowResults(searchResults)
    HideAllEntries()
    if DEBUG then print(DEBUG_MSG, "[ShowResults]", Utils:CountRules(searchResults), "showed") end
    for itemId, _ in pairs(searchResults) do
        if GargulAutoRoll.List.Entries[itemId] then
            GargulAutoRoll.List.Entries[itemId].itemFrame:Show()
        end
    end
    SortShownResults()
end

------------------------------------- 
-- REFRESH LIST WITH RESULTS
------------------------------------- 
function GargulAutoRoll.Interface:RefreshWithItems(searchResults)
    if not GargulAutoRoll:IsShown() then return end
    if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] Refreshing started") end
    local requests = 0

    if not searchResults then
        if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] Results empty") end

        searchResults = {}

        -- Defensive check for Utils and CountRules with diagnostics
        if not Utils then
            print(MSG, "Error: Utils table is nil. Please reload the UI (/reload)")
            return
        end
        
        -- Fallback implementation if CountRules is missing
        local function CountRules(rules)
            if not rules then return 0 end
            local count = 0
            for _ in pairs(rules) do
                count = count + 1
            end
            return count
        end
        
        if not Utils.CountRules then
            print(MSG, "Warning: Utils.CountRules is missing, using fallback implementation")
            print(MSG, "Utils table contents:")
            for k, v in pairs(Utils) do
                print("  ", k, type(v))
            end
            -- Use fallback
            Utils.CountRules = CountRules
        end

        local pendingAsync = Utils:CountRules(GargulAutoRollDB.rules)

        if pendingAsync > 0 then
            if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] Processing", pendingAsync, "rules") end
            for itemId, _ in pairs(GargulAutoRollDB.rules) do
                Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
                    requests = requests + 1
                    if DEBUG then REQUESTED = REQUESTED + 1 end
                    if itemLink then
                        searchResults[itemId] = {
                            id = itemId,
                            name = itemName,
                            link = itemLink,
                            rarity = itemRarity,
                            icon = itemIcon,
                            rule = GargulAutoRollDB.rules[itemId] or Utils.ROLL.SEARCH,
                        }
                    else
                        if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] Item not found:", itemId) end
                    end

                    pendingAsync = pendingAsync - 1

                    -- Check if pendingAsync is valid
                    if pendingAsync < 0 then
                        if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] ERROR: pendingAsync is less than zero") end
                    end

                    if pendingAsync == 0 then
                        if DEBUG then REFRESHED = REFRESHED + 1 end
                        if DEBUG then print(DEBUG_MSG, "[RefreshWithItems] Requested", requests, "items") end
                        GargulAutoRoll.Interface:RenderMany(searchResults)
                        GargulAutoRoll.Interface:ShowResults(searchResults)
                        return
                    end
                end)
            end
        end
    else
        if DEBUG then REFRESHED = REFRESHED + 1 end
        GargulAutoRoll.Interface:RenderMany(searchResults)
        GargulAutoRoll.Interface:ShowResults(searchResults)
    end

    GargulAutoRoll.List:SetHeight(Utils:CountRules(searchResults) * 20 + 20)
    GargulAutoRoll.scrollFrame:UpdateScrollChildRect()
end

---------------------------
--- RENDERING
---------------------------
function GargulAutoRoll.Interface:RenderMany(searchResults)
    if DEBUG then print(DEBUG_MSG, "[RenderMany]") end
    local lastWidget = GargulAutoRoll.List

    for _, item in pairs(searchResults) do
        local newWidget = GargulAutoRoll.Interface:RenderItem(item, lastWidget)
        if newWidget then
            lastWidget = newWidget
        end
    end

    if DEBUG then
        print(
            DEBUG_MSG, "[SUMMARY]",
            "[ API", tostring(REQUESTED),
            "][ R", tostring(REFRESHED),
            "][ F", tostring(RENDERED),
            "][ LF", tostring(LOOTED),
            "][ EF", tostring(EXCHANGED) .. " ]"
        )
    end
end

local function RenderEquippedLoot(parent, itemId, itemLink, itemIcon)
    local equippedCount = 0
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if GetInventoryItemID("player", slot) == itemId then
            equippedCount = equippedCount + 1
        end
    end

    if equippedCount > 0 then
        if DEBUG then LOOTED = LOOTED + 1 end
        --if DEBUG then print(DEBUG_MSG, "[RenderEquippedLoot]", itemId, equippedCount) end
        return CreateLootButton(parent, itemLink, itemIcon, equippedCount, "equipped")
    end

    return nil
end

local function RenderBagLoot(parent, itemId, itemLink, itemIcon)
    local bagCount = 0

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.itemID == itemId then
                bagCount = bagCount + itemInfo.stackCount
            end
        end
    end

    if bagCount > 0 then
        if DEBUG then LOOTED = LOOTED + 1 end
        --if DEBUG then print(DEBUG_MSG, "[RenderBagLoot]", itemId, bagCount) end
        return CreateLootButton(parent, itemLink, itemIcon, bagCount, "bag")
    end

    return nil
end

local function RenderBankLoot(parent, itemId, itemLink, itemIcon)
    local bagCount = C_Item.GetItemCount(itemId, false, false)
    local bankCount = C_Item.GetItemCount(itemId, true, false) - bagCount

    if bankCount > 0 then
        if DEBUG then LOOTED = LOOTED + 1 end
        --if DEBUG then print(DEBUG_MSG, "[RenderBankLoot]", itemId, bankCount) end
        return CreateLootButton(parent, itemLink, itemIcon, bankCount, "bank")
    end

    return nil
end

local function RenderTokenLoot(parent, itemId)
    -- If the wanted item is a token, show owned items related to the token
    local tokenRewards = GargulAutoRoll.GetTokenRewards(itemId)
    local previousButton = parent
    local tokensLooted = {}

    for _, rewardId in ipairs(tokenRewards) do
        local rewardCount = C_Item.GetItemCount(rewardId, true, false) -- Checks inventory and bank
        if rewardCount > 0 then
            --if DEBUG then print(DEBUG_MSG, "[RenderTokenLoot] Rendering", itemId) end
            Utils:GetItemInfoAsync(rewardId, function(itemName, itemLink, itemRarity, itemIcon)
                if DEBUG then EXCHANGED = EXCHANGED + 1 end
                if itemLink and itemIcon and Utils:IsItemUsableByClass(rewardId) then
                    --if DEBUG then print(DEBUG_MSG, "[RenderTokenLoot]", itemId, rewardCount) end
                    local itemLocation = select(1, Utils:GetItemLocation(rewardId))
                    previousButton = CreateLootButton(previousButton, itemLink, itemIcon, rewardCount, itemLocation)
                    table.insert(tokensLooted, previousButton)
                end
            end)
        end
    end
    return tokensLooted
end

----------------------
--- RENDER ITEM
----------------------
function GargulAutoRoll.Interface:RenderItem(item, lastWidget)
    if not item.id or not item.link or not item.icon or not item.rule then
        if DEBUG then print(DEBUG_MSG, "[RenderItem] Skipping invalid item:", item.id, item.link, item.icon, item.rule) end
        return nil
    end

    if not GargulAutoRoll.List.Entries[item.id] then
        --if DEBUG then print(DEBUG_MSG, "[RenderItem]", item.id, item.name) end
        if DEBUG then RENDERED = RENDERED + 1 end

        local itemFrame = CreateFrame("Frame", nil, GargulAutoRoll.List)
        itemFrame:SetSize(GargulAutoRollDB.width, 24)
        itemFrame:Hide()

        GargulAutoRoll.List.Entries[item.id] = {}
        local entry = GargulAutoRoll.List.Entries[item.id]
        entry.itemFrame = itemFrame
        entry.itemName = item.name
        entry.itemRarity = item.rarity
        entry.raids = item.raids or {}
        entry.bosses = item.bosses or {}

        -- Helper function to check if a value exists in a table
        local function valueExists(tbl, value)
            for _, v in ipairs(tbl) do
                if v == value then
                    return true
                end
            end
            return false
        end

        if not item.raids or item.bosses then
            for raidName, bosses in pairs(GargulAutoRoll.Items.GetItems()) do
                for bossName, itemIds in pairs(bosses) do
                    for _, itemId in pairs(itemIds) do
                        if itemId == item.id then
                            if not valueExists(entry.raids, raidName) then
                                table.insert(entry.raids, raidName)
                            end
                            if not valueExists(entry.bosses, bossName) then
                                table.insert(entry.bosses, bossName)
                            end
                        end
                    end
                end
            end

            SortRaidsByPriority(entry)
            entry.raidHeader = table.concat(entry.raids, ", ")

            ShortenBossNames(entry)
            entry.bossHeader = table.concat(entry.bosses, ", ")
        end

        if lastWidget == GargulAutoRoll.List then
            itemFrame:SetPoint("TOPLEFT", lastWidget, "TOPLEFT", 0, -5)
        else
            itemFrame:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -5)
        end

        itemFrame.needButton = CreateNeedButton(itemFrame, item.id, item.link, item.rule)
        itemFrame.greedButton = CreateGreedButton(itemFrame, item.id, item.link, item.rule)
        itemFrame.passButton = CreatePassButton(itemFrame, item.id, item.link, item.rule)
        itemFrame.itemButton = CreateItemButton(entry, item.link, item.icon)
    end

    if GargulAutoRoll.List.Entries[item.id] then
        --if DEBUG then print(DEBUG_MSG, "[RenderItemLoot]", item.id, item.name) end

        local itemFrame = GargulAutoRoll.List.Entries[item.id].itemFrame
        local equippedButton = RenderEquippedLoot(itemFrame.itemButton, item.id, item.link, item.icon)
        local bagButton = RenderBagLoot(equippedButton or itemFrame.itemButton, item.id, item.link, item.icon)
        local bankButton = RenderBankLoot(bagButton or equippedButton or itemFrame.itemButton, item.id, item.link, item.icon)
        local tokensLooted = RenderTokenLoot(bankButton or bagButton or equippedButton or itemFrame.itemButton, item.id)
    end

    return GargulAutoRoll.List.Entries[item.id].itemFrame
end

local function ClearItemFrame(itemId)
    local entry = GargulAutoRoll.List.Entries[itemId]
    if entry then
        CleanupFrame(entry.itemFrame)
        GargulAutoRoll.List.Entries[itemId] = nil
        if DEBUG then print(DEBUG_MSG, "[ClearItemFrame]:", itemId) end
    end
end

local function ClearAllItemFrames()
    for _, entry in pairs(GargulAutoRoll.List.Entries) do
        CleanupFrame(entry.itemFrame)
    end

    wipe(GargulAutoRoll.List.Entries)
    if DEBUG then print(DEBUG_MSG, "[ClearAllItemFrames]") end
end

function GargulAutoRoll.Interface:RefreshLootedItems(delay, itemId)
    C_Timer.After(delay or 0, function()
        GargulAutoRoll.inputBox:Clear()

        if itemId then
            ClearItemFrame(itemId)
        else
            ClearAllItemFrames()
        end

        GargulAutoRoll.Interface:RefreshWithItems()
    end)
end