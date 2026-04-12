# Individual Project

## Week 9 Detailed Progress Report on branch `feature/user-profiles`

### Summary

Implemented a complete user profile management system with authentication, account editing, allergen management, password security features, and account deletion and added session persistence, duplicate screen stacking prevention, UI refactoring with reusable components, and navigation standardization across the entire application.

### New files

The following new files were added to support the user profile feature:

- `app/lib/models/user.dart` — User data model with fields for authentication and allergen preferences
- `app/lib/providers/auth_state_provider.dart` — State management provider for authentication state
- `app/lib/services/auth_service.dart` — Service layer for user authentication and profile operations
- `app/lib/screens/profile_screen.dart` — Display user profile information
- `app/lib/screens/edit_profile_screen.dart` — Edit user profile (name, email, password, allergens)

### File Modifications (major changes)

#### General Changes Affecting Many Files

- Removed raw `Scaffold`
- Removed individual appbar definitions
- Simplified code by using centralized navigation using `AppRoutes`
- Updated import paths to absolute paths
- Replaced `AllergenFilter` instances with `FilterModal`
- Improved styling

#### `app/lib/main.dart` (significant modifications)

- Integrated `AuthStateProvider` into the widget tree using `ListenableBuilder`
- Added centralized route definitions using `AppRoutes` enum
- Implemented duplicate screen stacking prevention via `RouteTracker`
- Added bottom navigation bar integration

#### `app/lib/models/user.dart` (new)

- Created `User` class with fields: `id`, `firstName`, `lastName`, `email`, `password`, `allergies`
- Implemented `fromJson()` factory constructor for Firestore document deserialization
- Implemented `toJson()` method for Firestore document serialization
- Added computed `fullName` property

#### `app/lib/providers/auth_state_provider.dart` (new)

- Created `AuthStateProvider` extending `ChangeNotifier` for state management
- Implemented methods: `signUp()`, `signIn()`, `signOut()`, `updateUserProfile()`, `deleteAccount()`
- Properties: `isSignedIn` (getter), `currentUser` (getter)
- All methods notify listeners on state changes

#### `app/lib/services/auth_service.dart` (new)

- Implemented singleton pattern for authentication service
- User data persistence using Firebase Firestore
- Sign-up validation: email uniqueness, password requirements, field validation
- Sign-in with email/password verification
- Profile update with partial updates (only changed fields written to database)
- Account deletion with proper cleanup
- Session persistence on app startup via `onAppStartup()`

#### `app/lib/screens/profile_screen.dart` (new)

- Displays current user profile information
- Shows user's full name, email, and selected allergens
- Displays allergen labels (not IDs) by mapping from Firestore allergen data
- "Edit Profile" button to navigate to edit screen
- "Delete Account" button with confirmation dialog
- Uses `FutureBuilder` to load and display allergen labels
- Responsive layout with proper spacing and typography

#### `app/lib/screens/edit_profile_screen.dart` (new)

- Form for editing user profile info (first name, last name, email, allergens, password)
- Form validation with user-friendly error messages
- Password visibility toggle on password fields
- Only writes changed attributes to database
- Cancel and Save buttons with loading state management

#### `app/lib/screens/sign_in_screen.dart` (new)

- User login form with email and password fields
- Form validation and error handling
- "Don't have an account? Sign Up" link
- Loading state during authentication
- Automatic navigation to home on successful sign-in
- Password visibility toggle

#### `app/lib/screens/sign_up_screen.dart` (new)

- Multi-step registration flow
- Step 1: Account information (first name, last name, email, password, confirm password)
- Step 2: Allergen selection
- Form validation with inline feedback
- Prevents duplicate emails
- Password strength requirements
- Navigation between steps with back button

#### `app/lib/views/edit_profile_view.dart` (new)

- View component for basic profile editing (name, email, allergens)
- Extracted from monolithic edit screen to allow for separate change password views

#### `app/lib/views/update_password_view.dart` (new)

- Dedicated view for password update workflow
- Includes current password verification
- New password and confirm password fields
- Uses `TextFormFieldWithController` for consistency
- Form validation and error handling
- Uses password visibility toggle

#### `app/lib/views/verify_current_password_view.dart` (new)

- Standalone view for current password verification
- Used before allowing password change
- Uses password visibility toggle

#### `app/lib/views/sign_up_account_view.dart` (new)

- Account information form for registration
- Collects: first name, last name, email, password, confirm password
- Form validation with user feedback
- Uses `TextFormFieldWithController` for consistent styling

#### `app/lib/views/sign_up_allergen_view.dart` (new)

- Allergen multi-select interface during registration
- Displays all available allergens from Firestore
- Uses `MultiSelectCheckboxList` widget
- Shows loading state during allergen data fetch
- Allows users to register without selecting allergens

