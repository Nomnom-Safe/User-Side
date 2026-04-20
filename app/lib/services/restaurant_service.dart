import 'package:nomnom_safe/models/restaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class to handle restaurant-related Firestore operations
class RestaurantService {
  final FirebaseFirestore _firestore;

  RestaurantService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch all restaurants (businesses) from Firestore
  Future<List<Restaurant>> getAllRestaurants() async {
    final snapshot = await _firestore.collection('businesses').get();

    return snapshot.docs.map<Restaurant>((doc) {
      final data = doc.data();
      return Restaurant.fromJson({'id': doc.id, ...data});
    }).toList();
  }

  /// Filter restaurants based on selected allergen ids
  Future<List<Restaurant>> filterRestaurantsFromList(
    List<Restaurant> allRestaurants,
    List<String> selectedAllergenIds,
  ) async {
    // If no allergens are selected, return all restaurants unfiltered.
    if (selectedAllergenIds.isEmpty) return allRestaurants;

    // Initialize an empty list to collect restaurants that are safe for the user.
    List<Restaurant> safeRestaurants = [];

    // Iterate over each restaurant to evaluate its menu items.
    for (final restaurant in allRestaurants) {
      final menuSnapshot = await _firestore
          .collection('menus')
          .where('business_id', isEqualTo: restaurant.id)
          .limit(1)
          .get();
      // Skip this restaurant if no menu is found.
      if (menuSnapshot.docs.isEmpty) continue;

      // Extract the ID of the found menu.
      final menuId = menuSnapshot.docs.first.id;

      // Query Firestore for all menu items linked to that menu.
      final menuItemsSnapshot = await _firestore
          .collection('menu_items')
          .where('menu_id', isEqualTo: menuId)
          .get();

      // Map each menu item to its list of allergens, defaulting to an empty list if none are present.
      final menuItems = menuItemsSnapshot.docs.map<List<String>>((doc) {
        final data = doc.data();
        final rawAllergens = data['allergens'];
        // Defensive: treat missing/null/non-list allergens as empty list
        final List<String> allergensList = rawAllergens is List
            ? rawAllergens
                  .map((e) => e?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toList()
            : <String>[];
        return allergensList;
      }).toList();

      // Check if every menu item contains at least one of the selected allergens.
      final allMenuItemsUnsafe = menuItems.every(
        (menuItemAllergens) => selectedAllergenIds.any(
          (selected) => menuItemAllergens.contains(selected),
        ),
      );

      // Add the restaurant to the safe list if at least one menu item is allergen-free.
      if (!allMenuItemsUnsafe) {
        safeRestaurants.add(restaurant);
      }
    }

    // Return the filtered list of safe restaurants.
    return safeRestaurants;
  }
}
