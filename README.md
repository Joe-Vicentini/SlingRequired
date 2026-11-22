# Sling Required

A Project Zomboid **Build 42** mod requiring a worn sling (or suitable back-worn equipment) before the **Back** weapon hotbar slot can be used.

## Behavior

- Without qualifying equipment, the Back hotbar slot is removed and an attached item is detached to inventory.
- A worn **Makeshift Sling** enables the Back slot.
- **Any worn item explicitly declaring `AttachmentsProvided = Back` qualifies automatically**, including items added by other mods. Other attachment types, such as `BedrollBottom`, do not count.
- Five optional categories of vanilla backpacks and sling bags can also qualify.
- Makeshift slings can be crafted from eight configurable material groups, without additional ingredients. Dismantling restores the exact original item type and its numeric condition as recorded just before crafting.

## Sandbox settings

Build 42's options appear on two alphabetical pages, both using the `SlingRequired` sandbox namespace:

**Makeshift Sling Materials:** Belts, Denim Strips, Leather Strips, Neckties, Ropes, Scarves, Sheets (including Sheet Rope), Twine.

**Qualifying Back Wear:** Hiking Backpacks, Large Framepacks, Military Backpacks / ALICE Packs, School Backpacks, Sling Bags.

All options default to enabled. Turning a material option off prevents that material from being crafted into a sling; it does not invalidate existing slings. Back-wear options are only required for items that do *not* explicitly provide the Back weapon attachment.

## Installation

Install the whole `SlingRequired` folder in `Zomboid/mods/`, keeping `common/` and `42/` side by side (`SlingRequired/42/mod.info` and `SlingRequired/42/media/sandbox-options.txt`). Enable **Sling Required** for the save before creating a Custom Sandbox world. Its settings are on the **Sling Required - Makeshift Sling Materials** and **Sling Required - Qualifying Back Wear** pages of the sandbox world-creation settings, not in the main-menu Mod Options screen. Restart the game after replacing local mod files; if options still do not appear, check for another installed copy of the same mod ID and inspect `Zomboid/console.txt` for loading errors.

## Build 42 notes

- The mod uses `craftRecipe`, `ItemType = base:clothing`, and Build 42 JSON translations.
- The makeshift sling temporarily reuses the vanilla scarf visual and `base:scarf` body location; it is not a custom shoulder model.
- Only numeric item condition and original item type are stored for restoration. Existing mod-specific item state, fabric holes, stains, and other clothing data are not yet serialized by this implementation.
- Not tested in a live Project Zomboid session. Verify crafting, dismantling, and hotbar changes in both single-player and multiplayer before publishing.
