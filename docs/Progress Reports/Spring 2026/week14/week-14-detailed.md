# Summary of Changes

This document summarizes **Task #4 – UI consistency** from `docs/demo_preparation.md` §4. Skipped items from the doc (**§4.4 AppBar actions**, **§4.5 Bottom navigation**) were left unchanged by design. No database or Firestore schema changes were made.

---

## Task #4 – UI consistency (`docs/demo_preparation.md` §4)

Work follows a single pattern per concern: **`BackButtonRow`** for back navigation, **`ScreenInsets.content`** for primary body padding, **`NomNomProgress`** for loading indicators, and **`headlineSmall`** with centered alignment for primary screen titles where the doc calls for alignment with the majority pattern.

| Item                            | Resolution                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **4.1 Back button**             | Extended **`BackButtonRow`** to take `targetRoute`, optional `routeArguments`, `blockIfCurrent`, and `tooltip`. Added **`BackButtonRow.home`** (→ `AppRoutes.home`, blocks duplicate home) and **`BackButtonRow.toProfile`** (→ profile). **Sign-in**, **sign-up**, **menu** (home), **restaurant** (menu + `Restaurant` arguments), and **edit profile** (profile) use this widget instead of ad hoc `Align` + `IconButton`. Back actions remain body-level (no AppBar back). |
| **4.2 Heading style**           | **`RestaurantScreen`** primary title uses **`headlineSmall`**, centered via **`Align`**, matching sign-in / sign-up / menu / profile header. Detail lines below (hours, address, etc.) stay left-aligned for readability. **`displayName`** / **`displayCuisine`** are used for the title and cuisine line so empty data matches the rest of the app (**`Restaurant`** model helpers).                                                                                         |
| **4.3 Page padding**            | Introduced **`ScreenInsets`** (`app/lib/theme/screen_insets.dart`) with **`content`** = `EdgeInsets.all(24)`. Applied to **Home**, **Menu**, **Restaurant**, **Sign-in**, **Sign-up**, **Profile**, and **Edit Profile**. Home and menu filter strips no longer mix conflicting horizontal insets—the outer **`Padding`** is `24`; inner filter rows use vertical spacing only where needed.                                                                                   |
| **4.4 AppBar profile icon**     | **SKIPPED** (per doc).                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **4.5 Bottom nav destinations** | **SKIPPED** (per doc).                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **4.6 Loading spinners**        | Introduced **`NomNomProgress`** (`app/lib/widgets/nomnom_progress.dart`): **`pageIndicator`** / **`centeredPage`** (36×36) for list/full-area loading; **`inline`** (20×20, `strokeWidth: 2`) for buttons and dialogs. Replaced raw **`CircularProgressIndicator`** usages in **home**, **menu**, **sign-in**, **verify/update password**, **delete account dialog**, **allergen section**, **sign-up allergen** view.                                                         |

---

### Supporting / overlooked consistency

- **Profile (signed out):** “Please sign in…” is wrapped with **`ScreenInsets.content`** so it aligns with other full-screen messages.
- **`BackButtonRow` tests:** Updated to construct **`BackButtonRow.home`** (required route args after API change); added coverage for **`tooltipText`** on **`BackButtonRow.home`**.
- **Restaurant detail:** Cuisine line uses **`displayCuisine`** so “Not specified” appears when Firebase has no cuisine (aligned with cards and filters from prior work).

---

### Files touched (high level)

| Area    | Files                                                                                                                                                             |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Theme   | `app/lib/theme/screen_insets.dart` (**new**)                                                                                                                      |
| Widgets | `app/lib/widgets/back_button_row.dart`, `app/lib/widgets/nomnom_progress.dart` (**new**), `delete_account_dialog.dart`                                            |
| Screens | `sign_in_screen.dart`, `sign_up_screen.dart`, `home_screen.dart`, `menu_screen.dart`, `restaurant_screen.dart`, `profile_screen.dart`, `edit_profile_screen.dart` |
| Views   | `verify_current_password_view.dart`, `update_password_view.dart`, `allergen_section.dart`, `sign_up_allergen_view.dart`                                           |
| Tests   | `test/widget/widgets/back_button_row_test.dart`                                                                                                                   |

