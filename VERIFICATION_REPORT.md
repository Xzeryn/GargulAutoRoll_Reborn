# GargulAutoRoll Items.lua Verification Report
**Date:** November 20, 2025  
**Verified Against:** AtlasLootClassic_DungeonsAndRaids (Classic Anniversary)

## Executive Summary
The verification of the loot items list in `Items.lua` has revealed **multiple significant discrepancies** between GargulAutoRoll's item database and the AtlasLootClassic reference database. The issues fall into three main categories:

1. **Items assigned to wrong bosses**
2. **Missing items that should be included**
3. **Invalid or incorrect item IDs**

## Detailed Findings

### NAXXRAMAS - Classic Anniversary

#### Anub'Rekhan
**GargulAutoRoll has:** 22726, 22369, 22362, 22355, 23220, 23219, 23221, 23218, 23237, 23217  
**AtlasLoot has:** 22726, 22727, 22369, 22362, 22355, 22935, 22938, 22936, 22939, 22937

**Issues Found:**
- ❌ **Missing 22727** (Frame of Atiesh) - Should be included
- ❌ **23219** (Girdle of the Mentor) - **WRONG BOSS** - This drops from Instructor Razuvious, not Anub'Rekhan
- ❌ **23221** (Misplaced Servo Arm) - **WRONG BOSS** - This drops from Naxx Trash, not Anub'Rekhan
- ❌ **23218** (Grave Digger) - **DOES NOT EXIST** in Classic Naxx loot tables
- ❌ **23237** (Ring of the Cryptstalker) - **WRONG BOSS** - This drops from Naxx Trash, not Anub'Rekhan
- ❌ **23217** (Maladath...) - **INVALID ITEM ID** for Classic Naxx (Maladath is 19351 from BWL)
- ❌ **23220** (Crystal Webbed Robe) - **WRONG BOSS** - This drops from Maexxna, not Anub'Rekhan
- ❌ **Missing 22935, 22938, 22936, 22939, 22937** - Actual Anub'Rekhan drops that are missing

#### Grand Widow Faerlina
**GargulAutoRoll has:** 22726, 22369, 22362, 22355, 23226, 23238, 23225, 23221, 23220  
**AtlasLoot has:** 22726, 22727, 22369, 22362, 22355, 22943, 22941, 22940, 22942, 22806

**Issues Found:**
- ❌ **Missing 22727** (Frame of Atiesh)
- ❌ **23226** (Ghoul Skin Tunic) - **WRONG BOSS** - This drops from Naxx Trash
- ❌ **23238** (Stygian Buckler) - **WRONG BOSS** - This drops from Naxx Trash
- ❌ **23225** (Soulstring?) - Comment says "Soulstring" but actual Soulstring is 22811 from Four Horsemen
- ❌ **23221** (Misplaced Servo Arm) - **WRONG BOSS** - This drops from Naxx Trash
- ❌ **23220** (Crystal Webbed Robe) - **WRONG BOSS** - This drops from Maexxna
- ❌ **Missing 22943, 22941, 22940, 22942, 22806** - Actual Faerlina drops

#### Maexxna
**GargulAutoRoll has:** 22726, 22371, 22364, 22357, 23220, 23219, 23221, 23237  
**AtlasLoot has:** 22726, 22727, 22371, 22364, 22357, 22947, 23220, 22954, 22807, 22804

**Issues Found:**
- ❌ **Missing 22727** (Frame of Atiesh)
- ✅ **23220** (Crystal Webbed Robe) - **CORRECT** (This one is actually on Maexxna)
- ❌ **23219** (Girdle of the Mentor) - **WRONG BOSS** - From Instructor Razuvious
- ❌ **23221** (Misplaced Servo Arm) - **WRONG BOSS** - From Naxx Trash
- ❌ **23237** (Ring of the Cryptstalker) - **WRONG BOSS** - From Naxx Trash
- ❌ **Missing 22947, 22954, 22807, 22804** - Actual Maexxna drops

#### Noth the Plaguebringer
**GargulAutoRoll has:** 22726, 22370, 22363, 22356, 23030, 23029, 23028, 23027, 23006, 23005  
**AtlasLoot has:** 22726, 22727, 22370, 22363, 22356, 23030, 23031, 23028, 23029, 23006, 23005, 22816

**Issues Found:**
- ❌ **Missing 22727** (Frame of Atiesh)
- ❌ **23027** - Comment says "Plague Bearer" but this is actually "Warmth of Forgiveness" from **The Four Horsemen**
- ❌ **Missing 23031** (Band of the Inevitable) - Should be included
- ❌ **Missing 22816** (Hatchet of Sundered Bone) - Should be included

