import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/utils/restaurant_utils.dart';
import 'package:nomnom_safe/models/restaurant.dart';

Restaurant _make(String id, String cuisine) => Restaurant(
  id: id,
  name: 'Name$id',
  addressId: 'addr$id',
  website: '',
  hours: List.filled(7, ''),
  phone: '',
  cuisine: cuisine,
  disclaimers: [],
);

void main() {
  group('Restaurant utils', () {
    test('extractAvailableCuisines returns sorted unique list', () {
      final list = [
        _make('1', 'Thai'),
        _make('2', 'Mexican'),
        _make('3', 'Thai'),
        _make('4', 'American'),
      ];

      final cuisines = extractAvailableCuisines(list);
      expect(cuisines, ['American', 'Mexican', 'Thai']);
    });

    test('filterRestaurantsByCuisine returns all when none selected', () {
      final list = [_make('1', 'A'), _make('2', 'B')];
      final out = filterRestaurantsByCuisine(list, []);
      expect(out.length, 2);
    });

    test('filterRestaurantsByCuisine filters correctly', () {
      final list = [_make('1', 'A'), _make('2', 'B'), _make('3', 'C')];
      final out = filterRestaurantsByCuisine(list, ['A', 'C']);
      expect(out.map((r) => r.id), containsAll(['1', '3']));
      expect(out.map((r) => r.id), isNot(contains('2')));
    });

    test('extractAvailableCuisines maps empty cuisine to Not specified', () {
      final list = [_make('1', 'Thai'), _make('2', ''), _make('3', '  ')];
      final cuisines = extractAvailableCuisines(list);
      expect(cuisines, ['Not specified', 'Thai']);
    });

    test(
      'filterRestaurantsByCuisine matches Not specified for empty cuisine',
      () {
        final list = [_make('1', 'A'), _make('2', ''), _make('3', 'B')];
        final out = filterRestaurantsByCuisine(list, [
          Restaurant.cuisineNotSpecifiedDisplay,
        ]);
        expect(out.map((r) => r.id), ['2']);
      },
    );
  });
}