#### `app/lib/widgets/password_field.dart` (new)

- Reusable password input field component
- Password visibility toggle with eye icon
- Eye (visible) and eye-slash (hidden) icons to indicate state
- Hidden by default for security
- Uses `TextFormFieldWithController` internally

#### `app/lib/widgets/text_form_field_with_controller.dart` (new)

- Reusable form field component wrapping `TextFormField`
- Accepts `TextEditingController` for value management
- Supports custom validators
- Provides consistent styling and spacing
- Replaces manual `TextField` widgets throughout the app

#### `app/lib/widgets/multi_select_checkbox_list.dart` (new)

- Reusable multi-select checkbox widget
- Displays list of items with checkboxes
- Callback for selection changes
- Used in allergen selection views
- Provides scrollable list for long option lists

#### `app/lib/widgets/nomnom_scaffold.dart` (new)

- Reusable scaffold template for all screens
- Includes `NomnomAppBar` at the top
- Includes bottom navigation bar (visible when signed in) with:
  - Search icon (home button)
  - Profile icon (profile button)
- Eliminates code duplication across screens

#### `app/lib/widgets/nomnom_appbar.dart` (renamed from nomnom_safe_appbar.dart)

- Renamed for consistency
- Updated to use centralized `authStateProvider` (no longer global instance)
- Sign Out functionality with confirmation
- Dynamic button visibility based on authentication state (Sign In/Sign Up/Sign Out)

#### `app/lib/widgets/filter_modal.dart` (renamed from filter.dart)

- Renamed for clarity
- Updated to use `TextFormFieldWithController`
- Made button label dynamic for reusability across filters
- Better visual presentation with consistent styling

#### `app/lib/navigation/nav_utils.dart` (new/modified)

- Centralized navigation utility functions
- Handles navigation with duplicate screen prevention
- Works in conjunction with `RouteTracker`

#### `app/lib/navigation/route_constants.dart` (new)

- Centralized route path definitions
- `AppRoutes` enum for type-safe route management
- Routes: home, signIn, signUp, profile, editProfile, restaurant, menu

#### `app/lib/navigation/nav_destination.dart` (new)

- Navigation destination configuration model
- Defines label, icon, and route for each navigation item
- Supports different destination sets (authenticated vs. unauthenticated)

#### `app/lib/utils/navigation_utils.dart` (new)

- Navigation helper functions
- Builds navigation items dynamically based on authentication state
- Handles screen push/replacement with duplicate prevention

#### `app/lib/utils/auth_utils.dart` (new)

- Authentication-related utility functions
- Email validation
- Password strength validation
- Field validation helpers

#### `firebase.json` (new)

- Firebase Cloud Functions configuration
- Includes Firestore indexes and Cloud Functions setup

#### `functions/package.json` (new)

- Node.js dependencies for Cloud Functions

#### `functions/index.js` (new)

- Firebase Cloud Functions implementation
- User creation, deletion, and other backend operations

#### `.firebaserc` (new)

- Firebase project configuration

### Technical Details

#### Authentication Flow

1. **Sign Up**

   - User enters account information (names, email, password)
   - Email uniqueness verified against Firestore
   - Password must be 6+ characters
   - User selects allergen preferences
   - New user document created in Firestore
   - User automatically signed in

2. **Sign In**

   - User enters email and password
   - Credentials verified against Firestore
   - Successful login loads user data and sets session

3. **Session Persistence**

   - `authStateProvider.onAppStartup()` called on app launch
   - Checks for existing user session
   - Restores authentication state if previous session exists

4. **Profile Management**

   - Users can view their complete profile
   - Edit profile supports multi-step form (info, password, allergens)
   - Only changed attributes are written to database (optimized)
   - Current password verification required for sensitive changes

5. **Account Deletion**
   - User clicks delete account button
   - Confirmation dialog prevents accidental deletion
   - Backend Cloud Function handles cleanup
   - User is signed out and redirected to home

#### Import Path Standardization

- Converted all relative imports to absolute paths (e.g., `package:nomnom_safe/screens/...`)
- Improved code clarity and reduces fragility
- Easier to refactor and reorganize files

#### Navigation Architecture

- Centralized route definitions in `AppRoutes` enum
- Route constants prevent typos and provide IDE autocomplete
- `RouteTracker` prevents duplicate screens from stacking
- Navigation utils encapsulate common navigation patterns

#### Code Organization

- **Views**: Reusable form components
- **Screens**: Full page implementations
- **Widgets**: UI components (buttons, inputs, scaffolds)
- **Controllers**: Business logic (edit profile operations)
- **Services**: Backend integration (authentication, database)
- **Providers**: State management
- **Utils**: Helper functions and constants

