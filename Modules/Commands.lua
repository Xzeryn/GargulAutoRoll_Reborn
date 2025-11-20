SLASH_AR1 = '/gar';
SLASH_AR2 = '/gargulautoroll';

SlashCmdList["AR"] = function(msg)
    local cmd = msg:lower()

    local rule = string.match(cmd, "^(%S*)")

    if (rule == "enable") then
        GargulAutoRoll:EnableRollListener()
        return
    end

    if (rule == "disable") then
        GargulAutoRoll:DisableRollListener()
        return
    end

    if (rule == "ms") or (rule == "os") or (rule == "pass") then
        GargulAutoRoll:SaveRuleAsync(cmd, rule)
        return
    end

    if (rule == "remove") then
        GargulAutoRoll:SaveRuleAsync(cmd, nil)
        return
    end

    if cmd == "rules" then
        print(MSG, "Listing rules...")

        local rulesToSort = {}
        local remainingItems = 0

        -- Callback to finalize and print sorted results
        local function finalizeAndPrint()
            -- Sort rules by rarity (descending) and then alphabetically by name
            table.sort(rulesToSort, function(a, b)
                if a.itemRarity ~= b.itemRarity then
                    return a.itemRarity > b.itemRarity -- Higher rarity first
                end
                return a.itemName < b.itemName -- Alphabetical order
            end)

            -- Print sorted results
            for _, ruleInfo in ipairs(rulesToSort) do
                local ruleText = string.upper(Utils:getRuleString(ruleInfo.rule) or "UNKNOWN")
                if ruleInfo.itemLink then
                    print("Rolling " .. ruleText .. " for " .. ruleInfo.itemLink)
                else
                    print("Rolling " .. ruleText .. " for " .. ruleInfo.itemName)
                end
            end
        end

        -- Process rules asynchronously
        for itemId, ruleData in pairs(GargulAutoRollDB.rules) do
            remainingItems = remainingItems + 1

            -- Use the existing GetItemInfoAsync to fetch item info
            Utils:GetItemInfoAsync(itemId, function(itemName, itemLink, itemRarity, itemIcon)
                if itemLink then
                    table.insert(rulesToSort, {
                        itemId = itemId,
                        itemLink = itemLink,
                        itemName = itemName or tostring(itemId),
                        itemRarity = itemRarity or 0,
                        rule = ruleData
                    })
                else
                    --print(MSG, "Item info not available for ID:", itemId)
                end

                remainingItems = remainingItems - 1
                if remainingItems == 0 then
                    finalizeAndPrint()
                end
            end)
        end

        return
    end

    if cmd == "minimap" then
        GargulAutoRoll.Minimap:Toggle()
        return
    end

    if cmd == "test" then
        -- Test AtlasLoot integration
        print(MSG, "=== AtlasLoot Integration Test ===")
        
        -- Check if AtlasLoot is loaded
        if AtlasLoot then
            print(MSG, "✓ AtlasLoot addon is loaded")
        else
            print(MSG, "✗ AtlasLoot addon NOT found")
            return
        end
        
        -- Check if data storage exists
        if AtlasLoot.ItemDB and AtlasLoot.ItemDB.Storage and AtlasLoot.ItemDB.Storage.AtlasLootClassic_DungeonsAndRaids then
            print(MSG, "✓ AtlasLoot data storage is ready")
        else
            print(MSG, "✗ AtlasLoot data storage NOT ready")
            return
        end
        
        -- Check if GargulAutoRoll has imported items
        local hasItems = false
        local raidCount = 0
        local bossCount = 0
        local itemCount = 0
        
        for raidName, raidData in pairs(GargulAutoRoll.Items.Classic) do
            raidCount = raidCount + 1
            for bossName, items in pairs(raidData) do
                bossCount = bossCount + 1
                for _, itemId in pairs(items) do
                    itemCount = itemCount + 1
                    hasItems = true
                end
            end
        end
        
        if hasItems then
            print(MSG, "✓ Items imported successfully")
            print(MSG, "  Raids: " .. raidCount)
            print(MSG, "  Bosses: " .. bossCount)
            print(MSG, "  Items: " .. itemCount)
        else
            print(MSG, "✗ No items found in GargulAutoRoll.Items.Classic")
        end
        
        -- Sample a specific raid
        if GargulAutoRoll.Items.Classic["Blackwing Lair"] then
            local bwlBosses = 0
            for _ in pairs(GargulAutoRoll.Items.Classic["Blackwing Lair"]) do
                bwlBosses = bwlBosses + 1
            end
            print(MSG, "  Example: Blackwing Lair has " .. bwlBosses .. " bosses")
        end
        
        print(MSG, "=== Test Complete ===")
        return
    end

    -- Test raid sorting by simulating being in a specific raid
    if string.match(cmd, "^testraid") then
        local raidName = string.match(msg, "^testraid%s+(.+)")
        
        if not raidName then
            print(MSG, "Usage: /gar testraid <raid name>")
            print(MSG, "Available raids:")
            print(MSG, "  - Naxxramas")
            print(MSG, "  - Temple of Ahn'Qiraj")
            print(MSG, "  - Ruins of Ahn'Qiraj")
            print(MSG, "  - Blackwing Lair")
            print(MSG, "  - Zul'Gurub")
            print(MSG, "  - Molten Core")
            print(MSG, "  - Onyxia's Lair")
            print(MSG, "")
            print(MSG, "To reset: /gar testraid reset")
            return
        end
        
        if raidName:lower() == "reset" then
            GargulAutoRoll.playerInstance = nil
            print(MSG, "Raid instance reset to normal (not in any raid)")
        else
            GargulAutoRoll.playerInstance = raidName
            print(MSG, "Simulating being in: " .. raidName)
        end
        
        -- Refresh the UI if it's open
        if GargulAutoRoll:IsShown() then
            GargulAutoRoll.Interface:RefreshEntries()
            print(MSG, "Interface refreshed - items should now be sorted with " .. (raidName:lower() == "reset" and "normal priority" or raidName .. " at the top"))
        else
            print(MSG, "Open the addon window (/gar) to see the sorting effect")
        end
        
        return
    end

    if cmd == "help" then
        GargulAutoRoll:PrintHelp()
        return
    end

    GargulAutoRoll:ToggleShow()

end

