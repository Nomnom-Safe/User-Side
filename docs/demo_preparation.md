# NomNom Safe - Demo Preparation Plan

> **Timeline:** 2 weeks (April 9 - April 23, 2026)
>
> **Generated:** April 9, 2026
>
> **Scope:** UI consistency, user feedback, edge cases, error handling, Firebase model sync

---

## Table of Contents

1. [Firebase / MCP Access Issue](#1-firebase--mcp-access-issue)
2. [Critical Bugs & Errors](#2-critical-bugs--errors)
3. [Model / Firebase Schema Sync](#3-model--firebase-schema-sync)
4. [UI Consistency](#4-ui-consistency)
5. [User Feedback Consistency](#5-user-feedback-consistency)
6. [Edge Cases](#6-edge-cases)
7. [Code Quality & Cleanup](#7-code-quality--cleanup)
8. [Demo-Day Polish](#8-demo-day-polish)
9. [Suggested Sprint Schedule](#9-suggested-sprint-schedule)

---

## 1. Firebase / MCP Access Issue

The Firebase MCP server in Cursor is currently errored and cannot connect. Additionally, the `.env` file references `./firebase-cursor-key.json` but that file does not appear in the workspace (it may be gitignored or not yet placed).

### Action Items

- [x] Verify `firebase-cursor-key.json` exists at the workspace root (next to `.env`)
- [x] Debug to see why the server cannot connect to the database
- [x] Once MCP access is working, use it to audit Firestore collections (`restaurants`, `menus`, `menu_items`, `allergens`, `addresses`, `users`) and compare against your Dart models (see Section 3)

---

## 2. Critical Bugs & Errors

### 2.1 `AuthStateProvider.signOut()` uses a non-standard method name

**File:** `providers/auth_state_provider.dart` (line 44)

```dart
await (_auth_serviceOrCreate()).signOut();
```

The helper is named `_auth_serviceOrCreate()` which uses underscores in the method name (Dart convention is lowerCamelCase). More critically, it works but is inconsistent with how other methods access the service (`_authService ??= AuthService()`). Not a crash bug, but a code smell that could cause confusion.

**Fix:** Rename `_auth_serviceOrCreate` to `_authServiceOrCreate` or just inline the pattern used everywhere else.

---

### 2.2 `AuthStateProvider.signUp()` does not propagate errors from `AuthService`

**File:** `providers/auth_state_provider.dart` (lines 14-31)

`AuthService.signUp()` returns a `String?` error message, but `AuthStateProvider.signUp()` calls it and discards the return value. If sign-up fails (e.g., passwords don't match), the error is silently lost. The `SignUpScreen._handleSignUp()` never sees an error unless an exception is thrown.

**Fix:** Check the return value and throw or surface the error:

```dart
Future<void> signUp({...}) async {
  final error = await (_authService ??= AuthService()).signUp(...);
  if (error != null) throw Exception(error);
  notifyListeners();
}
```

---

### 2.3 `AuthStateProvider.signIn()` does not propagate errors from `AuthService`

**File:** `providers/auth_state_provider.dart` (lines 34-40)

Same issue as sign-up. `AuthService.signIn()` returns `String?` but the provider discards it. The `SignInScreen` does check `authStateProvider.isSignedIn` afterward, but generic Firebase errors will be silently swallowed.

**Fix:** Same pattern as sign-up - check return and throw/surface.

---

### 2.4 `Restaurant.toJson()` field name mismatch

**File:** `models/restaurant.dart` (line 47)

`fromJson` reads `json['address_id']` but `toJson` writes `'address': addressId`. This mismatch means if you ever round-trip a Restaurant through JSON, the address_id is lost.

**Fix:** Change `toJson` to use `'address_id': addressId`.

---

### 2.5 `Restaurant.fromJson` missing null safety on required fields

**File:** `models/restaurant.dart` (lines 29-40)

Fields like `name`, `phone`, `cuisine`, and `hours` are accessed directly from JSON without null checks. If any Firestore document is missing a field, the app will crash with a null error.

**Fix:** Add fallback defaults or throw descriptive errors:

```dart
name: json['name'] ?? 'Unknown',
phone: json['phone'] ?? '',
cuisine: json['cuisine'] ?? 'Unknown',
hours: List<String>.from(json['hours'] ?? []),
```

---

### 2.6 `Address.fromJson` missing null safety

**File:** `models/address.dart` (lines 17-23)

All fields are accessed without null guards. A missing `zipCode`, `state`, etc. in Firestore will crash the app.

**Fix:** Add `?? ''` defaults.

---

### 2.7 `User.fromJson` missing null safety on `id`, `first_name`, `last_name`, `email`

**File:** `models/user.dart` (lines 17-23)

These are directly cast without fallback. If a Firestore document is malformed, this will crash.

**Fix:** Add defaults or validate.

---

### 2.8 `MenuItem.fromJson` missing null safety on `id`, `name`, `description`, `menu_id`

**File:** `models/menu_item.dart` (lines 19-26)

Same pattern.

**Fix:** Add `?? ''` defaults.

---

### 2.9 `Menu.fromJson` missing null safety on `id`, `restaurant_id`

**File:** `models/menu.dart` (lines 11-17)

Same pattern.

**Fix:** Add `?? ''` defaults.

---

### 2.10 `RestaurantScreen` is not scrollable

**File:** `screens/restaurant_screen.dart` (lines 70-157)

The restaurant detail screen uses a `Column` directly. If the content is taller than the screen (e.g., many hours or disclaimers), it will overflow.

**Fix:** Wrap the `Column` in a `SingleChildScrollView`.

---

### 2.11 `deleteAccount` dialog uses wrong context for `Navigator.pop`

**File:** `widgets/delete_account_dialog.dart` (line 46)

The dialog `builder` receives `_` as the dialog context, but the `Cancel` button (line 37) uses the _outer_ `context` instead. This could cause the wrong route to be popped.

**Fix:** Use the dialog's local context for both `Navigator.pop` calls:

```dart
builder: (dialogContext) {
  ...
  TextButton(
    onPressed: () => Navigator.pop(dialogContext, false),
    ...
  ),
  TextButton(
    onPressed: () async {
      ...
      Navigator.pop(dialogContext, success);
    },
    ...
  ),
}
```

---

### 2.12 `AuthService.signIn` loads user profile twice

**File:** `services/auth_service.dart` (lines 106-124)

After `signInWithEmailAndPassword`, it calls `await loadCurrentUser()` (which sets `_currentUser`), then immediately re-fetches the same user document and sets `_currentUser` again. This is redundant and doubles the Firestore reads.

**Fix:** Remove the duplicate fetch. Just call `loadCurrentUser()` and return.

---

### 2.13 Duplicate validation logic

**Files:** `utils/auth_utils.dart` vs `utils/form_validation_utils.dart`

Both files contain email and password validation logic. `auth_utils.dart` has `validateEmailFormat`, `validatePasswordFormat`, `validatePasswordsMatch` while `form_validation_utils.dart` has `FormValidators.email`, `FormValidators.password`, `FormValidators.confirmPassword`. Only the `FormValidators` class is actually used.

**Fix:** Delete `auth_utils.dart` or consolidate into one file to avoid confusion.

---

## 3. Model / Firebase Schema Sync

These are the Dart models and their expected Firestore collections. Once you have MCP access, verify each field exists and matches.

### 3.1 `User` model (`users` collection)

| Dart Field  | Firestore Key | Type             | Notes                                     |
| ----------- | ------------- | ---------------- | ----------------------------------------- |
| `id`        | document ID   | string           | Set from `doc.id`, not stored in document |
| `firstName` | `first_name`  | string           |                                           |
| `lastName`  | `last_name`   | string           |                                           |
| `email`     | `email`       | string           |                                           |
| `allergies` | `allergies`   | array of strings | Stores allergen doc IDs                   |

**Check for:** Has the DB added any new fields (e.g., `phone`, `profile_image`, `dietary_preferences`)? Has `allergies` been renamed or restructured?

### 3.2 `Restaurant` model (`restaurants` collection)

| Dart Field    | Firestore Key      | Type               | Notes                          |
| ------------- | ------------------ | ------------------ | ------------------------------ |
| `id`          | document ID        | string             |                                |
| `name`        | `name`             | string             |                                |
| `addressId`   | `address_id`       | string             |                                |
| `website`     | `website`          | string             |                                |
| `hours`       | `hours`            | array of 7 strings | Mon-Sun                        |
| `phone`       | `phone`            | string             |                                |
| `cuisine`     | `cuisine`          | string             |                                |
| `disclaimers` | `disclaimers`      | array of strings   |                                |
| `logoUrl`     | `logoUrl`          | string (nullable)  |                                |
| `menu`        | (not in Firestore) | embedded           | Joined from `menus` collection |

**Check for:** Has `address_id` been renamed to `address`? Has `hours` format changed? Any new fields like `rating`, `price_range`, `is_active`?

### 3.3 `Menu` model (`menus` collection)

| Dart Field     | Firestore Key   | Type     | Notes                               |
| -------------- | --------------- | -------- | ----------------------------------- |
| `id`           | document ID     | string   |                                     |
| `restaurantId` | `restaurant_id` | string   |                                     |
| `items`        | (not in doc)    | embedded | Joined from `menu_items` collection |

**Check for:** Has `restaurant_id` been renamed? Any new fields like `name`, `is_active`, `season`?

### 3.4 `MenuItem` model (`menu_items` collection)

| Dart Field    | Firestore Key | Type             | Notes                   |
| ------------- | ------------- | ---------------- | ----------------------- |
| `id`          | document ID   | string           |                         |
| `name`        | `name`        | string           |                         |
| `description` | `description` | string           |                         |
| `allergens`   | `allergens`   | array of strings | Stores allergen doc IDs |
| `itemType`    | `item_type`   | string           | e.g., "entree", "side"  |
| `menuId`      | `menu_id`     | string           |                         |

**Check for:** Has `item_type` changed to an enum or different casing? Has `allergens` been renamed? Any new fields like `price`, `calories`, `image_url`, `is_available`?

### 3.5 `Allergen` model (`allergens` collection)

| Dart Field | Firestore Key | Type   | Notes |
| ---------- | ------------- | ------ | ----- |
| `id`       | document ID   | string |       |
| `label`    | `label`       | string |       |

**Check for:** Any new fields like `icon`, `severity`, `description`? Have allergen IDs or labels changed?

### 3.6 `Address` model (`addresses` collection)

| Dart Field | Firestore Key | Type   | Notes                             |
| ---------- | ------------- | ------ | --------------------------------- |
| `id`       | document ID   | string | Not currently set from `fromJson` |
| `street`   | `street`      | string |                                   |
| `city`     | `city`        | string |                                   |
| `state`    | `state`       | string |                                   |
| `zipCode`  | `zipCode`     | string |                                   |

**Check for:** Has `zipCode` been renamed to `zip_code`? Is `id` being passed in `fromJson` (currently it's not — `AddressService` doesn't pass `doc.id`)?

### Action Items

- [ ] Connect to Firebase via MCP or Firebase console
- [ ] Run through each collection and compare fields vs. model
- [ ] Update models for any new/renamed/removed fields
- [ ] Add null-safety defaults to all `fromJson` constructors
- [ ] Test that data loads correctly after model changes

---

## 4. UI Consistency

### 4.1 Back Button Inconsistency

Different screens use different back button patterns:

| Screen              | Back Button Style               | Behavior                         |
| ------------------- | ------------------------------- | -------------------------------- |
| `SignInScreen`      | IconButton in body              | `replaceIfNotCurrent` to home    |
| `SignUpScreen`      | IconButton in body              | `replaceIfNotCurrent` to home    |
| `MenuScreen`        | IconButton in header row        | `replaceIfNotCurrent` to home    |
| `RestaurantScreen`  | Standalone `Align` + IconButton | `replaceIfNotCurrent` to menu    |
| `EditProfileScreen` | `BackButtonRow` widget          | `replaceIfNotCurrent` to profile |
| `ProfileScreen`     | No back button                  | Uses bottom nav only             |

**Fix:** Standardize back navigation. Either:

- Use the `BackButtonRow` widget everywhere (adapting it to accept a target route)
- Or put a back button in the AppBar (more conventional)

### 4.2 Heading Style Inconsistency

| Screen            | Heading                  | Style                   |
| ----------------- | ------------------------ | ----------------------- |
| SignIn            | "Welcome Back"           | `headlineSmall`, center |
| SignUp (account)  | "Create Account"         | `headlineSmall`, center |
| SignUp (allergen) | "Select Allergens"       | `headlineSmall`, center |
| EditProfile       | "Edit Profile"           | `headlineSmall`, center |
| VerifyPassword    | "Enter Current Password" | `headlineSmall`, center |
| UpdatePassword    | "Enter New Password"     | `headlineSmall`, center |
| MenuScreen        | restaurant.name          | `headlineSmall`, center |
| RestaurantScreen  | restaurant.name          | `headlineMedium`, left  |
| ProfileScreen     | fullName                 | `headlineSmall`, center |
| HomeScreen        | No heading               | N/A                     |

**Fix:** Pick one heading level and alignment for all screens. `headlineSmall` + center-aligned is the majority pattern; update `RestaurantScreen` to match.

### 4.3 Page Padding Inconsistency

| Screen            | Padding                                             |
| ----------------- | --------------------------------------------------- |
| HomeScreen        | Mixed (12 horizontal for filters, 12 for text)      |
| MenuScreen        | Mixed (16 for header, 12 for filters, 16 for items) |
| RestaurantScreen  | `EdgeInsets.all(16)`                                |
| SignInScreen      | `EdgeInsets.all(24)`                                |
| SignUpScreen      | `EdgeInsets.all(24)`                                |
| ProfileScreen     | `EdgeInsets.all(24)`                                |
| EditProfileScreen | `EdgeInsets.all(24)`                                |

**Fix:** Define a standard content padding constant (e.g., `EdgeInsets.all(24)` or `EdgeInsets.symmetric(horizontal: 16, vertical: 24)`) and use it across all screens.

### 4.4 AppBar Actions When Signed In

When signed in, the AppBar only shows "Sign Out". There is no way to navigate to the profile from the AppBar itself; it's only in the bottom nav. Consider adding a profile icon to the AppBar for signed-in users.

### 4.5 Bottom Navigation Bar

The bottom nav only shows for signed-in users (which is fine), but it only has 2 items: "Search" and "Profile". Consider if this is the final design or if you want to add more destinations.

### 4.6 Loading Spinner Inconsistency

Some loading spinners are sized (`SizedBox(height: 20, width: 20)` inside buttons) while the page-level ones are just `CircularProgressIndicator()` without sizing. The button spinners are good; ensure they all use the same pattern.

### Action Items

- [ ] Standardize back button pattern (create a reusable widget or use AppBar leading)
- [ ] Standardize heading style across all screens
- [ ] Define and use a constant for page padding
- [ ] Consider adding profile icon to AppBar for signed-in users
- [ ] Ensure all loading spinners use consistent sizing

---

## 5. User Feedback Consistency

### 5.1 Error Display: Mixed Patterns

The app uses three different patterns for showing errors:

1. **Inline error banner** (Container with red border): Used in `SignInScreen`, `SignUpAccountView`, `VerifyCurrentPasswordView`, `UpdatePasswordView`, `EditProfileScreen` (via `ErrorBanner` widget)
2. **SnackBar**: Used in `MenuScreen` (load errors), `ProfileScreen` (success/failure), form validation messages ("Please fix the errors above.")
3. **Inline text**: Used in `HomeScreen` allergen error

**Fix:** Standardize error display:

- **Field validation errors**: Keep inline under fields (Flutter's built-in)
- **API/network errors**: Use the `ErrorBanner` widget consistently (already exists)
- **Success feedback**: Use SnackBars
- **Remove SnackBars for errors** and replace with `ErrorBanner`

### 5.2 Success Feedback

Only `ProfileScreen` shows a success SnackBar after editing. Sign-in, sign-up, and password change silently navigate away without confirmation.

**Fix:**

- [ ] Add success SnackBar after sign-in ("Welcome back, {name}!")
- [ ] Add success SnackBar after sign-up ("Account created successfully!")
- [ ] Add success SnackBar after password change ("Password updated successfully.")
- [ ] Add success SnackBar after sign-out ("You have been signed out.")

### 5.3 Form Validation Feedback

When form validation fails, some screens show a SnackBar ("Please fix the errors above.") while the form fields themselves show inline errors. The SnackBar is redundant and slightly confusing.

**Fix:** Remove the "Please fix the errors above" SnackBars. The red inline validation messages on each field are sufficient and more informative.

### 5.4 Loading State Feedback

Buttons in `SignInScreen` and `UpdatePasswordView` show a small spinner while loading. But `EditProfileView`'s "Save Changes" button just disables without a spinner.

**Fix:** Add a loading spinner to all action buttons when `isLoading` is true. Create a reusable `LoadingButton` widget.

### 5.5 Empty State Messages

| Context                      | Current Message                             | Suggested Improvement                                                                     |
| ---------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------- |
| No restaurants match         | "No restaurants match your filters"         | "No restaurants found matching your allergen filters. Try adjusting your selections."     |
| No menu items match          | "No menu items match your allergen filters" | "No safe menu items found. All items at this restaurant contain your selected allergens." |
| No allergens selected (home) | "No allergens selected."                    | "Select allergens above to filter restaurants by dietary safety."                         |
| No allergens on profile      | "No allergens selected" (italic)            | Fine as-is                                                                                |

### Action Items

- [ ] Replace SnackBar errors with `ErrorBanner` widget consistently
- [ ] Add success SnackBars for sign-in, sign-up, password change, sign-out
- [ ] Remove redundant "Please fix the errors above" SnackBars
- [ ] Create a `LoadingButton` widget and use it everywhere
- [ ] Improve empty state messages

---

## 6. Edge Cases

### 6.1 Restaurant with Empty Hours Array

`Restaurant.todayHours` accesses `hours[weekday - 1]` which will throw `RangeError` if `hours` has fewer than 7 entries or is empty.

**Fix:**

```dart
String get todayHours {
  final weekday = DateTime.now().weekday;
  if (hours.isEmpty || weekday > hours.length) return 'Hours unavailable';
  return hours[weekday - 1];
}
```

### 6.2 Restaurant with No Menu

If a restaurant has no menu document in Firestore, the `MenuScreen` will show "No menu items match your allergen filters" which is misleading.

**Fix:** Show a distinct "No menu available for this restaurant" message when `restaurantMenu` is null after loading.

### 6.3 User Signs Out While on Profile/EditProfile Screen

If a user signs out (e.g., via AppBar button) while viewing their profile, the `ProfileScreen` checks `user == null` and shows "Please sign in to view your profile" which is fine. But `EditProfileScreen` doesn't handle this — it would crash because `_formModel` was initialized from a now-null user.

**Fix:** Add a null check in `EditProfileScreen`'s `build` method.

### 6.4 Network Errors / Offline State

There is no global error handling for network failures. If Firebase is unreachable, individual `try/catch` blocks handle it but inconsistently.

**Fix:** Consider adding a connectivity check or a global error boundary widget.

### 6.5 Email Change Sends Verification But Doesn't Inform User

`AuthService.updateProfile` calls `fbUser?.verifyBeforeUpdateEmail(email)` and stores `pending_email` but never tells the user to check their email for verification.

**Fix:** Return a specific message like "A verification email has been sent to {email}. Your email will be updated after verification."

### 6.6 Item Type Filter Uses String Manipulation

`MenuScreen._updateFilteredMenuItems()` converts filter labels like "Entrees" to "entree" by lowercasing and removing trailing "s". This is fragile.

**Fix:** Use a proper mapping:

```dart
const itemTypeDisplayToDb = {
  'Sides': 'side',
  'Entrees': 'entree',
  'Desserts': 'dessert',
  'Drinks': 'drink',
  'Appetizers': 'appetizer',
};
```

### 6.7 `AllergenService` Cache Never Invalidates

The `AllergenService` caches allergens on first load and never refreshes. If allergens are updated in Firestore, the app must be restarted.

**Fix:** For a demo this is fine. For production, add a `clearCache()` method or TTL-based invalidation.

### 6.8 `AuthService` Singleton Can't Be Reset in Production

The singleton pattern with `_instance` means if sign-in fails and leaves partial state, the service can't be re-initialized without `clearInstanceForTests()`.

**Fix:** For demo, ensure sign-in/sign-up error paths properly clean up state. For production, consider a different pattern.

### 6.9 Cuisine Filter Disappears When All Restaurants Filtered Out

On the HomeScreen, the cuisine filter is hidden when allergen filtering leaves zero restaurants. This is correct behavior but can be confusing.

**Fix:** Consider always showing the cuisine filter but disabling it when there are no restaurants, with a tooltip explaining why.

### 6.10 `deleteAccount` Dialog Doesn't Show Loading State

When the user taps "Delete" in the confirmation dialog, there's no loading indicator while the deletion is in progress.

**Fix:** Add a loading state to the dialog.

### 6.11 Password Not Cleared After Failed Verification

In `VerifyCurrentPasswordView`, if the user enters the wrong password, the error message shows but the password field retains the incorrect value.

**Fix:** Clear the password controller on failure.

### Action Items

- [ ] Add bounds check to `Restaurant.todayHours`
- [ ] Show distinct message when restaurant has no menu
- [ ] Handle null user in `EditProfileScreen` build
- [ ] Inform user about email verification
- [ ] Replace fragile item type string manipulation with a proper map
- [ ] Add loading state to delete account dialog
- [ ] Clear password field on failed verification

---

## 7. Code Quality & Cleanup

### 7.1 Remove Unused File

`utils/auth_utils.dart` contains validation functions that are never used (replaced by `FormValidators`). Delete it.

### 7.2 `RestaurantService` Uses `dynamic` for Firestore

`RestaurantService`, `MenuService`, `AddressService`, and `AllergenService` all type their Firestore instance as `dynamic`. This disables all type checking.

**Fix:** Type them as `FirebaseFirestore` with proper imports, or create adapters like `AuthService` uses.

### 7.3 `Restaurant.toJson()` Field Mismatch

Already covered in 2.4 but listing here for cleanup tracking.

### 7.4 `Address.fromJson` Doesn't Set `id`

`AddressService.getRestaurantAddress` calls `Address.fromJson(addressData)` but `addressData` comes from `addressDoc.data()` which doesn't include the document ID. The `Address.id` field will be null/crash.

**Fix:** Pass `{'id': addressDoc.id, ...addressData}` or skip the `id` field since it's not used in `AddressService`.

### 7.5 `SignUpAllergenView` Creates New `AllergenService` Instances

**File:** `views/sign_up_allergen_view.dart` (lines 40-43)

Creates `AllergenService()` three times instead of using the one from the provider. Since `AllergenService` caches internally this works, but it's inconsistent with the rest of the app.

**Fix:** Use `context.read<AllergenService>()` or accept it as a constructor parameter.

### Action Items

- [ ] Delete `utils/auth_utils.dart`
- [ ] Fix `Restaurant.toJson()` field name
- [ ] Fix `Address.fromJson` to include `id`
- [ ] Use provider's `AllergenService` in `SignUpAllergenView`
- [ ] Consider typing Firestore instances properly in services

---

## 8. Demo-Day Polish

### 8.1 Splash / Loading Screen

The app currently shows nothing meaningful while Firebase initializes and allergens load (before `runApp`). Consider adding a splash screen or loading indicator.

### 8.2 App Icon and Branding

Ensure the app has a custom icon and branding instead of the default Flutter icon.

### 8.3 Error Boundaries

Wrap the root `MaterialApp` in an error widget builder to catch and display unexpected errors gracefully during the demo.

```dart
ErrorWidget.builder = (FlutterErrorDetails details) {
  return Center(child: Text('Something went wrong'));
};
```

### 8.4 Test the Full User Journey

Before the demo, test these flows end-to-end:

1. **Guest flow**: Open app > see restaurants > filter by allergens > view menu > view restaurant details
2. **Sign-up flow**: Sign up > select allergens > see filtered home screen > view profile > edit profile > change allergens > see updated home screen
3. **Sign-in flow**: Sign out > sign in > verify allergens persisted > navigate to profile
4. **Edit profile flow**: Edit name/email > save > verify changes reflected
5. **Password change flow**: Edit profile > change password > verify current > set new > verify sign-in with new password
6. **Delete account flow**: Profile > delete account > confirm > verify redirected to home as guest
7. **Edge cases**: Try invalid email, wrong password, mismatched passwords, empty fields

### 8.5 Responsive Design

Check how the app looks on:

- [ ] Mobile (phone-sized viewport)
- [ ] Tablet
- [ ] Web (desktop browser window)

The hover effects on `RestaurantCard` suggest web support, so ensure the layout works at various widths.

### Action Items

- [ ] Add splash screen or loading state
- [ ] Set custom app icon
- [ ] Add global error boundary
- [ ] Run through all user journey test flows
- [ ] Test on multiple screen sizes

---

## 9. Suggested Sprint Schedule

### Week 1 (April 9-15): Fix Bugs & Sync Models

| Day         | Focus             | Tasks                                                                                                                           |
| ----------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Day 1-2** | Firebase & Models | Fix MCP access, audit Firestore collections, update models for any schema changes, add null-safety to all `fromJson`            |
| **Day 3**   | Critical Bugs     | Fix errors from Section 2 (AuthStateProvider error propagation, toJson mismatch, delete dialog context, duplicate signIn fetch) |
| **Day 4-5** | Edge Cases        | Fix items from Section 6 (todayHours bounds, no-menu message, item type mapping, email verification feedback)                   |

### Week 2 (April 16-22): Polish UI & Test

| Day         | Focus          | Tasks                                                                                             |
| ----------- | -------------- | ------------------------------------------------------------------------------------------------- |
| **Day 1-2** | UI Consistency | Standardize back buttons, headings, padding, loading spinners (Section 4)                         |
| **Day 3**   | User Feedback  | Standardize error/success display, add success SnackBars, create LoadingButton widget (Section 5) |
| **Day 4**   | Code Cleanup   | Remove unused files, fix code quality items (Section 7)                                           |
| **Day 5**   | Demo Prep      | Add splash screen, set app icon, add error boundary, full user journey testing (Section 8)        |

### Day Before Demo (April 22)

- [ ] Complete all test flows from Section 8.4
- [ ] Test on target demo device/platform
- [ ] Prepare demo script (which features to show and in what order)
- [ ] Have a fallback plan if Firebase is slow/down

---

## Quick Reference: Files to Modify

| Priority | File                                 | Changes Needed                                        |
| -------- | ------------------------------------ | ----------------------------------------------------- |
| **P0**   | `providers/auth_state_provider.dart` | Fix error propagation in signUp/signIn, rename method |
| **P0**   | `models/restaurant.dart`             | Fix toJson field name, add null-safety to fromJson    |
| **P0**   | `models/user.dart`                   | Add null-safety to fromJson                           |
| **P0**   | `models/menu_item.dart`              | Add null-safety to fromJson                           |
| **P0**   | `models/menu.dart`                   | Add null-safety to fromJson                           |
| **P0**   | `models/address.dart`                | Add null-safety to fromJson                           |
| **P0**   | `widgets/delete_account_dialog.dart` | Fix Navigator context                                 |
| **P1**   | `services/auth_service.dart`         | Remove duplicate user fetch in signIn                 |
| **P1**   | `screens/restaurant_screen.dart`     | Wrap in SingleChildScrollView, standardize heading    |
| **P1**   | `screens/menu_screen.dart`           | Fix item type filtering, add no-menu state            |
| **P1**   | `screens/home_screen.dart`           | Improve empty state messages                          |
| **P1**   | `views/sign_up_allergen_view.dart`   | Use provider's AllergenService                        |
| **P2**   | `theme/theme_constants.dart`         | Add shared padding/sizing constants                   |
| **P2**   | `widgets/back_button_row.dart`       | Make reusable with target route param                 |
| **P2**   | All screens                          | Standardize padding, headings, error display          |
| **P2**   | `utils/auth_utils.dart`              | Delete (unused)                                       |
| **P3**   | `main.dart`                          | Add error boundary                                    |
| **P3**   | Various                              | Add success SnackBars, create LoadingButton widget    |
