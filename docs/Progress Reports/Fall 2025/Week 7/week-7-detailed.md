# Individual Project

## Week 7 Detailed Progress Report on branch `feature/menu`

### Summary

This week focused on wiring menus and menu items into the app, improving the menu screen UI and data flow, and strengthening model/service boundaries. Key work:

- Implemented a dedicated `MenuService` to fetch menus and menu items from Firestore.
- Updated the `Menu` and `Restaurant` models to carry menu data and to parse nested menu/menu_item JSON safely.
- Improved `RestaurantCard` interaction and navigation to the menu screen.
- Enhanced application routing and Firebase initialization in `main.dart`.
- Updated the `MenuScreen` UI and state management: two-step retrieval (menu -> menu items), allergen-label mapping, filtering by selected allergens, and delayed rendering until allergens have loaded.
- Added a project slide (`docs/Progress Reports/Week 7/week-7.md`) (presentation scaffold) and this detailed report.

The changes in this commit make the app show restaurant menus and menu items, provide allergen-aware filtering with human-readable labels, and improve UX when switching from a restaurant card to its menu.

### New files

- `app/lib/services/menu_service.dart`

  - Service responsible for retrieving a restaurant's menu (by restaurant id) and the corresponding menu items from Firestore.

- `app/docs/Progress Reports/Week 7/week-7.md`

  - Marp slide scaffold for the week 7 presentation (auto-generated slide template).

