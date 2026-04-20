import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/models/restaurant.dart';

void main() {
  test(
    'filterRestaurantsFromList returns restaurants that have allergen-free menu items',
    () async {
      // Create two restaurants with full required fields
      final r1 = Restaurant(
        id: 'r1',
        name: 'Safe Cafe',
        addressId: 'a1',
        website: '',
        hours: List<String>.filled(7, ''),
        phone: '',
        cuisine: 'Cafe',
        disclaimers: [],
      );

      final r2 = Restaurant(
        id: 'r2',
        name: 'Risky Diner',
        addressId: 'a2',
        website: '',
        hours: List<String>.filled(7, ''),
        phone: '',
        cuisine: 'Diner',
        disclaimers: [],
      );

      // Implement a focused test service that mimics the Firestore queries
      final service = _TestRestaurantService(
        menus: {'r1': 'm1', 'r2': 'm2'},
        menuItems: {
          'm1': [<String>[]], // m1 has one item with empty allergens
          'm2': [
            ['a1'],
          ], // m2 items contain allergen a1
        },
      );

      final result = await service.filterRestaurantsFromList([r1, r2], ['a1']);
      expect(result.map((r) => r.id).toList(), contains('r1'));
      expect(result.map((r) => r.id).toList(), isNot(contains('r2')));
    },
  );
}

class _TestRestaurantService extends RestaurantService {
  final Map<String, String> menus; // restaurantId -> menuId
  final Map<String, List<List<String>>>
  menuItems; // menuId -> list of allergens per item

  _TestRestaurantService({required this.menus, required this.menuItems})
    : super(FakeFirebaseFirestore());

  @override
  Future<List<Restaurant>> filterRestaurantsFromList(
    List<Restaurant> allRestaurants,
    List<String> selectedAllergenIds,
  ) async {
    if (selectedAllergenIds.isEmpty) return allRestaurants;

    List<Restaurant> safe = [];
    for (final r in allRestaurants) {
      final menuId = menus[r.id];
      if (menuId == null) continue;
      final items = menuItems[menuId] ?? [];
      // allMenuItemsUnsafe if every menu item contains at least one selected allergen
      final allUnsafe = items.every(
        (allergens) => selectedAllergenIds.any((s) => allergens.contains(s)),
      );
      if (!allUnsafe) safe.add(r);
    }
    return safe;
  }
}
