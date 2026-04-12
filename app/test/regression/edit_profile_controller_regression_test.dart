import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';

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
  @override
  UserAdapter? get currentUser => _user;

  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('u_edit', email: email);
    return {'user': _user};
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('u_edit', email: email);
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

void main() {
  setUp(() {
    AuthService.clearInstanceForTests();
  });

  test(
    'EditProfileController.saveChanges calls provider.updateProfile and persists',
    () async {
      final fakeAuth = _FakeAuthAdapter();
      final fakeFs = _FakeFirestoreAdapter();

      await fakeFs.collection('users').doc('u_edit').set({
        'first_name': 'Before',
        'last_name': 'Tester',
        'email': 'before@example.com',
        'allergies': [],
      });

      final service = AuthService(auth: fakeAuth, firestore: fakeFs);
      await service.signIn(email: 'before@example.com', password: 'password');

      final provider = AuthStateProvider(service);

      final fakeAllergens = _FakeAllergenService();
      final controller = EditProfileController(
        authProvider: provider,
        allergenService: fakeAllergens,
      );

      await controller.saveChanges(
        firstName: 'After',
        lastName: 'Tester',
        email: 'before@example.com',
        password: '',
        confirmPassword: '',
      );

      expect(provider.currentUser?.firstName, 'After');
      final doc = await fakeFs.collection('users').doc('u_edit').get();
      expect(doc, isNotNull);
      expect(doc!['first_name'], 'After');
    },
  );
}
