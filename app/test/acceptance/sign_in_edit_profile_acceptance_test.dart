import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/sign_in_screen.dart';
import 'package:nomnom_safe/screens/edit_profile_screen.dart';
import 'package:nomnom_safe/widgets/nomnom_appbar.dart';
import 'package:nomnom_safe/widgets/nomnom_scaffold.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/services/allergen_service.dart';

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

class _FakeAuthAdapter implements AuthAdapter {
  _FakeUserAdapter? _user;
  _FakeAuthAdapter([this._user]);
  @override
  UserAdapter? get currentUser => _user;
  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('newid', email: email);
    return {'user': _user};
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('signedin', email: email);
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class _FakeDocumentAdapter implements DocumentAdapter {
  final String id;
  Map<String, dynamic>? _data;
  _FakeDocumentAdapter(this.id, [this._data]);
  @override
  Future<void> delete() async => _data = null;
  @override
  Future<Map<String, dynamic>?> get() async => _data;
  @override
  Future<void> set(Map<String, dynamic> data) async => _data = data;
  @override
  Future<void> update(Map<String, dynamic> data) async =>
      _data = {...?_data, ...data};
}

class _FakeCollectionAdapter implements CollectionAdapter {
  final Map<String, _FakeDocumentAdapter> store = {};
  @override
  DocumentAdapter doc(String id) =>
      store.putIfAbsent(id, () => _FakeDocumentAdapter(id));
}

class _FakeFirestoreAdapter implements FirestoreAdapter {
  final Map<String, _FakeCollectionAdapter> cols = {};
  @override
  CollectionAdapter collection(String name) =>
      cols.putIfAbsent(name, () => _FakeCollectionAdapter());
}

class _FakeAllergenService extends AllergenService {
  _FakeAllergenService() : super(FakeFirebaseFirestore());
  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {};
  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {};
  @override
  Future<List<String>> idsToLabels(List<String> ids) async => [];
}

void main() {
  setUp(() {
    AuthService.clearInstanceForTests();
  });

  testWidgets('Sign in then edit profile updates name', (
    WidgetTester tester,
  ) async {
    final fakeAuth = _FakeAuthAdapter();
    final fakeFs = _FakeFirestoreAdapter();

    // prepare a user document that signIn will load
    await fakeFs.collection('users').doc('signedin').set({
      'first_name': 'Old',
      'last_name': 'Name',
      'email': 'a@b.com',
      'allergies': <String>[],
    });

    final service = AuthService(auth: fakeAuth, firestore: fakeFs);
    final provider = AuthStateProvider(service);

    // Pump SignInScreen and perform sign in like a real user
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthStateProvider>.value(
        value: provider,
        child: MaterialApp(home: Scaffold(body: SignInScreen())),
      ),
    );

    await tester.pumpAndSettle();

    // Fill email and password fields
    await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // provider should now have a currentUser
    expect(provider.currentUser, isNotNull);

    // Now open EditProfileScreen inside a scaffold and with controller injected
    final fakeAllergen = _FakeAllergenService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthStateProvider>.value(value: provider),
          Provider<AllergenService>.value(value: fakeAllergen),
        ],
        child: MaterialApp(
          home: NomNomScaffold(
            appBar: NomnomAppBar(),
            body: ChangeNotifierProvider<EditProfileController>(
              create: (context) => EditProfileController(
                authProvider: context.read<AuthStateProvider>(),
                allergenService: fakeAllergen,
              ),
              child: EditProfileScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Edit first name field
    await tester.enterText(find.byType(TextFormField).at(0), 'NewFirst');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // AuthService.loadCurrentUser should have refreshed currentUser through the provider
    expect(provider.currentUser?.firstName, 'NewFirst');
  });
}
