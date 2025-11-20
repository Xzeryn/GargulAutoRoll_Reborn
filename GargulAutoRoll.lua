ADDON_VERSION = "v4.0"
DEBUG = false  -- Debug mode disabled
DEBUG_MSG = "|c00967FD2[DEBUG]|r"
MSG = "|c00967FD2[GargulAutoRoll]|r"

if DEBUG then
    REQUESTED = 0
    REFRESHED = 0
    RENDERED = 0
    LOOTED = 0
    EXCHANGED = 0
end

GargulAutoRoll = CreateFrame("Frame", "AutoRollMainFrame", UIParent, "BasicFrameTemplateWithInset")
GargulAutoRoll:Hide()
GargulAutoRoll:RegisterEvent("ADDON_LOADED")
GargulAutoRoll:RegisterEvent("PLAYER_ENTERING_WORLD")
GargulAutoRoll:RegisterEvent("BANKFRAME_OPENED")
GargulAutoRoll:RegisterEvent("BANKFRAME_CLOSED")
GargulAutoRoll:RegisterEvent("TRADE_CLOSED")
GargulAutoRoll:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
if DEBUG then GargulAutoRoll:RegisterEvent("CHAT_MSG_SAY") end

do
    local defaults = {
        rules = {},
        playerClass = UnitClass("player"),
        bankItems = {},
        enabled = true,      -- RollListener
        ["hide"] = false,    -- MinimapButton visibility
        ["minimapPos"] = 110, -- MinimapButton position
        height = 390,
        width = 400
    }

    local function SetGameVersion()
        GargulAutoRoll.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

        GargulAutoRoll.IsSoD = GargulAutoRoll.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfDiscovery)
    end

    local function LoadSavedSettings()
        GargulAutoRollDB = GargulAutoRollDB or {}

        for key,value in pairs(defaults) do
            if (GargulAutoRollDB[key] == nil) then
                GargulAutoRollDB[key] = value
            end
        end
    end

    -- Function to register events if the addon is enabled
    local function RegisterRaidEvents()
        GargulAutoRoll:RegisterEvent("CHAT_MSG_RAID")
        GargulAutoRoll:RegisterEvent("CHAT_MSG_RAID_LEADER")
        GargulAutoRoll:RegisterEvent("CHAT_MSG_RAID_WARNING")
    end

    -- Function to unregister events if the addon is disabled
    local function UnregisterRaidEvents()
        GargulAutoRoll:UnregisterEvent("CHAT_MSG_RAID")
        GargulAutoRoll:UnregisterEvent("CHAT_MSG_RAID_LEADER")
        GargulAutoRoll:UnregisterEvent("CHAT_MSG_RAID_WARNING")
    end

    -- Enable auto rolling
    function GargulAutoRoll:EnableRollListener()
        GargulAutoRollDB.enabled = true
        RegisterRaidEvents()
        print(MSG, "Auto rolling Enabled")
        GargulAutoRoll.statusButton:SetText("|cff00ff00Enabled|r")
    end

    -- Disable auto rolling
    function GargulAutoRoll:DisableRollListener()
        GargulAutoRollDB.enabled = false
        UnregisterRaidEvents()
        print(MSG, "Auto rolling Disabled")
        GargulAutoRoll.statusButton:SetText("|cffA9A9A9Disabled|r")
    end

    local function InitializeRollListener()
        if GargulAutoRollDB.enabled == true then
            GargulAutoRoll:EnableRollListener()
        else
            GargulAutoRoll:DisableRollListener()
        end
    end

    local function PrintWelcomeMessage()
        print("|c00967FD2GargulAutoRoll " .. ADDON_VERSION .. " by Daga_WildGrowth.|r Type |cff00ff00/gar|r to get started!")
    end

    local function HandleAutoroll(message, sender)
        if GargulAutoRollDB.enabled == true then
            local itemLink, itemId = message:match("roll on (|c.-|Hitem:(%d+).-|h|r)")

            if itemId then
                itemId = tonumber(itemId)
                if GargulAutoRollDB.rules and GargulAutoRollDB.rules[itemId] == Utils.ROLL.MS then
                    print(MSG, "Rolling MS for " .. itemLink)
                    -- Delay the roll by 1 second to appear more natural
                    C_Timer.After(1, function()
                        RandomRoll(1, 100)
                    end)
                elseif GargulAutoRollDB.rules and GargulAutoRollDB.rules[itemId] == Utils.ROLL.OS then
                    print(MSG, "Rolling OS for " .. itemLink)
                    -- Delay the roll by 1 second to appear more natural
                    C_Timer.After(1, function()
                        RandomRoll(1, 99)
                    end)
                end
            end
        end
    end

    local function HandleItemAwarded(message)
        local itemLink, awardedPlayer = message:match("(|c.-|Hitem:%d+.-|h|r) was awarded to ([^%.%s]+%-?[^%.%s]*)%.?")

        if itemLink and awardedPlayer then
            if DEBUG then print(DEBUG_MSG, "[ItemAwarded]", itemLink, awardedPlayer) end

            local itemId = tonumber(itemLink:match("Hitem:(%d+)"))
            local strippedPlayerName = awardedPlayer:match("([^%-%.]+)")
            if DEBUG then print(DEBUG_MSG, "[ItemAwarded]", itemId, strippedPlayerName) end

            if strippedPlayerName == UnitName("player") then
                if GargulAutoRollDB.rules[itemId] then
                    GargulAutoRoll:SaveRuleAsync(itemLink, "pass")
                    GargulAutoRoll.Interface:RefreshLootedItems(2, itemId)
                end
            end
        end
    end

    local function HandleItemGiven(message)
        local itemLink, givenPlayer = message:match("gave (|c.-|Hitem:%d+.-|h|r) to ([^%.%s]+%-?[^%.%s]*)%.?")

        if itemLink and givenPlayer then
            if DEBUG then print(DEBUG_MSG, "[ItemGiven]", itemLink, givenPlayer) end

            local itemId = tonumber(itemLink:match("Hitem:(%d+)"))
            local strippedPlayerName = givenPlayer:match("([^%-]+)%-?.*")
            if DEBUG then print(DEBUG_MSG, "[ItemGiven]", itemId, strippedPlayerName) end

            if strippedPlayerName == UnitName("player") then
                if GargulAutoRollDB.rules[itemId] then
                    GargulAutoRoll:SaveRuleAsync(itemLink, "pass")
                    GargulAutoRoll.Interface:RefreshLootedItems(2, itemId)
                end
            end
        end
    end

    local function OnRaidMessage(self, event, message, sender, ...)
        HandleAutoroll(message, sender)
        HandleItemAwarded(message)
        HandleItemGiven(message)
    end

    GargulAutoRoll:SetScript("OnEvent", function(self, event, addon, ...)
        GargulAutoRoll.isInitialized = false
        --if DEBUG then print(DEBUG_MSG, event, addon or "") end

        if event == "ADDON_LOADED" then
            if addon == "GargulAutoRoll" then
                PrintWelcomeMessage()
                GargulAutoRoll:UnregisterEvent("ADDON_LOADED")
            end
            return
        elseif event == "PLAYER_ENTERING_WORLD" then
            if not GargulAutoRoll.IsInitialized then
                SetGameVersion()
                LoadSavedSettings()
                GargulAutoRoll.Interface:Initialize()
                GargulAutoRoll.Minimap:Initialize()
                InitializeRollListener()
                if not GargulAutoRoll.IsSoD then GargulAutoRoll.AtlasLoot.Import() end
                GargulAutoRoll.IsInitialized = true
            end
            local instanceName = GetInstanceInfo()
            GargulAutoRoll.playerInstance = instanceName
            if DEBUG then print(DEBUG_MSG, "[GetPlayerInstance]", GargulAutoRoll.playerInstance) end
            -- Refresh the UI to reorder items if the addon window is open
            if GargulAutoRoll:IsShown() then
                GargulAutoRoll.Interface:RefreshEntries()
            end
            return
        elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_RAID_WARNING" or (DEBUG and event == "CHAT_MSG_SAY") then
            OnRaidMessage(self, event, addon, ...)
            return
        elseif event == "BANKFRAME_OPENED" then
            Utils:StoreBankItems()
            GargulAutoRoll:RegisterEvent("BAG_UPDATE_DELAYED")
            return
        elseif event == "BANKFRAME_CLOSED" then
            GargulAutoRoll:UnregisterEvent("BAG_UPDATE_DELAYED")
            return
        elseif event == "BAG_UPDATE_DELAYED" then
            GargulAutoRoll.Interface:RefreshLootedItems(2)
            return
        elseif event == "TRADE_CLOSED" then
            GargulAutoRoll.Interface:RefreshLootedItems(2)
            return
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            GargulAutoRoll.Interface:RefreshLootedItems(2)
            return
        end
    end)

    function GargulAutoRoll:SaveRule(itemLink, rule)
        local itemId = Utils:GetItemIdFromLink(itemLink)

        if itemId then
            if rule == nil or rule == "search" then
                if GargulAutoRollDB.rules[itemId] then
                    GargulAutoRoll.Interface:HighlightNone(itemId)
                    GargulAutoRollDB.rules[itemId] = nil
                    print(MSG, "Removed", itemLink)
                else
                    print(MSG, itemLink, "is not in the list")
                end
            elseif rule == "ms" then
                GargulAutoRoll.Interface:HighlightNeedButton(itemId)
                GargulAutoRollDB.rules[itemId] = Utils:getRuleValue(rule)
                print(MSG, "Rolling", rule:upper(), "for", itemLink)
            elseif rule == "os" then
                GargulAutoRoll.Interface:HighlightGreedButton(itemId)
                GargulAutoRollDB.rules[itemId] = Utils:getRuleValue(rule)
                print(MSG, "Rolling", rule:upper(), "for", itemLink)
            elseif rule == "pass" then
                GargulAutoRoll.Interface:HighlightPassButton(itemId)
                GargulAutoRollDB.rules[itemId] = Utils:getRuleValue(rule)
                print(MSG, "Rolling", rule:upper(), "for", itemLink)
            end
        end
    end

    function GargulAutoRoll:SaveRuleAsync(itemLink, rule)
        local itemId = Utils:GetItemIdFromLink(itemLink)

        Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
            if DEBUG then print(DEBUG_MSG, "[SaveRuleAsync] Requested item", itemId) end
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
                GargulAutoRoll:SaveRule(itemLink, rule)
                GargulAutoRoll.Interface:RefreshWithItems(searchResults)
            else
                if DEBUG then print(DEBUG_MSG, "[SaveRuleAsync] Item not found:", itemId) end
            end
        end)
    end

    function GargulAutoRoll:ToggleShow()
        if GargulAutoRoll:IsShown() then
            GargulAutoRoll:Hide()
        else
            GargulAutoRoll:Show()
            GargulAutoRoll.inputBox:Clear()
            GargulAutoRoll.Interface:RefreshWithItems()
        end
    end

    function GargulAutoRoll:PrintHelp()
        print(MSG, "Help")
        print("  Show/Hide addon interface:")
        print("       /gar")
        print("  Add item rules:")
        print("       /gar ms [item-link]")
        print("       /gar os [item-link]")
        print("       /gar pass [item-link]")
        print("  Remove item rules:")
        print("       /gar remove [item-link]")
        print("  List item rules:")
        print("       /gar rules")
        print("  Show/Hide minimap button:")
        print("       /gar minimap")
        print("  Test AtlasLoot integration:")
        print("       /gar test")
        print("  Test raid sorting (simulate being in a raid):")
        print("       /gar testraid [raid name]")
        print("       /gar testraid reset")
    end
end

return GargulAutoRoll