### Tests

- No unit or widget tests were added in this feature
- Application was tested manually through the UI

Suggested tests to add (high-value):

- **Unit Tests**:
  - `User` model deserialization from JSON
  - `AuthService` sign-up/sign-in validation logic
  - Password strength validation in `auth_utils.dart`
- **Widget Tests**:

  - `ProfileScreen` rendering with user data
  - `EditProfileScreen` multi-step form flow
  - `SignInScreen` form validation and error display
  - `SignUpScreen` multi-step flow with allergen selection
  - `PasswordField` visibility toggle functionality
  - `TextFormFieldWithController` validation states

- **Integration Tests**:
  - Complete sign-up flow end-to-end
  - Complete sign-in flow end-to-end
  - Profile edit workflow
  - Account deletion workflow

### Why these changes were made (rationale)

1. **User Profile Feature**: Essential for personalizing the app experience and allowing users to manage their allergen preferences
2. **Session Persistence**: Users shouldn't need to log in every time they restart the app
3. **Duplicate Screen Prevention**: Improves UX by preventing accidental navigation stacks
4. **Reusable Components**: Reduces code duplication and maintenance burden
5. **Navigation Standardization**: Centralized routes and constants reduce bugs and improve developer experience
6. **Absolute Imports**: Improves code clarity and makes refactoring safer
7. **Multi-step Forms**: Complex workflows (sign-up, edit profile) are easier to manage in separate views
8. **Password Security Features**: Visibility toggle helps users verify correct passwords; current password verification adds security layer
9. **Account Deletion**: Users have full control over their data

### Files touched (comprehensive list)

**New files created**:

- `app/lib/models/user.dart`
- `app/lib/providers/auth_state_provider.dart`
- `app/lib/services/auth_service.dart`
- `app/lib/screens/profile_screen.dart`
- `app/lib/screens/edit_profile_screen.dart`
- `app/lib/screens/sign_in_screen.dart`
- `app/lib/screens/sign_up_screen.dart`
- `app/lib/views/edit_profile_view.dart`
- `app/lib/views/update_password_view.dart`
- `app/lib/views/verify_current_password_view.dart`
- `app/lib/views/sign_up_account_view.dart`
- `app/lib/views/sign_up_allergen_view.dart`
- `app/lib/widgets/password_field.dart`
- `app/lib/widgets/text_form_field_with_controller.dart`
- `app/lib/widgets/multi_select_checkbox_list.dart`
- `app/lib/widgets/nomnom_scaffold.dart`
- `app/lib/navigation/route_tracker.dart`
- `app/lib/navigation/route_constants.dart`
- `app/lib/navigation/nav_destination.dart`
- `app/lib/utils/navigation_utils.dart`
- `app/lib/utils/auth_utils.dart`
- `app/lib/controllers/edit_profile_controller.dart`
- `firebase.json`
- `.firebaserc`
- `functions/package.json`
- `functions/index.js`

**Files renamed**:

- `app/lib/widgets/nomnom_safe_appbar.dart` → `app/lib/widgets/nomnom_appbar.dart`
- `app/lib/widgets/filter.dart` → `app/lib/widgets/filter_modal.dart`

### How to run / verify locally

1. From the repo root, ensure Firebase is configured:

```powershell
cd app
flutter pub get
flutter analyze
```

2. To verify the user profile feature works:

```powershell
flutter run
```

3. Manual verification checklist:

- **Sign Up Flow**:

  - Navigate to sign-up screen
  - Enter account information (names, email, password)
  - Confirm email validation works (reject if already exists)
  - Confirm password requirements enforced (6+ chars)
  - Proceed to allergen selection step
  - Select some allergens and complete sign-up
  - Verify user is automatically signed in

- **Profile Viewing**:

  - After sign-up, navigate to profile screen via bottom navbar
  - Verify profile displays: full name, email, selected allergens (with labels, not IDs)
  - Verify allergen labels are loaded correctly from Firestore

- **Profile Editing**:

  - Click "Edit Profile" button
  - Modify basic info (name, email)
  - Click "Edit Password" to go to password step
  - Enter current password to verify
  - Change password successfully
  - Proceed to allergen selection
  - Modify allergen selections
  - Save changes and verify in profile

- **Sign Out and Sign In**:

  - Sign out from profile screen
  - Sign in with previously created account
  - Verify session persists on app restart

- **Account Deletion**:

  - Click "Delete Account" button on profile
  - Confirm deletion dialog
  - Verify account is deleted and user is signed out
  - Verify can sign up with the same email again

- **Navigation**:
  - Verify bottom navbar appears on all authenticated screens
  - Verify duplicate screens don't stack when navigating
  - Verify absolute import paths work correctly
