# Summary of Changes

## Firebase Collection vs Model Mismatches Found & Fixed

1. **Collection name mismatch** — Firebase uses `businesses`, code queried `restaurants` (which was empty).

2. **`Restaurant` model** (`app/lib/models/restaurant.dart`):
   - Added `menuId` field (maps to `menu_id` in Firebase)
   - Added `allergens` field (restaurant-level allergens list)
   - Added `diets` field (dietary accommodations list)
   - Made `logoUrl` optional (not present in Firebase data)
   - Fixed `toJson()` — was writing `'address'` instead of `'address_id'`
   - Added null-safety defaults to all `fromJson` fields
   - Fixed `todayHours` to handle empty hours array safely

3. **`Menu` model** (`app/lib/models/menu.dart`):
   - Renamed `restaurantId` → `businessId` (Firebase uses `business_id`, not `restaurant_id`)
   - Added `title` field (Firebase menus have a `title`)
   - Added null-safety defaults to `fromJson`

4. **`MenuItem` model** (`app/lib/models/menu_item.dart`):
   - Added `ingredients` field (some Firebase menu items have ingredients)
   - Added `hasIngredients` getter
   - Added null-safety defaults to all `fromJson` fields

5. **`User` model** — Added null-safety defaults to `fromJson`

6. **`Address` model** — Added null-safety defaults to `fromJson`

7. **`Allergen` model** — Added null-safety default for `label` in `fromJson`

## Service Updates

- **`RestaurantService`**: Changed collection from `'restaurants'` to `'businesses'`; updated menu query to use `'business_id'`
- **`MenuService`**: Updated `getMenuByRestaurantId` to query by `'business_id'`

## UI Updates

- **`MenuScreen`**: Now displays menu `title` under restaurant name, and shows `ingredients` on menu item cards
- **`RestaurantScreen`**: Now accepts an `AllergenService` for resolving diet labels; displays "Dietary Accommodations" section with chips when the restaurant has diets

## Test Updates

- Updated **17 test files** across unit, widget, integration, and regression tests to use the new field names (`business_id`, removed required `logoUrl`, etc.)
- Fixed `restaurant_screen_test.dart` to inject a `FakeAllergenService`
- Updated `user_model_test.dart` to expect defaults instead of throws on missing fields

## Database Updates

- Removed all unnamed businesses from the database and all connected data