---

### Verification

`flutter test` completes successfully (all tests passing; existing skipped tests unchanged). `flutter analyze lib` reports only a pre-existing **use_build_context_synchronously** info in `profile_screen.dart` (not introduced by these edits).

---

## Task #5 – User feedback consistency (`docs/demo_preparation.md` §5)

Work aligns with the demo doc: **network / load failures** use **`ErrorBanner`** plus a **Retry** action where recovery is meaningful; **success** outcomes use **`SnackBar`** with copy from **`UserFeedbackMessages`**; **form validation** relies on field validators and banners only (no redundant validation **SnackBar**); **primary actions** use **`LoadingElevatedButton`**; **empty and guidance** copy is centralized in **`UserFeedbackMessages`**. No database or Firestore changes were made.

| Item                               | Resolution                                                                                                                                                                                                                                                                                                                              |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **5.1 API / network errors**       | **`HomeScreen`** allergen and restaurant failures, **`MenuScreen`** allergen load and menu load failures, and **delete-account** failure (from earlier in this sprint) use **`ErrorBanner`** instead of plain error **`Text`** or **SnackBar** for the same class of problem.                                                           |
| **5.2 Success SnackBars**          | Sign-in welcome, sign-up success, password change success, sign-out, and profile-updated messages use **`UserFeedbackMessages`** constants or helpers.                                                                                                                                                                                  |
| **5.3 Validation SnackBars**       | Removed the shared “please fix errors” **SnackBar** on invalid submit; **`SignInScreen`** test now expects inline **`Email is required`**.                                                                                                                                                                                              |
| **5.4 Loading on primary actions** | Introduced **`LoadingElevatedButton`** (spinner via **`NomNomProgress.inline`**) on sign-in, sign-up account step, sign-up allergen “Create Account”, edit profile save, verify password continue, and change password. **`LoadingElevatedButton.onPressed`** is **`FutureOr<void> Function()?`** so async handlers type-check cleanly. |
| **5.5 Empty-state copy**           | Home: **`homeSelectAllergensHint`**, **`homeNoRestaurantsMatch`**, and **`homeNoRestaurantsAvailable`** (unfiltered empty directory). Menu: filtered-empty uses **`menuNoSafeItemsWithFilters`**; “showing safe items” line appears when **`allMenuItems.isNotEmpty`** (not only when the filtered list has rows).                      |

### Supporting / overlooked consistency

- **`MenuScreen` initial load** — Replaced **`allergenIdToLabel.isEmpty`** gating (which could re-trigger loads after a failed allergen fetch) with **`_initialDataRequested`** so **`didChangeDependencies`** runs data load once per state instance.
- **`SignUpAllergenView`** — “Create Account” uses **`LoadingElevatedButton`** like other submit flows.
- **`EditProfileBody`** — **`_buildUpdatePasswordView`** now takes **`BuildContext`** so the password-change success **SnackBar** uses a valid **`context`** for **`mounted`** checks (fixes a compile error from using **`context`** inside a callback with no **`BuildContext`** in scope).

### Files touched (high level)

| Area     | Files                                                                                                                                                                           |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Messages | `app/lib/utils/user_feedback_messages.dart`                                                                                                                                     |
| Widgets  | `app/lib/widgets/loading_elevated_button.dart`, `nomnom_appbar.dart`                                                                                                            |
| Screens  | `sign_in_screen.dart`, `sign_up_screen.dart`, `profile_screen.dart`, `home_screen.dart`, `menu_screen.dart`                                                                     |
| Views    | `sign_up_account_view.dart`, `sign_up_allergen_view.dart`, `edit_profile_view.dart`, `edit_profile_body.dart`, `verify_current_password_view.dart`, `update_password_view.dart` |
| Tests    | `sign_in_screen_test.dart`, `main_smoke_test.dart`, `home_integration_test.dart`, `app_flow_test.dart`, `update_password_view_test.dart`                                        |

