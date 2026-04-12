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

## Bug Fixes & Errors

### Doc-listed bugs (2.1 - 2.13)

**2.1** `AuthStateProvider._auth_serviceOrCreate()` — Removed the non-standard helper entirely; all methods now use the inline `(_authService ??= AuthService())` pattern consistently.

**2.2 & 2.3** `AuthStateProvider.signUp()` and `signIn()` silently discarded errors — Both now capture the `String?` return value from `AuthService` and throw an `Exception` if non-null. The `SignInScreen` and `SignUpScreen` already had catch blocks that display the error to the user.

**2.4 - 2.9** Model null-safety and `toJson` mismatches — Already fixed in the previous session (confirmed still passing).

**2.10** `RestaurantScreen` not scrollable — Replaced the outer `Padding` with `SingleChildScrollView` so long content won't overflow.

**2.11** `deleteAccount` dialog wrong context — Changed `builder: (_)` to `builder: (dialogContext)` and updated both `Navigator.pop` calls to use `dialogContext`.

**2.12** `AuthService.signIn` double Firestore read — Removed the redundant re-fetch after `loadCurrentUser()`. Now only calls `loadCurrentUser()` and checks `_currentUser`.

**2.13** Duplicate validation in `auth_utils.dart` — Deleted `auth_utils.dart` and its test since only `FormValidators` in `form_validation_utils.dart` is used anywhere.

### Additional bugs found and fixed

- **Standardized error display** — Replaced 4 hand-rolled inline `Container` error widgets (in `sign_in_screen.dart`, `sign_up_account_view.dart`, `verify_current_password_view.dart`, `update_password_view.dart`) with the existing `ErrorBanner` widget for consistency.

- **Inconsistent validation SnackBar messages** — `update_password_view.dart` said "Please correct the highlighted fields." while all others said "Please fix the errors above." Unified to the latter.

- **Dead code in `SignInScreen._handleSignIn`** — After making `signIn` throw on error, the `else` branch checking `isSignedIn` was unreachable. Cleaned it up so the success path simply navigates.

- **Fragile item-type filter** — The `MenuScreen` used `RegExp('s$')` to strip trailing 's' from display labels for comparison. Replaced with an explicit `_displayToItemType` map (`'Sides' → 'side'`, `'Entrees' → 'entree'`, etc.).

- **Menu screen: indistinguishable empty states** — Added distinct messages for error ("Could not load menu..."), no menu ("No menu available for this restaurant."), and no items matching filters ("No menu items match your current filters.").

- **Missing error handling** — Added try/catch to `RestaurantScreen._loadAddress()` and `_loadDiets()`, and `HomeScreen._fetchUnfilteredRestaurants()` / `_applyAllergenFilter()` so network failures show an error message instead of an infinite spinner.
