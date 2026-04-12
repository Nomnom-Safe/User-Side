import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/screens/restaurant_screen.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/services/address_service.dart';
import 'package:nomnom_safe/services/allergen_service.dart';

class FakeAddressService implements AddressService {
  @override
  Future<String?> getRestaurantAddress(String addressId) async => '123 Test St';
}

class FakeAllergenService implements AllergenService {
  @override
  void clearCache() {}
  @override
  Future<List<Allergen>> getAllergens() async => [];
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
  Future<String?> getIdForLabel(String label) async => null;
  @override
  Future<String?> getLabelForId(String id) async => null;
}

Restaurant _makeRestaurant() => Restaurant(
  id: 'r1',
  name: 'Testaurant',
  addressId: 'addr1',
  website: '',
  hours: List.generate(7, (i) => 'Hours $i'),
  phone: '555-0000',
  cuisine: 'Test',
  disclaimers: [],
);

void main() {
  testWidgets('RestaurantScreen shows name and loading address', (
    tester,
  ) async {
    final r = _makeRestaurant();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantScreen(
            restaurant: r,
            addressService: FakeAddressService(),
            allergenService: FakeAllergenService(),
          ),
        ),
      ),
    );

    expect(find.text('Testaurant'), findsOneWidget);
    expect(find.textContaining('Address:'), findsOneWidget);
    expect(find.textContaining('Loading'), findsOneWidget);
  });
}
