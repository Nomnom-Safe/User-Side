import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/menu_service.dart';

import 'fake_firestore.dart';

void main() {
  group('MenuService', () {
    test('getMenuByRestaurantId returns null when no menu', () async {
      final fs = FakeFirestore({'menus': []});
      final service = MenuService(fs);
      final menu = await service.getMenuByRestaurantId('r1');
      expect(menu, isNull);
    });

    test('getMenuItems returns empty list when no menu_items', () async {
      final fs = FakeFirestore({
        'menus': [
          FakeDocument('m1', {'id': 'm1', 'business_id': 'r1'}),
        ],
        'menu_items': [],
      });
      final service = MenuService(fs);
      final items = await service.getMenuItems('m1');
      expect(items, isEmpty);
    });

    test('getMenuItems parses menu items correctly', () async {
      final menus = [
        FakeDocument('m1', {'id': 'm1', 'business_id': 'r1'}),
      ];
      final menuItems = [
        FakeDocument('i1', {
          'id': 'i1',
          'menu_id': 'm1',
          'name': 'Burger',
          'description': 'Tasty',
          'allergens': [],
          'item_type': 'food',
          'price': 5.0,
        }),
      ];
      final fs = FakeFirestore({'menus': menus, 'menu_items': menuItems});
      final service = MenuService(fs);
      final items = await service.getMenuItems('m1');
      expect(items.length, 1);
      expect(items.first.name, 'Burger');
    });
  });
}
