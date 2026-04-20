import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';

Map<String, dynamic> _businessFields(String name) => {
  'name': name,
  'address_id': 'a1',
  'website': '',
  'hours': List<String>.generate(7, (_) => ''),
  'phone': '',
  'cuisine': '',
  'disclaimers': <String>[],
  'menu_id': '',
  'allergens': <String>[],
  'diets': <String>[],
};

void main() {
  group('RestaurantService', () {
    test(
      'getAllRestaurants returns restaurants even with missing menus',
      () async {
        final fs = FakeFirebaseFirestore();
        await fs.collection('businesses').doc('r1').set(_businessFields('R1'));
        await fs.collection('businesses').doc('r2').set(_businessFields('R2'));
        final service = RestaurantService(fs);
        final all = await service.getAllRestaurants();
        expect(all.length, 2);
      },
    );

    test(
      'filterRestaurantsFromList handles empty menus and allergen formats',
      () async {
        final fs = FakeFirebaseFirestore();
        await fs.collection('businesses').doc('r1').set(_businessFields('R1'));
        await fs.collection('menus').doc('m1').set({
          'business_id': 'r1',
          'title': 'M',
        });
        await fs.collection('menu_items').doc('i1').set({
          'menu_id': 'm1',
          'name': 'Item1',
          'description': '',
          'allergens': ['a1'],
          'item_type': 'food',
        });
        final service = RestaurantService(fs);

        final filtered = await service.filterRestaurantsFromList(
          await service.getAllRestaurants(),
          [],
        );
        expect(filtered, isA<List>());
      },
    );
  });
}
