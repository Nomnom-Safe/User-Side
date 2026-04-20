/// Consistent copy for service / network failures (no connectivity package required).
abstract final class UserFeedbackMessages {
  static const String connectionOrServer =
      "Couldn't reach the server. Check your connection and try again.";

  static const String loadAllergensFailed =
      "Couldn't load allergens. Check your connection and try again.";

  static const String loadRestaurantsFailed =
      "Couldn't load restaurants. Check your connection and try again.";

  static const String filterRestaurantsFailed =
      "Couldn't filter restaurants. Check your connection and try again.";

  static const String loadMenuFailed =
      "Couldn't load the menu. Check your connection and try again.";

  static const String menuNoItemsListed =
      "This restaurant doesn't have any menu items listed yet.";

  static const String loadAddressFailed = "Couldn't load address.";

  // --- Success SnackBars (`docs/demo_preparation.md` §5.2) ---

  static String signInWelcome(String firstName) =>
      'Welcome back, ${firstName.trim()}!';

  static const String signInWelcomeGeneric = 'Welcome back!';

  static const String signUpSuccess = 'Account created successfully.';

  static const String passwordChangeSuccess = 'Password updated successfully.';

  static const String signedOutSuccess = 'You have been signed out.';

  static const String profileUpdatedSuccess = 'Profile updated successfully.';

  static const String accountDeletionFailed =
      "Couldn't delete your account. Check your password and try again.";

  // --- Empty / guidance copy (`docs/demo_preparation.md` §5.5) ---

  static const String homeNoRestaurantsMatch =
      'No restaurants found matching your allergen filters. Try adjusting your selections.';

  /// Shown when the directory loaded successfully but the list is empty with no allergen filter applied.
  static const String homeNoRestaurantsAvailable =
      'No restaurants are available right now.';

  static const String homeSelectAllergensHint =
      'Select allergens above to filter restaurants by dietary safety or cuisine.';

  static const String menuNoSafeItemsWithFilters =
      'No safe menu items found. All items at this restaurant contain your selected allergens.';
}
