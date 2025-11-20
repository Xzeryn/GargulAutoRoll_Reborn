# AtlasLoot Raid Name Mapping Issues

## Problem Found

The `raidNameMappings` in `Modules\AtlasLoot.lua` has **incorrect key names** that don't match the actual AtlasLoot data structure.

## Current (WRONG) Mappings

```lua
local raidNameMappings = {
    --Naxxramas = "Naxxramas"
    TheTempleofAhnQiraj = "Temple of Ahn'Qiraj",      -- ✓ CORRECT
    TheRuinsofAhnQiraj = "Ruins of Ahn'Qiraj",        -- ✓ CORRECT
    NightmareGrove = "Nightmare Grove",               -- ❌ DOESN'T EXIST in AtlasLoot
    BlackwingLair = "Blackwing Lair",                 -- ✓ CORRECT
    ["Zul'Gurub"] = "Zul'Gurub",                      -- ✓ CORRECT
    MoltenCore2 = "Molten Core",                      -- ❌ WRONG - Should be "MoltenCore"
    Onyxia2 = "Onyxia",                               -- ❌ WRONG - Should be "Onyxia"
    WorldBosses2 = "World Bosses",                    -- ❌ WRONG - Should be "WorldBosses"
}
```

## Actual AtlasLoot Data Keys

From `AtlasLootClassic_DungeonsAndRaids\data.lua`:
```lua
data["WorldBosses"] = {      -- NOT "WorldBosses2"
data["MoltenCore"] = {       -- NOT "MoltenCore2"
data["Onyxia"] = {           -- NOT "Onyxia2"
data["Zul'Gurub"] = {        -- Correct
data["BlackwingLair"] = {    -- Correct
data["TheRuinsofAhnQiraj"] = {    -- Correct
data["TheTempleofAhnQiraj"] = {   -- Correct
data["Naxxramas"] = {        -- Exists but commented out in mappings
```

**Note:** There is NO `NightmareGrove` in Classic data.lua - this appears to be Season of Discovery content only.

## Impact

These incorrect mappings mean:
- ❌ **Molten Core items are NOT being imported** from AtlasLoot
- ❌ **Onyxia items are NOT being imported** from AtlasLoot  
- ❌ **World Bosses items are NOT being imported** from AtlasLoot
- ❌ **Nightmare Grove mapping fails** (but may work in SoD)

This is why we had to manually fix all the items - the import wasn't working for these raids!

## Solution Applied ✅

Updated the mappings to use the correct AtlasLoot keys:

```lua
local raidNameMappings = {
    Naxxramas = "Naxxramas",              -- ✅ NOW ENABLED (was commented out)
    TheTempleofAhnQiraj = "Temple of Ahn'Qiraj",
    TheRuinsofAhnQiraj = "Ruins of Ahn'Qiraj",
    BlackwingLair = "Blackwing Lair",
    ["Zul'Gurub"] = "Zul'Gurub",
    MoltenCore = "Molten Core",           -- ✅ FIXED (was MoltenCore2)
    Onyxia = "Onyxia",                    -- ✅ FIXED (was Onyxia2)
    WorldBosses = "World Bosses",         -- ✅ FIXED (was WorldBosses2)
}
```

### Why Naxxramas Was Enabled

The import logic uses `tContains()` to check if items already exist before adding them. This means:
- **Merges** new items with existing ones
- **Doesn't replace** manually verified items
- **Safe** to enable for all raids including Naxxramas
- Provides automatic updates if AtlasLoot data changes

Now ALL Classic raids will import correctly from AtlasLoot!

