GargulAutoRoll.AtlasLoot = {}

local function IsAtlasLootDataReady()
    return AtlasLoot and AtlasLoot.ItemDB and AtlasLoot.ItemDB.Storage and AtlasLoot.ItemDB.Storage.AtlasLootClassic_DungeonsAndRaids
end

local raidNameMappings = {
    Naxxramas = "Naxxramas",              -- Now enabled for consistency
    TheTempleofAhnQiraj = "Temple of Ahn'Qiraj",
    TheRuinsofAhnQiraj = "Ruins of Ahn'Qiraj",
    --NightmareGrove = "Nightmare Grove",  -- Doesn't exist in AtlasLoot data structure
    BlackwingLair = "Blackwing Lair",
    ["Zul'Gurub"] = "Zul'Gurub",
    MoltenCore = "Molten Core",           -- Fixed: was "MoltenCore2"
    Onyxia = "Onyxia",                    -- Fixed: was "Onyxia2"
    WorldBosses = "World Bosses",         -- Fixed: was "WorldBosses2"
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

    for atlasRaidName, raidData in pairs(atlasRaidsTable) do

        if IsRaid(atlasRaidName) and type(raidData) == "table" and raidData.items then
            local raidName = FormatRaidNames(atlasRaidName)

            GargulAutoRoll.Items.SoD[raidName] = GargulAutoRoll.Items.SoD[raidName] or {}
            GargulAutoRoll.Items.Classic[raidName] = GargulAutoRoll.Items.Classic[raidName] or {}

            for bossIndex, bossData in pairs(raidData.items) do

                if not IsBlacklisted(bossData.name) then
                    GargulAutoRoll.Items.SoD[raidName][bossData.name] = GargulAutoRoll.Items.SoD[raidName][bossData.name] or {}
                    GargulAutoRoll.Items.Classic[raidName][bossData.name] = GargulAutoRoll.Items.Classic[raidName][bossData.name] or {}

                    for gameVersionKey, lootTable in pairs(bossData) do
                        if gameVersionKey == 2 then -- 2 = Classic
                            for _, itemEntry in pairs(lootTable) do
                                if type(itemEntry[2]) == "number" and not tContains(GargulAutoRoll.Items.Classic[raidName][bossData.name], itemEntry[2]) then
                                    table.insert(GargulAutoRoll.Items.Classic[raidName][bossData.name], itemEntry[2])
                                end
                            end
                        end
                    end
                end
            end
            print(MSG, "[ImportItemIds]", raidName)
        end
    end
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