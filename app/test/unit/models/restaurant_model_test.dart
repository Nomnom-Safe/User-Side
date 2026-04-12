import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/restaurant.dart';

void main() {
  test('Restaurant.fromJson and helpers', () {
    final data = {
      'id': 'r1',
      'name': 'R1',
      'address_id': 'addr1',
      'website': 'http://t',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': 'p',
      'cuisine': 'c',
      'disclaimers': [],
      'logoUrl': null,
      'menu_id': 'menu1',
      'allergens': ['a1'],
      'diets': ['d1'],
    };
    final r = Restaurant.fromJson(data);
    expect(r.id, 'r1');
    expect(r.hasWebsite, true);
    expect(r.todayHours, isNotNull);
    expect(r.menuId, 'menu1');
    expect(r.allergens, ['a1']);
    expect(r.diets, ['d1']);
  });

  test('Restaurant.toJson uses address_id key', () {
    final r = Restaurant(
      id: 'r1',
      name: 'R1',
      addressId: 'addr1',
      website: '',
      hours: [],
      phone: '',
      cuisine: '',
      disclaimers: [],
      menuId: 'menu1',
    );
    final json = r.toJson();
    expect(json['address_id'], 'addr1');
    expect(json.containsKey('address'), false);
    expect(json['menu_id'], 'menu1');
  });

  test('Restaurant.todayHours handles empty hours', () {
    final r = Restaurant(
      id: 'r1',
      name: 'R1',
      addressId: '',
      website: '',
      hours: [],
      phone: '',
      cuisine: '',
      disclaimers: [],
    );
    expect(r.todayHours, Restaurant.unavailableDisplay);
  });

  test('display fields use unavailableDisplay when empty', () {
    final r = Restaurant(
      id: 'r1',
      name: '',
      addressId: '',
      website: '',
      hours: ['', 'Mon', '', '', '', '', ''],
      phone: '  ',
      cuisine: '',
      disclaimers: [],
    );
    expect(r.displayName, Restaurant.unavailableDisplay);
    expect(r.displayCuisine, Restaurant.unavailableDisplay);
    expect(r.displayPhone, Restaurant.unavailableDisplay);
    expect(r.displayHourLines, [
      Restaurant.unavailableDisplay,
      'Mon',
      Restaurant.unavailableDisplay,
      Restaurant.unavailableDisplay,
      Restaurant.unavailableDisplay,
      Restaurant.unavailableDisplay,
      Restaurant.unavailableDisplay,
    ]);
  });

  test('todayHours is unavailable when today line is blank (any weekday)', () {
    final r = Restaurant(
      id: 'r1',
      name: 'N',
      addressId: '',
      website: '',
      hours: List.filled(7, ''),
      phone: '',
      cuisine: '',
      disclaimers: [],
    );
    expect(r.todayHours, Restaurant.unavailableDisplay);
  });

  test('displayName maps JSON Unknown sentinel to unavailableDisplay', () {
    final r = Restaurant.fromJson({
      'id': 'r1',
      'name': 'Unknown',
      'address_id': 'a',
    });
    expect(r.displayName, Restaurant.unavailableDisplay);
  });

  test('Restaurant.fromJson handles missing optional fields', () {
    final data = <String, dynamic>{
      'id': 'r2',
      'name': 'R2',
      'address_id': 'addr2',
    };
    final r = Restaurant.fromJson(data);
    expect(r.menuId, '');
    expect(r.allergens, isEmpty);
    expect(r.diets, isEmpty);
    expect(r.hours, isEmpty);
    expect(r.disclaimers, isEmpty);
  });
}
