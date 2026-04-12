# Individual Project

## Week 8 Detailed Progress Report on branch `feature/menu-filter`

### Summary

Added an item-type filter to the menu UI and wired the underlying model so menu items can be filtered by their type (e.g. entree, side, dessert).

### New files

No new source files were added in this commit.

### File Modifications (major changes)

#### `app/lib/models/menu_item.dart` (modified)

- Added/ensured presence of an `itemType` field on the `MenuItem` model: `final String itemType;`
- Updated JSON (de)serialization to read and write `item_type`:
  - `factory MenuItem.fromJson` now sets `itemType: json['item_type'] ?? ''`.
  - `toJson()` includes `'item_type': itemType`.

Why: menu item documents include an `item_type` field (lowercase, singular). Exposing this on the model is required so the UI can filter by the type.

Implementation details:

- Fields are non-nullable and default to an empty string for `item_type` when the JSON field is absent (defensive parsing).

#### `app/lib/screens/menu_screen.dart` (significant modifications)

- Added item-type filter state and UI wiring:

  - `availableItemTypes` — a list of display labels used by the `Filter` widget. The labels are capitalized and plural (e.g. `['Sides','Entrees','Desserts','Drinks','Appetizers']`).
  - `selectedItemTypes` — runtime state to hold the selected display labels.
  - A `Filter` widget instance is rendered on the Menu screen (label: 'Item types') and bound to `availableItemTypes` / `selectedItemTypes`.

- Extended filtering logic in `_updateFilteredMenuItems()` to combine item-type filtering with existing allergen-exclusion logic.

Key technical detail (mapping display -> DB values):

- Database `item_type` values are lowercase singular words (e.g. `side`, `entree`). The UI uses capitalized plural display names for readability.
- To ensure correct comparisons, the filtering code maps each selected display label to a lowercase singular form before matching against `item.itemType`:
  - `selectedItemTypes.map((type) => type.toLowerCase().replaceAll(RegExp('s\$'), ''))` — this converts e.g. `Sides` -> `sides` -> `side`.
- The final comparison uses `item.itemType.toLowerCase()` so that the match is case-insensitive and robust against variations.

UX choice and defensive behavior:

- The commit preserves display capitalization (so checkboxes/labels read nicely) while maintaining correct backend mapping.
- The code composes item-type filtering with allergen filtering so both filters apply together.
- The model parsing provides safe defaults when `item_type` is absent.

### Tests

- No unit or widget tests were added in this commit.

Suggested tests to add (small, high-value):

- `MenuItem` parsing unit test: verify `itemType` is populated from `item_type` JSON and defaults to `''` when missing.
- `MenuScreen` widget test(s):
  - Ensure the Item types `Filter` renders the capitalized options.
  - Verify that selecting `Sides` filters in items whose `item_type == 'side'` (and that selection composes with allergen filters).

### Why these changes were made (rationale)

- Filtering by item type is a common use-case for menus — it lets users quickly narrow results (e.g., show only desserts).
- The UI benefits from capitalized, plural labels for clarity; however, Firestore stores `item_type` in a different form. The commit resolves this mismatch by mapping display labels to the stored value format at comparison time.

### Files touched (concise list)

- Modified: `app/lib/models/menu_item.dart` — expose and (de)serialize `itemType`.
- Modified: `app/lib/screens/menu_screen.dart` — add item-type filter UI and filtering logic.

### How to run / verify locally

1. From the repo root open a terminal and run the app in the `app` folder (PowerShell example):

```powershell
cd app
flutter pub get
flutter analyze
flutter run
```

2. Manual checks to verify this commit's behavior:

- Open the app and navigate to a Restaurant → Menu screen.
- Confirm the "Item types" filter appears and shows capitalized options like "Sides", "Entrees", etc.
- Toggle a type (e.g. "Sides") and confirm the list updates to only show items whose `item_type` is `side` in the backend. Also confirm that selecting allergen exclusions still excludes items that contain those allergens.
