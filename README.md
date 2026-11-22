# Sling Required

A Project Zomboid **Build 42** mod requiring a worn sling (or suitable back-worn equipment) before the **Back** weapon hotbar slot can be used.

## Behavior

- Without qualifying equipment, the Back hotbar slot is removed and an attached item is detached to inventory.
- A worn **Makeshift Sling** enables the Back slot.
- **Any worn item explicitly declaring `AttachmentsProvided = Back` qualifies automatically**, including items added by other mods. Other attachment types, such as `BedrollBottom`, do not count.
- Five optional categories of vanilla backpacks and sling bags can also qualify.
- Makeshift slings can be crafted from eight configurable material groups, without additional ingredients. Dismantling restores the exact original item type and its numeric condition as recorded just before crafting.

## Sandbox settings

Build 42's options appear on one **Sling Required** sandbox page (`SlingRequired` namespace). Two decorative, unchecked checkbox headings separate the alphabetical groups; those checkboxes do not affect gameplay:

**Materials Allowed for Sling Crafting:** Belts, Denim Strips, Leather Strips, Neckties, Ropes, Scarves, Sheets (including Sheet Rope), Twine.

**Back-Worn Gear with Built-In Slings:** Hiking Backpacks, Large Framepacks, Military Backpacks / ALICE Packs, School Backpacks, Sling Bags.

All options default to enabled. Turning a material option off prevents that material from being crafted into a sling; it does not invalidate existing slings. Back-wear options are only required for items that do *not* explicitly provide the Back weapon attachment.

## Installation

Install the whole `SlingRequired` folder in `Zomboid/mods/`, preserving `SlingRequired/42/mod.info` and `SlingRequired/42/media/sandbox-options.txt`. The `common/` folder may be present but does not contain the sandbox settings.

To see the sandbox settings when creating a world:

1. Fully close Project Zomboid after updating the local mod files.
2. From the **main menu**, open **Mods** and enable **Sling Required** there. Enabling a mod only for an existing save is not sufficient for the new-world sandbox settings screen.
3. Choose **Solo > Custom Sandbox** and look for the **Sling Required** sandbox page. The Materials Allowed for Sling Crafting and Back-Worn Gear with Built-In Slings sections share that page. These are not entries in the separate Mod Options menu.

If the page still does not appear, check whether a duplicate `SlingRequired` mod ID exists in another local mods directory or the Steam Workshop installation; the game may load a different copy of `sandbox-options.txt` than the one being edited. Inspect `Zomboid/console.txt` for errors mentioning `sandbox-options.txt`, `CustomSandboxOptions`, or `SlingRequired`. The hotbar behavior working by itself does not confirm sandbox registration: the mod defaults to enabled behavior when `SandboxVars.SlingRequired` is missing.

## Build 42 notes

- The mod uses `craftRecipe`, `ItemType = base:clothing`, and Build 42 JSON translations.
- The makeshift sling temporarily reuses the vanilla scarf visual and `base:scarf` body location; it is not a custom shoulder model.
- Only numeric item condition and original item type are stored for restoration. Existing mod-specific item state, fabric holes, stains, and other clothing data are not yet serialized by this implementation.
- Not tested in a live Project Zomboid session. Verify crafting, dismantling, and hotbar changes in both single-player and multiplayer before publishing.
