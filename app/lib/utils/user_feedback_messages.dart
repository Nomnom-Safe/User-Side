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

  static const String loadAddressFailed = "Couldn't load address.";
}
