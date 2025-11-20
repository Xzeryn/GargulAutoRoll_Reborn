# Testing AtlasLoot Integration

This guide will help you test if GargulAutoRoll is successfully pulling loot data from AtlasLoot Classic.

## Prerequisites

1. ✅ Both addons must be installed:
   - GargulAutoRoll
   - AtlasLootClassic (with AtlasLootClassic_DungeonsAndRaids module)

2. ✅ Both addons must be enabled in the AddOns menu

## Method 1: Enable Debug Mode (Recommended for Testing)

### Step 1: Enable Debug Messages
Edit `GargulAutoRoll.lua` line 2:
```lua
DEBUG = true  -- Enable to see import messages
```

### Step 2: Reload UI
In-game, type: `/reload`

### Step 3: Check Chat for Messages
After reload, you should see in chat:
```
[DEBUG] [Import] AtlasLoot detected
[DEBUG] [ImportItemIds] Importing items from Atlasloot...
[DEBUG] [ImportItemIds] Temple of Ahn'Qiraj
[DEBUG] [ImportItemIds] Ruins of Ahn'Qiraj
[DEBUG] [ImportItemIds] Nightmare Grove
[DEBUG] [ImportItemIds] Blackwing Lair
[DEBUG] [ImportItemIds] Zul'Gurub
[DEBUG] [ImportItemIds] Molten Core
[DEBUG] [ImportItemIds] Onyxia
[DEBUG] [ImportItemIds] World Bosses
```

**If you see these messages:** ✅ AtlasLoot integration is working!

**If you see nothing or "AtlasLoot not detected":** ❌ Integration failed

### Step 4: Disable Debug Mode
After testing, change line 2 back to:
```lua
DEBUG = false  -- Debug mode disabled
```

## Method 2: Add Test Command (Permanent Testing Tool)

I can add a `/gar test` command that will check and report AtlasLoot status without needing debug mode.

Would you like me to add this command?

## Method 3: Manual Verification

### Check if AtlasLoot Data is Available
Type in chat:
```lua
/dump AtlasLoot
```

You should see a table structure. If it says "nil", AtlasLoot isn't loaded properly.

### Check Specific Raid Data
```lua
/dump AtlasLoot.ItemDB.Storage.AtlasLootClassic_DungeonsAndRaids
```

Should show raid data tables.

### Check if GargulAutoRoll Has Items
```lua
/dump GargulAutoRoll.Items.Classic["Blackwing Lair"]
```

Should show a table of bosses and their loot if integration worked.

## Understanding the Integration

### How It Works
1. When GargulAutoRoll loads, it calls `GargulAutoRoll.AtlasLoot.Import()`
2. The Import function checks if AtlasLoot data is ready
3. If ready, it imports items from these raids:
   - Temple of Ahn'Qiraj
   - Ruins of Ahn'Qiraj
   - Nightmare Grove
   - Blackwing Lair
   - Zul'Gurub
   - Molten Core
   - Onyxia
   - World Bosses

4. It specifically imports **Classic version (gameVersionKey == 2)** items
5. Items are merged into existing GargulAutoRoll.Items tables

### What Gets Imported
- Only raids in the `raidNameMappings` table
- Only Classic version items (not TBC/Wrath)
- Excludes blacklisted categories (like "Tier 2 Tokens")

### Important Notes
- ⚠️ **Naxxramas is NOT in the import list** (commented out in line 8 of AtlasLoot.lua)
- The import happens automatically on addon load
- It retries up to 5 times (1 second apart) if AtlasLoot isn't ready yet

## Common Issues

### AtlasLoot Not Detected
**Cause:** AtlasLoot loads after GargulAutoRoll, or DungeonsAndRaids module isn't installed

**Solution:** 
1. Make sure AtlasLootClassic_DungeonsAndRaids is installed
2. Check load order in addon list
3. Try `/reload` after both addons are loaded

### Naxxramas Items Not Importing
**Cause:** Naxxramas is commented out in the import mapping (line 8)

**Solution:** We already fixed the Naxxramas items manually, so this is intentional.

## Verification Checklist

- [ ] Both addons show as loaded in `/reload` output
- [ ] Debug messages appear in chat (if DEBUG = true)
- [ ] `/dump AtlasLoot` returns a table (not nil)
- [ ] Items from AtlasLoot appear in GargulAutoRoll interface
- [ ] Auto-rolling works on raid boss loot

## Need Help?

If integration isn't working, try:
1. Disable all other addons except these two
2. Delete WTF cache folder and reload
3. Verify AtlasLoot Classic is the correct version for Classic Anniversary
4. Check if AtlasLoot works independently (open its interface)

