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

## Task #6 – Edge cases (`docs/demo_preparation.md` §6)

Work tracked the demo doc’s edge-case list and a few related gaps. User-facing failures use a single vocabulary from `app/lib/utils/user_feedback_messages.dart` (`UserFeedbackMessages`) where appropriate, plus existing `ErrorBanner` / inline errors for form flows. No database or Firestore schema changes were made.

| Item                                     | Resolution                                                                                                                                                                                                                                                                                 |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **6.1 Empty / short `hours`**            | Already safe: `Restaurant.todayHours` returns `"Hours unavailable"` when `hours` is empty or shorter than the current weekday index.                                                                                                                                                       |
| **6.2 No menu**                          | Already distinct: `MenuScreen` shows a dedicated empty state when the menu document is missing vs. when filters match nothing.                                                                                                                                                             |
| **6.3 Sign out on Edit Profile**         | `EditProfileScreen` watches `AuthStateProvider`; when `currentUser` is null it shows `ErrorBanner` (“Please sign in to edit your profile.”) and `BackButtonRow` instead of assuming a loaded form model.                                                                                   |
| **6.4 Network / inconsistent errors**    | Load paths on home, menu, restaurant, profile, sign-up allergen step, and edit-profile allergen fetch catch failures and set user-visible messages via `UserFeedbackMessages` (and existing banners where already used).                                                                   |
| **6.5 Email verification**               | `ProfileUpdateResult` models success vs. failure with an optional `userMessage`. `AuthService.updateProfile` / `AuthStateProvider.updateProfile` return it; when email verification is triggered, the UI can show a SnackBar with the verification copy before navigating back on success. |
| **6.6 Item type filter**                 | Already using an explicit display-to-DB map on `MenuScreen` (no fragile plural-stripping regex).                                                                                                                                                                                           |
| **6.7 Allergen cache**                   | `AllergenService.clearCache()` clears in-memory caches; `HomeScreen` refreshes allergens when returning to the route so edits elsewhere can be reflected without an app restart.                                                                                                           |
| **6.8 Partial auth state after sign-in** | If Firebase Auth succeeds but the user document cannot be loaded, `AuthService.signIn` signs out of Firebase Auth and clears local user state, returning a clear error string instead of leaving a half-signed-in session.                                                                 |
| **6.9 Cuisine filter hidden**            | Cuisine `FilterModal` stays visible when allergens have loaded; it is disabled with a `Tooltip` when there are no cuisines or no restaurants match allergens, and enabled otherwise (`filter_modal.dart` `enabled` / `disabledTooltip`).                                                   |
| **6.10 Delete account loading**          | `delete_account_dialog.dart` uses a small stateful content widget: while deletion runs, actions are disabled and a progress indicator appears on the destructive action.                                                                                                                   |
| **6.11 Clear password on failed verify** | After a failed `verifyCurrentPassword`, the current-password field is cleared so the user is not left staring at a wrong value; `onContinue` is async to allow awaiting verification.                                                                                                      |

**Tests:** Fakes were updated for `Future<ProfileUpdateResult> updateProfile`, async `onContinue` in verify-password widget tests, and `void clearCache()` on `implements AllergenService` test doubles. Full `flutter test` run passes.

### Additional Edge Cases

**1. `Restaurant` model (`app/lib/models/restaurant.dart`)**

- Added `Restaurant.unavailableDisplay` (`'Unavailable'`).

- **`todayHours`**: Uses that label when there are no hours, the weekday is out of range, or **today’s line is blank** (whitespace-only).

- **`displayName`**: Empty or the JSON fallback `'Unknown'` → `Unavailable`.

- **`displayCuisine`** / **`displayPhone`**: Empty/whitespace → `Unavailable`.

- **`displayHourLines`**: For the full week list, empty hours becomes a single `Unavailable` line; each blank day line becomes `Unavailable`.

**2. UI uses display values**

- **`RestaurantScreen`**: `displayName`, `displayCuisine`, `displayPhone`, `displayHourLines`; website without URL shows `Unavailable` instead of `none`; resolved address treats null, empty, or `'Unknown'` (from `AddressService`) as `Unavailable` (still shows `Loading...` until the request finishes).

- **`RestaurantCard`** and **`MenuScreen`**: Titles use `displayName` and `displayCuisine`.

**3. Menu allergen line (`app/lib/screens/menu_screen.dart`)**
The line _"Showing menu items that do not contain your selected allergens:"_ is shown only when **`_selectedAllergenLabels.isNotEmpty && allMenuItems.isNotEmpty`**, so it does not appear when the menu has no items (including an empty list after load).

**4. Tests**

- `restaurant_model_test.dart` updated for the new `todayHours` text and new display-helper tests.

Full `flutter test` had already completed successfully in the earlier run; targeted restaurant tests were run again after the address `'Unknown'` mapping and passed.