### Verification (Task #5)

`flutter test` completes successfully after expectation updates for new home copy and sign-in validation behavior.

---

## Branded SnackBars (`NomNomSnackBar`)

Introduced **`NomNomSnackBar`** (`app/lib/widgets/nomnom_snackbar.dart`), a reusable **`SnackBar`** subclass that reads **`Theme.of(context).colorScheme.primary`** and **`onPrimary`** so messaging matches **`nomnom_theme.dart`** (primary **`0xFF034c53`**, white **`onPrimary`** text). All **`showSnackBar`** call sites under **`lib/`** now use **`NomNomSnackBar`** instead of raw **`SnackBar`** widgets.

| Location                     | Change                                                                 |
| ---------------------------- | ---------------------------------------------------------------------- |
| **`sign_in_screen.dart`**    | Welcome message after successful sign-in                               |
| **`sign_up_screen.dart`**    | Account-created success                                                |
| **`profile_screen.dart`**    | Profile updated (keeps **2s** duration)                                |
| **`nomnom_appbar.dart`**     | Signed-out confirmation                                                |
| **`edit_profile_body.dart`** | Optional profile **`userMessage`** after save; password-change success |

### Files touched

| Area                      | Files                                                                                                               |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Widgets                   | `app/lib/widgets/nomnom_snackbar.dart` (**new**)                                                                    |
| Screens / views / widgets | `sign_in_screen.dart`, `sign_up_screen.dart`, `profile_screen.dart`, `nomnom_appbar.dart`, `edit_profile_body.dart` |

### Verification

`flutter test` passes with no test file changes required (behavior and strings unchanged).

---

## Navigation, header, and form polish (post–Task #5)

| Item                                   | Resolution                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Tappable app title**                 | **`NomnomAppBar`** wraps the title in an **`InkWell`** that calls **`replaceIfNotCurrent(..., AppRoutes.home, blockIfCurrent: [AppRoutes.home])`**, so “NomNom Safe” always returns the user to the restaurant list (home) from any route.                                                                                                                                                                               |
| **Title row with back (menu pattern)** | **Restaurant**, **sign-in**, and **sign-up** use a single **`Row`**: back control, **`Expanded`** centered **`headlineSmall`**, and a **48px** trailing spacer (matches **Menu**’s back + title + action width). **Edit profile** uses the same row for the whole flow; the step title (**Edit Profile** / **Enter Current Password** / **Enter New Password**) updates from **`EditProfileController.viewState`**.      |
| **Edit profile / password headings**   | **`EditProfileView`**, **`VerifyCurrentPasswordView`**, and **`UpdatePasswordView`** take optional **`showHeading`** (default **`true`** for tests). **`EditProfileScreen`** passes **`EditProfileBody(..., showHeading: false)`** so headings are not duplicated under the shared title row.                                                                                                                            |
| **Delete account dialog**              | Replaced plain obscured **`TextFormFieldWithController`** with **`PasswordField`** (`FormValidators.password`), plus local **`_passwordVisible`** toggle (eye icon).                                                                                                                                                                                                                                                     |
| **Bottom nav on edit-profile route**   | **`getNavIndexForRoute`** treats **`AppRoutes.editProfile`** like **`AppRoutes.profile`** (profile tab index **1**) so the **Profile** icon is selected on edit profile and password steps, not **Search**. **`nomnom_theme`** adds **`bottomNavigationBarTheme`** with **`selectedItemColor`** **`0xFF008080`** (teal, aligned with **`AppBar`**) so the selected tab reads as turquoise/teal vs grey unselected icons. |

### Files touched

