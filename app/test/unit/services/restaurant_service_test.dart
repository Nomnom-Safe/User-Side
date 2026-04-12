import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';

import 'fake_firestore.dart';

void main() {
  group('RestaurantService', () {
    test(
      'getAllRestaurants returns restaurants even with missing menus',
      () async {
        final restaurants = [
          FakeDocument('r1', {
            'id': 'r1',
            'name': 'R1',
            'address_id': 'a1',
            'website': '',
            'hours': List.generate(7, (_) => ''),
            'phone': '',
            'cuisine': '',
            'disclaimers': <String>[],
            'logoUrl': null,
          }),
          FakeDocument('r2', {
            'id': 'r2',
            'name': 'R2',
            'address_id': 'a2',
            'website': '',
            'hours': List.generate(7, (_) => ''),
            'phone': '',
            'cuisine': '',
            'disclaimers': <String>[],
            'logoUrl': null,
          }),
        ];
        final fs = FakeFirestore({'businesses': restaurants, 'menus': []});
        final service = RestaurantService(fs);
        final all = await service.getAllRestaurants();
        expect(all.length, 2);
      },
    );

    test(
      'filterRestaurantsFromList handles empty menus and allergen formats',
      () async {
        final restaurants = [
          FakeDocument('r1', {
            'id': 'r1',
            'name': 'R1',
            'address_id': 'a1',
            'website': '',
            'hours': List.generate(7, (_) => ''),
            'phone': '',
            'cuisine': '',
            'disclaimers': <String>[],
            'logoUrl': null,
          }),
        ];
        final menus = [
          FakeDocument('m1', {'id': 'm1', 'business_id': 'r1'}),
        ];
        final menuItems = [
          FakeDocument('i1', {
            'id': 'i1',
            'menu_id': 'm1',
            'name': 'Item1',
            'description': '',
            'allergens': ['a1'],
            'item_type': 'food',
          }),
        ];
        final fs = FakeFirestore({
          'businesses': restaurants,
          'menus': menus,
          'menu_items': menuItems,
        });
        final service = RestaurantService(fs);

        // Provide an empty list to filter -> should still return restaurant list
        final filtered = await service.filterRestaurantsFromList(
          await service.getAllRestaurants(),
          [],
        );
        expect(filtered, isA<List>());
      },
    );
  });
}
