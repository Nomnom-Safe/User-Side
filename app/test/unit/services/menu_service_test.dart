import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/menu_service.dart';

void main() {
  group('MenuService', () {
    test('getMenuByRestaurantId returns null when no menu', () async {
      final fs = FakeFirebaseFirestore();
      final service = MenuService(fs);
      final menu = await service.getMenuByRestaurantId('r1');
      expect(menu, isNull);
    });

    test('getMenuItems returns empty list when no menu_items', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('menus').doc('m1').set({
        'business_id': 'r1',
        'title': 'Menu',
      });
      final service = MenuService(fs);
      final items = await service.getMenuItems('m1');
      expect(items, isEmpty);
    });

    test('getMenuItems parses menu items correctly', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('menus').doc('m1').set({
        'business_id': 'r1',
        'title': 'Menu',
      });
      await fs.collection('menu_items').doc('i1').set({
        'menu_id': 'm1',
        'name': 'Burger',
        'description': 'Tasty',
        'allergens': <String>[],
        'item_type': 'food',
        'price': 5.0,
      });
      final service = MenuService(fs);
      final items = await service.getMenuItems('m1');
      expect(items.length, 1);
      expect(items.first.name, 'Burger');
    });
  });
}
