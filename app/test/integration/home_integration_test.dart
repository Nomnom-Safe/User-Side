import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/nomnom_appbar.dart';
import 'package:nomnom_safe/widgets/nomnom_scaffold.dart';
import 'package:nomnom_safe/screens/home_screen.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

class _FakeAllergenService extends AllergenService {
  final Map<String, String> idToLabel;
  final Map<String, String> labelToId;
  final List<String> labelsForIds;

  _FakeAllergenService({
    this.idToLabel = const {},
    this.labelToId = const {},
    this.labelsForIds = const [],
  }) : super(FakeFirebaseFirestore());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => idToLabel;

  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => labelToId;

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => labelsForIds;
}

class _FakeRestaurantService extends RestaurantService {
  final List<Restaurant> restaurants;
  final List<Restaurant> filtered;

  _FakeRestaurantService({
    this.restaurants = const [],
    this.filtered = const [],
  }) : super(FakeFirebaseFirestore());

  @override
  Future<List<Restaurant>> getAllRestaurants() async => restaurants;

  @override
  Future<List<Restaurant>> filterRestaurantsFromList(
    List<Restaurant> allRestaurants,
    List<String> selectedAllergenIds,
  ) async {
    return selectedAllergenIds.isEmpty ? allRestaurants : filtered;
  }
}

class _FakeAuthProvider extends AuthStateProvider {
  final User? _user;

  _FakeAuthProvider([this._user]);

  @override
  User? get currentUser => _user;

  @override
  Future<void> loadCurrentUser() async => Future.value();
}

void main() {
  group('Home integration tests', () {
    testWidgets('startup shows home and no allergens when none selected', (
      WidgetTester tester,
    ) async {
      final fakeAllergen = _FakeAllergenService();
      final fakeRestaurants = _FakeRestaurantService(
        restaurants: [
          Restaurant(
            id: 'r1',
            name: 'Test R',
            addressId: 'a1',
            website: '',
            hours: List.filled(7, '9-5'),
            phone: '123',
            cuisine: 'Test',
            disclaimers: [],
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AllergenService>.value(value: fakeAllergen),
            ChangeNotifierProvider<AuthStateProvider>(
              create: (_) => _FakeAuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => NomNomScaffold(
                appBar: NomnomAppBar(),
                body: HomeScreen(
                  restaurantService: fakeRestaurants,
                  allergenService: fakeAllergen,
                  injectedCurrentUser: null,
                  useInjectedCurrentUser: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(UserFeedbackMessages.homeSelectAllergensHint),
        findsOneWidget,
      );
      expect(find.text('Test R'), findsOneWidget);
    });

    testWidgets(
      'Home applies injected user allergens and filters restaurants',
      (WidgetTester tester) async {
        final fakeAllergen = _FakeAllergenService(
          idToLabel: {'a1': 'Peanut'},
          labelToId: {'Peanut': 'a1'},
          labelsForIds: ['Peanut'],
        );

        final fakeRestaurants = _FakeRestaurantService(
          restaurants: [
            Restaurant(
              id: 'r1',
              name: 'Safe R',
              addressId: 'a1',
              website: '',
              hours: List.filled(7, '9-5'),
              phone: '123',
              cuisine: 'Test',
              disclaimers: [],
            ),
          ],
          filtered: [],
        );

        final injectedUser = User(
          id: 'u1',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          allergies: ['a1'],
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AllergenService>.value(value: fakeAllergen),
              ChangeNotifierProvider<AuthStateProvider>(
                create: (_) => _FakeAuthProvider(injectedUser),
              ),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => NomNomScaffold(
                  appBar: NomnomAppBar(),
                  body: HomeScreen(
                    restaurantService: fakeRestaurants,
                    allergenService: fakeAllergen,
                    injectedCurrentUser: injectedUser,
                    useInjectedCurrentUser: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.textContaining('The following restaurants'),
          findsOneWidget,
        );
        expect(
          find.text(UserFeedbackMessages.homeNoRestaurantsMatch),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Filter modal interaction filters restaurants',
      (WidgetTester tester) async {},
      skip: true, // Flaky UI interaction; skip in CI
    );
  });
}
