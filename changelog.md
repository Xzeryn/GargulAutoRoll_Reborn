v4.0
- Updated addon interface version to 11508 (WoW Classic 1.15.8 Anniversary)
- Added comprehensive Classic Anniversary item database (Naxxramas, AQ40, AQ20, BWL, ZG, MC, Onyxia, World Bosses)
- Maintained separate SoD item database for Season of Discovery players
- Fixed item search functionality - now shows results for both Classic Anniversary and SoD
- Fixed item sorting by zone/raid with proper grouping
- Automatic version detection (Classic Anniversary vs Season of Discovery)
- **NEW:** Added `/gar test` command to verify AtlasLoot integration in-game
- Fixed AtlasLoot integration to properly detect loot tables using dynamic difficulty constants
- Enhanced AtlasLoot import messages with detailed item counts per raid:
  - Shows total items imported per raid
  - Displays count of new items added vs existing items
  - Provides summary of total raids and items processed
  - Improved import logic to properly merge AtlasLoot data with manual item lists without duplicates
  - **NEW:** Added 1-second delay to automatic rolls for a more natural appearance
  - Fixed raid sorting to include Naxxramas in the priority order
  - Added `/gar testraid` command to simulate being in specific raids for testing sorting

v3.8
- Added more AQ Items to the local database

v3.7
- Added more AQ Items to the local database

v3.6
- Fixed problem calculating the correct version of the game (Classic or SoD)
- Added more Tokens to the local database
- Added more Items to the local database

v3.5
- Limited the AtlasLoot import to only Classic
- Added a local database of items for Season of Discovery
- Fixed bug that was initializing the addon (a second time) after entering an instance

v3.4
- Added grouping items by Raid
- Added grouping priority based on where the player is instanced
- Added resizing to the Interface
- Incremented interface update delay after trading, banking or looting

v3.3
- Fixed refreshing items location after equipping them

v3.2
- Fixed player name recognition when winning a roll
- Fixed refreshing looted items after winning a roll
- Updated the information of the help button

v3.1
- Added information of items that you have already looted.
- Item information will be updated when trading, accessing the bank or equipping items.
- Added search by itemId.
- Added command to pass on items.
- Optimized code to reduce calls to WoW API.

v3.0
- Fixed error while checking if AtlasLoot was present.

v2.9
- Added: The search box now supports items from AtlasLootClassic.
- Removed the Command "/gar clear all rules".
- Changed the Command "/gar clear" to "/gar remove".
- Fixed the Command "/gar rules" will no longer open/close the Interface.
- Changed several Global variables to Local.
- Updated the chat notifications format to be more consistent.

v2.8
- Fixed: A debug message was being output when adding items via link.
- Added: More loot from Phase 6 raids (mounts).

v2.7
- Added: Shift-clicking item links now sends them to the addon search box (if GargulAutoRoll is open and the chat box is closed).
- Added: The search box now supports filtering items in your list.
- Added: The search box includes items from Phase 6 raids in its results.

v2.6
- Removed refreshing list when you loot an item (event fires too much)
- Removed GROUP_ROSTER_UPDATE events as they are no longer needed
- Removed CHAT_MSG_LOOT events as they are no longer needed

v2.5
- Added sorting by quality and alphabetically to /gar rules output
- Added more information and a better style to the Help tooltip
- Added an input to the interface to add items via shift+click
- Fixed bug where items were not fully loaded at boot (solution: async-calls)

v2.4
- Fixed bug where items awarded to the player were not changed to PASS

v2.3
- Fixed TRADE_CLOSED stack overflow
- Fixed Clear All Rules stack overflow

v2.2
- Disabled DEBUG mode (I left it enabled by mistake in 2.1)

v2.1
- Removed listener for event BAG_UPDATE_DELAYED for optimization
- Added the rule PASS to have an item in the list but not roll for it
- Items awarded to the player via Gargul will be changed to PASS rule

v2.0
- Fixed overflow in function Refresh

v1.9
- Fixed a bug where a the item list could load half empty.
- Added a Bank icon (wooden box) to indicate which items are stored in the Bank.
- The Bag and Bank icons are now updated when you loot an item.

v1.8
- Added Help button to explain the basic usage.
- Items will now be sorted by quality, then alphabetically.

v1.7
- Fixed listener for CHAT_MSG_RAID_WARNING not working properly.

v1.6
- Added listening to rolls on items via CHAT_MSG_RAID_WARNING.
- Added icons to indicate if an item is already in your bags or bank.

v1.5
- Added buttons to the Interface to change MS and OS rules from the list. 
- Changed the icon of the button that removes rules from the list.

v1.4
- Added a button to the Interface to enable/disable the auto rolling.
- Added a button to the Interface to remove rules from the list.
- Changed "Roll on" texts for "Roll for".

v1.3
- Fixed bug where the minimap button last position was not saved.

v1.2
- Added Ctrl+click to view the item in the Dressing Room.
- Fixed bug where rules were not fully listed at the first launch.

v1.1
- Added a minimap button.