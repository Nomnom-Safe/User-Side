import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/home_screen.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/allergen.dart';

class FakeAllergenService implements AllergenService {
  FakeAllergenService();
  @override
  void clearCache() {}
  @override
  Future<List<String>> getAllergenLabels() async => [];
  @override
  Future<List<String>> getAllergenIds() async => [];
  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {};
  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {};
  @override
  Future<List<String>> idsToLabels(List<String> ids) async =>
      ids.map((e) => e).toList();
  @override
  Future<List<String>> labelsToIds(List<String> labels) async =>
      labels.map((e) => e).toList();
  @override
  Future<List<Allergen>> getAllergens() async => [];

  @override
  Future<String?> getIdForLabel(String label) async => null;

  @override
  Future<String?> getLabelForId(String id) async => null;
}

class FakeRestaurantService implements RestaurantService {
  @override
  Future<List<Restaurant>> getAllRestaurants() async => [];

  @override
  Future<List<Restaurant>> filterRestaurantsFromList(
    List<Restaurant> allRestaurants,
    List<String> selectedAllergenIds,
  ) async {
    return allRestaurants;
  }
}

void main() {
  testWidgets('HomeScreen shows initial loading spinners', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<AllergenService>.value(
          value: FakeAllergenService(),
          child: Scaffold(
            body: HomeScreen(
              restaurantService: FakeRestaurantService(),
              useInjectedCurrentUser: true,
              injectedCurrentUser: null,
            ),
          ),
        ),
      ),
    );

    // Initially, allergens and restaurants are loading so expect progress indicators
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