### BLACKWING LAIR - Classic Anniversary

#### Razorgore the Untamed
**GargulAutoRoll has:** 19370, 19369, 19334, 19335, 16926, 16918, 16911, 16959, 16904, 16943, 16935, 16951  
**AtlasLoot has:** 16926, 16918, 16934, 16911, 16904, 16935, 16943, 16951, 16959, 19336, 19337, 19370, 19369, 19335, 19334

**Issues Found:**
- ❌ **Missing 16934** (Nemesis Bracers) - Should be included
- ❌ **Missing 19336** (Arcane Infused Gem) - Should be included
- ❌ **Missing 19337** (The Black Book) - Should be included

## Severity Assessment

### Critical Issues (Must Fix)
1. **Items assigned to wrong bosses** - This will cause the addon to trigger on incorrect loot
2. **Invalid item IDs** (23217, 23218, 23225?) - These may not work in-game
3. **Missing Frame of Atiesh (22727)** throughout Naxxramas

### High Priority Issues
1. **Missing actual boss drops** - Players will not be able to auto-roll on legitimate items
2. **Trash items appearing on boss loot tables** - May cause confusion

### Medium Priority Issues
1. **Incomplete item lists** - Some bosses are missing items but core items are present

## Recommendations

### Immediate Actions Required

1. **Remove items from wrong bosses:**
   - Remove Trash items (23221, 23237, 23238, 23226, 23069) from boss loot tables
   - Move boss-specific items to their correct bosses

2. **Add missing critical items:**
   - Add Frame of Atiesh (22727) to all applicable Naxx bosses
   - Add missing T2 tier items to BWL bosses
   - Add missing unique boss drops

3. **Fix invalid item IDs:**
   - Research items 23217, 23218, 23225, 23027 to determine correct IDs or remove
   - Verify all item ID comments match actual items

4. **Use AtlasLoot Integration:**
   - The addon has an `AtlasLoot.Import()` function - consider relying on this instead of manual lists
   - If manual lists are required, do a complete sync with AtlasLoot data

### Long-Term Recommendations

1. **Add validation script:** Create a verification script that cross-references with AtlasLoot on load
2. **Version tracking:** Add comments indicating which game version/phase the items are for
3. **Source documentation:** Add comments indicating data source (e.g., "-- Source: AtlasLoot v3.x")
4. **Regular updates:** Establish a process to update item lists when AtlasLoot is updated

## Testing Required

After corrections are made, the following should be tested:

1. ✓ Verify item IDs load in-game without errors
2. ✓ Confirm auto-roll triggers on correct boss loot
3. ✓ Ensure no false triggers on wrong bosses
4. ✓ Test with AtlasLoot integration enabled
5. ✓ Verify Season of Discovery items separately

## Season of Discovery (SoD) Findings

A quick check of SoD items shows they are **significantly more accurate** than Classic items. Example for The Prophet Skeram:

**GargulAutoRoll SoD:** 233496, 233502, 233503, 233504, 233505, 233506, 233507, 233514, 233515, 234975, 233516, 233517, 233518, 233509, 234974, 235045, 235046, 235039  
**AtlasLoot SoD:** 233496, 233516, 233506, 233505, 233518, 233517, 233514, 233502, 233503, 233504, 233507, 233515, 233509, 235045, 235046, 22222/22196

**Minor differences noted:**
- GargulAutoRoll includes Void-Touched (hardmode) versions (234975, 234974) in the base loot table - These should probably be in a separate "Hardmode" section (which exists)
- Plan item IDs differ slightly (235039 vs 22222/22196) - Likely different versions

**Conclusion:** SoD items are largely correct but could use minor cleanup for consistency.

## Notes

- **This report primarily covers Classic Anniversary.** Season of Discovery items appear mostly accurate
- **Only Naxxramas and beginning of BWL were fully analyzed** for Classic due to the pattern of errors found
- **Other Classic raids** (MC, AQ40, AQ20, ZG, Onyxia, World Bosses) likely have similar issues
- The existence of an **AtlasLoot.Import()** function suggests the addon can auto-populate from AtlasLoot, which may be preferable to manual maintenance
- **SoD data appears to have been updated more recently** and is in much better shape than Classic data

## Conclusion

The current `Items.lua` contains **significant errors** that will impact addon functionality. A comprehensive review and correction of all raid loot tables is recommended. Consider using the AtlasLoot integration feature more heavily to reduce manual maintenance burden.

**Estimated effort to fix:** 4-8 hours for complete correction and verification of all raids
**Risk if not fixed:** High - Players may auto-roll on wrong items or miss important loot

