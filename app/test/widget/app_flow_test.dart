import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/widgets/nomnom_appbar.dart';
import 'package:nomnom_safe/widgets/nomnom_scaffold.dart';
import 'package:nomnom_safe/screens/home_screen.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';
import 'package:nomnom_safe/services/auth_service.dart';

class _FakeAllergenService extends AllergenService {
  final Map<String, String> idToLabel;
  final Map<String, String> labelToId;
  final List<String> labelsForIds;

  _FakeAllergenService({
    this.idToLabel = const {},
    this.labelToId = const {},
    this.labelsForIds = const [],
  }) : super({});

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
  }) : super({});

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

class _FakeFirestoreAdapter implements FirestoreAdapter {
  @override
  CollectionAdapter collection(String name) => _FakeCollectionAdapter();
}

class _FakeCollectionAdapter implements CollectionAdapter {
  @override
  DocumentAdapter doc(String id) => _FakeDocumentAdapter(id);
}

class _FakeDocumentAdapter implements DocumentAdapter {
  final String id;
  Map<String, dynamic>? _data;
  _FakeDocumentAdapter(this.id);

  @override
  Future<Map<String, dynamic>?> get() async => _data;
  @override
  Future<void> set(Map<String, dynamic> data) async => _data = data;
  @override
  Future<void> update(Map<String, dynamic> data) async =>
      _data = {...?_data, ...data};
  @override
  Future<void> delete() async => _data = null;
}

class _FakeAuthAdapter implements AuthAdapter {
  UserAdapter? _user;

  @override
  UserAdapter? get currentUser => _user;

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('u1', email: email);
  }

  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('u2', email: email);
    return {'user': _user};
  }

  // Add other methods as no‑ops if needed
}

class _FakeUserAdapter implements UserAdapter {
  final String uid;
  final String? email;
  _FakeUserAdapter(this.uid, {this.email});

  @override
  Future<void> delete() async {}
  @override
  Future<void> reauthenticateWithCredential(dynamic credential) async {}
  @override
  Future<void> updatePassword(String password) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String email) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fakeAuth = _FakeAuthAdapter();
  final fakeFirestore = _FakeFirestoreAdapter();
  final fakeAuthService = AuthService(auth: fakeAuth, firestore: fakeFirestore);

  testWidgets('App startup shows home and no allergens when none selected', (
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
            create: (_) => AuthStateProvider(fakeAuthService),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')), // replace NomNomAppBar
            body: HomeScreen(
              restaurantService: fakeRestaurants,
              allergenService: fakeAllergen,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No allergens selected.'), findsOneWidget);
    expect(find.text('Test R'), findsOneWidget);
  });

  testWidgets('Home applies injected user allergens and filters restaurants', (
    WidgetTester tester,
  ) async {
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
      filtered: [], // filter removes restaurants when allergen selected
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
            create: (_) => AuthStateProvider(fakeAuthService),
          ),
        ],
        child: MaterialApp(
          home: NomNomScaffold(
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
    );

    await tester.pumpAndSettle();

    // When user has allergens selected, a descriptive header is shown
    expect(find.textContaining('The following restaurants'), findsOneWidget);
    // Filtered result is empty -> message indicating no restaurants
    expect(find.text('No restaurants match your filters.'), findsOneWidget);
  });
}
