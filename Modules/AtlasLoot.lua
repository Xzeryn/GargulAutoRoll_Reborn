GargulAutoRoll.AtlasLoot = {}

local function IsAtlasLootDataReady()
    return AtlasLoot and AtlasLoot.ItemDB and AtlasLoot.ItemDB.Storage and AtlasLoot.ItemDB.Storage.AtlasLootClassic_DungeonsAndRaids
end

local raidNameMappings = {
    Naxxramas = "Naxxramas",
    TheTempleofAhnQiraj = "Temple of Ahn'Qiraj",
    TheRuinsofAhnQiraj = "Ruins of Ahn'Qiraj",
    NightmareGrove = "Nightmare Grove",
    BlackwingLair = "Blackwing Lair",
    ["Zul'Gurub"] = "Zul'Gurub",
    MoltenCore = "Molten Core",
    Onyxia = "Onyxia",
    WorldBosses = "World Bosses",
}

local blacklist = {
    ["Tier 2 Tokens"] = "Tier 2 Tokens",
}

local function IsRaid(name)
    return raidNameMappings[name] ~= nil
end

local function IsBlacklisted(name)
    return blacklist[name] ~= nil
end

local function FormatRaidNames(raidName)
    return raidNameMappings[raidName] or raidName
end

local function ImportItemIds()
    print(MSG, "[ImportItemIds] Importing items from Atlasloot...")

    local atlasRaidsTable = AtlasLoot.ItemDB.Storage.AtlasLootClassic_DungeonsAndRaids
    local totalItemsImported = 0
    local totalRaids = 0

    for atlasRaidName, raidData in pairs(atlasRaidsTable) do

        if IsRaid(atlasRaidName) and type(raidData) == "table" and raidData.items then
            local raidName = FormatRaidNames(atlasRaidName)
            local raidItemCount = 0
            local newItemsAdded = 0

            GargulAutoRoll.Items.SoD[raidName] = GargulAutoRoll.Items.SoD[raidName] or {}
            GargulAutoRoll.Items.Classic[raidName] = GargulAutoRoll.Items.Classic[raidName] or {}

            for bossIndex, bossData in pairs(raidData.items) do

                if not IsBlacklisted(bossData.name) then
                    GargulAutoRoll.Items.SoD[raidName][bossData.name] = GargulAutoRoll.Items.SoD[raidName][bossData.name] or {}
                    GargulAutoRoll.Items.Classic[raidName][bossData.name] = GargulAutoRoll.Items.Classic[raidName][bossData.name] or {}

                    -- Iterate through all keys in bossData to find loot tables
                    for difficultyKey, lootTable in pairs(bossData) do
                        -- Loot tables are: numeric keys (difficulty IDs) with table values containing item arrays
                        -- Skip metadata fields (name, npcID, Level, etc.)
                        if type(difficultyKey) == "number" and type(lootTable) == "table" then
                            for _, itemEntry in pairs(lootTable) do
                                -- AtlasLoot item format: {position, itemID, [optional_flags]}
                                if type(itemEntry) == "table" and type(itemEntry[2]) == "number" then
                                    raidItemCount = raidItemCount + 1
                                    if not tContains(GargulAutoRoll.Items.Classic[raidName][bossData.name], itemEntry[2]) then
                                        table.insert(GargulAutoRoll.Items.Classic[raidName][bossData.name], itemEntry[2])
                                        newItemsAdded = newItemsAdded + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            totalRaids = totalRaids + 1
            totalItemsImported = totalItemsImported + raidItemCount
            
            if newItemsAdded > 0 then
                print(MSG, string.format("[ImportItemIds] %s: %d items (%d new, %d existing)", 
                    raidName, raidItemCount, newItemsAdded, raidItemCount - newItemsAdded))
            else
                print(MSG, string.format("[ImportItemIds] %s: %d items (all existing)", 
                    raidName, raidItemCount))
            end
        end
    end
    
    print(MSG, string.format("[ImportItemIds] Complete! %d raids, %d total items", totalRaids, totalItemsImported))
end

local attemptCount = 0

function GargulAutoRoll.AtlasLoot.Import()
    if IsAtlasLootDataReady() then
        print(MSG, "[Import] AtlasLoot detected")
        ImportItemIds()
    else
        attemptCount = attemptCount + 1
        if attemptCount >= 5 then
            print(MSG, "[Import] AtlasLoot not detected")
        else
            C_Timer.After(1, GargulAutoRoll.AtlasLoot.Import)
        end
    end
end