import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/home_screen.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

class _FakeAllergenService implements AllergenService {
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
  Future<String?> getLabelForId(String id) async => null;

  @override
  Future<String?> getIdForLabel(String label) async => null;

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => [];

  @override
  Future<List<String>> labelsToIds(List<String> labels) async => [];
}

class _FakeRestaurantService implements RestaurantService {
  @override
  Future<List<Restaurant>> getAllRestaurants() async => <Restaurant>[];

  @override
  Future<List<Restaurant>> filterRestaurantsFromList(
    List<Restaurant> allRestaurants,
    List<String> selectedAllergenIds,
  ) async {
    return allRestaurants;
  }
}

void main() {
  testWidgets('HomeScreen builds with injected fakes', (tester) async {
    final fakeAllergens = _FakeAllergenService();
    final fakeRestaurants = _FakeRestaurantService();

    final testUser = User(
      id: 'u1',
      firstName: 'Test',
      lastName: 'User',
      email: 't@example.com',
      allergies: [],
    );

    await tester.pumpWidget(
      Provider<AllergenService>.value(
        value: fakeAllergens,
        child: MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              restaurantService: fakeRestaurants,
              injectedCurrentUser: testUser,
              useInjectedCurrentUser: true,
            ),
          ),
        ),
      ),
    );

    // let async initializers settle
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    // With no allergens selected and empty restaurants, the text should be present
    expect(
      find.text(UserFeedbackMessages.homeSelectAllergensHint),
      findsOneWidget,
    );
  });
}
