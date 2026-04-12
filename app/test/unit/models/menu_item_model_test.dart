import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/menu_item.dart';

void main() {
  test('MenuItem.fromJson and toJson', () {
    final data = {
      'id': 'mi1',
      'name': 'Item 1',
      'description': 'Desc',
      'allergens': <String>[],
      'menu_id': 'm1',
      'ingredients': 'flour, sugar',
    };

    final item = MenuItem.fromJson(data);
    expect(item.id, 'mi1');
    expect(item.menuId, 'm1');
    expect(item.ingredients, 'flour, sugar');
    expect(item.hasIngredients, true);
    final json = item.toJson();
    expect(json['menu_id'], 'm1');
    expect(json['name'], 'Item 1');
    expect(json['ingredients'], 'flour, sugar');
  });

  test('MenuItem.fromJson reads allergens key and handles missing values', () {
    final jsonWithAllergens = {
      'id': 'mi1',
      'name': 'Item1',
      'description': 'desc',
      'allergens': ['a1', 'a2'],
      'menu_id': 'm1',
    };

    final item = MenuItem.fromJson(
      Map<String, dynamic>.from(jsonWithAllergens),
    );
    expect(item.allergens, isA<List<String>>());
    expect(item.allergens.length, equals(2));
    expect(item.allergens, containsAll(['a1', 'a2']));

    // The model requires an 'allergens' list; provide an empty list to test that case.
    final jsonWithEmptyAllergens = {
      'id': 'mi2',
      'name': 'Item2',
      'description': 'desc',
      'allergens': <String>[],
      'menu_id': 'm1',
    };

    final item2 = MenuItem.fromJson(
      Map<String, dynamic>.from(jsonWithEmptyAllergens),
    );
    expect(item2.allergens, isA<List<String>>());
    expect(item2.allergens, isEmpty);
  });

  test('MenuItem.fromJson handles missing ingredients', () {
    final data = {
      'id': 'mi3',
      'name': 'Item 3',
      'description': 'Desc',
      'allergens': <String>[],
      'menu_id': 'm1',
    };
    final item = MenuItem.fromJson(data);
    expect(item.ingredients, '');
    expect(item.hasIngredients, false);
  });
}