- `app/docs/Progress Reports/Week 7/week-7-detailed.md`
  - This detailed week 7 changelog (the file you're reading).

### File Modifications (major changes)

Note: file paths below are relative to `app/`.

#### `lib/services/menu_service.dart` (new)

- Responsibilities:
  - `getMenuByRestaurantId(String restaurantId)` — queries the `menus` collection with `restaurant_id` and returns the first menu as a `Menu` object (or null if none).
  - `getMenuItems(String menuId)` — queries the `menu_items` collection for items with the provided `menu_id` and returns a `List<MenuItem>`.
- Error handling: both methods wrap Firestore calls in try/catch and throw descriptive `Exception` on failures.
- Implementation details: uses dependency injection for a `FirebaseFirestore` instance (defaulting to `FirebaseFirestore.instance`) to make testing easier.

#### `lib/models/menu.dart` (modified)

- `Menu` model now has:
  - `id` (String)
  - `restaurantId` (String)
  - `items` (List<MenuItem>) — parsed from `json['items']` if present, defaulting to empty list when absent.
- `fromJson` and `toJson` updated to convert nested menu items via `MenuItem.fromJson` / `toJson`.
- This supports both inlined menu data and the service flow (where `menu` documents may not contain nested `items`, because items are stored in a separate `menu_items` collection).

#### `lib/models/restaurant.dart` (modified)

- New / changed properties and behaviors:
  - `Menu? menu` added — the model may optionally contain a nested `menu` object.
  - `logoUrl` made nullable (`String?`) and `logoUrl` JSON defaulting behavior adjusted.
  - Helper getters:
    - `hasWebsite` — whether website string is non-empty.
    - `todayHours` — convenience getter returning today’s hours based on the local weekday.
- `fromJson` updated to parse `menu` when present; `toJson` writes `menu?.toJson()`.

These changes let the app carry menu-related state with a restaurant when available, while still permitting the app to fetch menu items separately from `menu_items` collection.

#### `lib/widgets/restaurant_card.dart` (modified)

- Visual and interaction updates:
  - Adds hover effects with a scaling transform and elevation change for desktop/web mouse input.
  - Tighter layout and padding adjustments.
  - Shows the cuisine and today's hours (via `restaurant.todayHours`).
  - Navigation updated to push `MenuScreen` with the `restaurant` instance passed as an argument.

These updates produce a more polished, interactive card and make it simple to navigate to the menu screen for a restaurant.

#### `lib/screens/menu_screen.dart` (significant modifications)

- New state and service wiring:
  - Added `MenuService` and `AllergenService` usage.
  - State variables added: `allMenuItems`, `filteredMenuItems`, `restaurantMenu`, `isLoadingMenu`, and `isLoadingAllergens`.
- Two-step data retrieval flow:
  1. `_fetchMenuItems()` retrieves the `Menu` for the restaurant using `getMenuByRestaurantId`, then calls `getMenuItems(menu.id)` to populate `allMenuItems`.
  2. `_fetchAllergens()` loads `availableAllergens`.
- Allergen label mapping and filtering:
  - Menu item `allergens` are stored as allergen IDs. The UI now maps those IDs to allergen labels found in `availableAllergens` (falls back to ID when no match exists).
  - Filtering logic (`_updateFilteredMenuItems`) computes `filteredMenuItems` by excluding items that contain any selected allergen IDs.
- UI and rendering changes:
  - The screen delays rendering menu items until allergens have loaded (avoids showing raw IDs while label data is missing).
  - Shows loading indicators while allergens or menu data load.
  - Improved null-safety and removed unnecessary `?.` / forced unwraps because `MenuItem` fields are non-nullable.
- Error handling: errors while fetching menus or items are surfaced via a `SnackBar`.

These changes make the menu screen reliable, show human-friendly allergen labels, and ensure filters operate correctly.

#### `lib/main.dart` (modified)

- App initialization:
  - Ensures `Firebase.initializeApp` is awaited and initialized at startup using generated `DefaultFirebaseOptions`.
  - Adds `onGenerateRoute` handling for `/menu` and `/restaurant` routes, constructing `MenuScreen` and `RestaurantScreen` with the `Restaurant` argument from navigation.
- This simplifies navigation to menu and restaurant screens by route name and keeps login/startup initialization explicit.

### Tests

- No new unit or widget tests were added in this commit.
- Suggested tests to add next (low-effort, high value):
  - `MenuService` unit tests using `fake_cloud_firestore` to verify `getMenuByRestaurantId` and `getMenuItems` behavior (happy path + empty results + Firestore exceptions).
  - `MenuScreen` widget test verifying:
    - spinner appears while allergens/menu are loading,
    - allergen label mapping correctly replaces IDs with labels,
    - filtering removes items containing selected allergens.

### Why these changes were made (rationale)

- Previously the app had restaurant and allergen data, but menus and menu items were not reliably wired into the UI. The `MenuService` centralizes Firestore queries and makes menu/menu_item relationships explicit.
- Storing menu items in a collection (`menu_items`) with `menu_id` requires a two-step load (get menu -> get items). Reflecting that in the UI avoids fetching or rendering inconsistent data.
- Allergen IDs are not human-friendly; mapping to `Allergen.label` improves UX and accessibility.
- Delaying item rendering until allergens are loaded prevents flicker and avoids showing raw IDs.

### Files touched (concise list)

- Added: `lib/services/menu_service.dart`
- Added: `app/docs/Progress Reports/Week 7/week-7.md` (presentation scaffold)
- Modified: `lib/models/menu.dart`
- Modified: `lib/models/restaurant.dart`
- Modified: `lib/widgets/restaurant_card.dart`
- Modified: `lib/screens/menu_screen.dart`
- Modified: `lib/main.dart`

(Plus generated / tool files created under `.dart_tool` — not listed here as source changes.)

### How to run / verify locally

1. From the repo root open a terminal and run the app in the `app` folder (PowerShell example):

```powershell
cd app
flutter pub get
flutter analyze
flutter run
```

2. Manual checks to verify Week 7 behavior:

- Open the app and go to the home screen.
- Click a `RestaurantCard` to navigate to its Menu screen.
- Confirm the menu loads (or a friendly message is shown when not present).
- Toggle allergen filters and confirm filtered results update and that allergens are shown as labels, not IDs.
- While data loads you should see spinners instead of a partially populated list.

### Notes, caveats and next steps

- Menu items and menus are read from separate Firestore collections. If your `menus` documents contain nested `items`, the `Menu.fromJson` supports parsing them, but the common flow will request `menu_items` separately.
- Performance: constructing the allergen id→label mapping once (for example as a `Map<String,String>` built after `_fetchAllergens`) would speed repeated lookups — currently lookups use `firstWhere` with an `orElse` fallback.
- Consider adding unit tests for `MenuService` and widget tests for `MenuScreen` as outlined above.
- Consider caching `availableAllergens` once and reusing across screens/services if allergens rarely change.

### Completion summary

This commit implemented the menu retrieval flow and integrated menu UI with allergen-aware filtering and improved routing. I verified model nullability and updated UI code to remove unsafe null handling; error cases surface via `SnackBar` and UI shows loaders while data is being fetched.
