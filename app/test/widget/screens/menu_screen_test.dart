import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/screens/menu_screen.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/menu.dart';
import 'package:nomnom_safe/models/menu_item.dart';
import 'package:nomnom_safe/services/menu_service.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';

class FakeAllergenService implements AllergenService {
  @override
  Future<List<String>> getAllergenLabels() async => [];
  @override
  Future<List<String>> getAllergenIds() async => [];
  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {};
  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {};
  @override
  Future<List<String>> idsToLabels(List<String> ids) async => [];
  @override
  Future<List<String>> labelsToIds(List<String> labels) async => [];
  @override
  Future<List<Allergen>> getAllergens() async => [];
  @override
  Future<String?> getIdForLabel(String label) async => null;
  @override
  Future<String?> getLabelForId(String id) async => null;
}

class FakeMenuService implements MenuService {
  @override
  Future<List<MenuItem>> getMenuItems(String menuId) async => [];

  @override
  Future<Menu?> getMenuByRestaurantId(String restaurantId) async => null;
}

Restaurant _makeRestaurant() => Restaurant(
  id: 'r1',
  name: 'MenuPlace',
  addressId: 'addr1',
  website: '',
  hours: List.generate(7, (i) => 'H$i'),
  phone: '',
  cuisine: 'Test',
  disclaimers: [],
);

void main() {
  testWidgets('MenuScreen shows restaurant name and loading indicator', (
    tester,
  ) async {
    final r = _makeRestaurant();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuScreen(
            restaurant: r,
            menuService: FakeMenuService(),
            allergenService: FakeAllergenService(),
          ),
        ),
      ),
    );

    expect(find.text('MenuPlace'), findsOneWidget);
    // menu loads async; initial state should show progress indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