| Area       | Files                                                                                                                |
| ---------- | -------------------------------------------------------------------------------------------------------------------- |
| Navigation | `nav_utils.dart`, `test/unit/nav/nav_utils_test.dart`                                                                |
| Theme      | `nomnom_theme.dart`                                                                                                  |
| Widgets    | `nomnom_appbar.dart`, `delete_account_dialog.dart`                                                                   |
| Screens    | `restaurant_screen.dart`, `sign_in_screen.dart`, `sign_up_screen.dart`, `edit_profile_screen.dart`                   |
| Views      | `edit_profile_body.dart`, `edit_profile_view.dart`, `verify_current_password_view.dart`, `update_password_view.dart` |

### Verification

`flutter test` completes successfully (**`nav_utils`** test extended for **`AppRoutes.editProfile`**).

---

## Task #7 – Code quality & cleanup (`docs/demo_preparation.md` §7)

Work tracks the demo doc’s cleanup list and a few related gaps. **No database or Firestore schema changes** were made. User-visible load failures on the sign-up allergen step now match the rest of the app (**`ErrorBanner`** + **Retry**).

| Item                                    | Resolution                                                                                                                                                                                                                                                                                                                                                   |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **7.1 Remove unused file**              | **`utils/auth_utils.dart`** was already removed in an earlier sprint (duplicate of **`FormValidators`**); confirmed no remaining imports.                                                                                                                                                                                                                    |
| **7.2 Firestore typing**                | **`RestaurantService`**, **`MenuService`**, **`AddressService`**, and **`AllergenService`** now hold **`FirebaseFirestore _firestore`** (optional ctor arg, default **`FirebaseFirestore.instance`**). Removed **`dynamic`** field types and unnecessary **`.cast<dynamic>()`** on query snapshots; iteration uses typed **`snapshot.docs`**.                |
| **7.3 `Restaurant.toJson()`**           | Already aligned with Firestore field names (**`address_id`**, **`menu_id`**, etc.); no code change this pass.                                                                                                                                                                                                                                                |
| **7.4 `Address` document id**           | **`AddressService.getRestaurantAddress`** merges **`{'id': addressDoc.id, ...addressData}`** before **`Address.fromJson`**, so **`Address.id`** matches the **`addresses`** document id. Added unit test for a successful formatted address.                                                                                                                 |
| **7.5 `SignUpAllergenView` + feedback** | Already resolves **`AllergenService`** via **`getAllergenService(context)`** (shared instance / cache). **Overlooked:** allergen load errors used plain red **`Text`**; replaced with **`ErrorBanner`**, **`UserFeedbackMessages.loadAllergensFailed`**, and **Retry**; **`_loadAllergens`** clears error and sets loading at the start (including retries). |

### Test updates

Unit tests that injected **`Object()`** / **`{}`** into service subclasses now pass **`FakeFirebaseFirestore()`** from **`fake_cloud_firestore`** so constructors match **`FirebaseFirestore?`**. **`allergen_service_test`**, **`menu_service_test`**, **`restaurant_service_test`**, and **`address_service_test`** were rewritten to seed **`FakeFirebaseFirestore`** instead of the bespoke **`test/unit/services/fake_firestore.dart`** helper (that helper remains for **`AuthService`** / **`FirestoreAdapter`** tests). Integration, widget, acceptance, and controller tests that **`extend AllergenService`** / **`RestaurantService`** were updated the same way.

### Files touched (high level)

| Area     | Files                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Services | `restaurant_service.dart`, `menu_service.dart`, `address_service.dart`, `allergen_service.dart`                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Views    | `sign_up_allergen_view.dart`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Docs     | `docs/demo_preparation.md` (§7 action checkboxes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Tests    | `test/unit/services/*.dart` (four service tests), `test/regression/restaurant_service_regression_test.dart`, `test/widget/app_flow_test.dart`, `test/integration/home_integration_test.dart`, `test/integration/edit_profile_integration_test.dart`, `test/unit/controllers/profile_controller_test.dart`, `test/unit/controllers/edit_profile_controller_test.dart`, `test/widget/views/edit_profile_body_widget_test.dart`, `test/widget/views/allergen_section_widget_test.dart`, `test/acceptance/sign_in_edit_profile_acceptance_test.dart` |

### Verification (Task #7)

`flutter test` completes successfully (all tests passing).
