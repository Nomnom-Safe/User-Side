import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';

class _FakeAuthProvider extends AuthStateProvider {
  User? _user;
  bool loadCalled = false;
  bool throwOnLoad = false;
  bool throwOnDelete = false;

  _FakeAuthProvider([this._user]);

  @override
  User? get currentUser => _user;

  @override
  Future<void> loadCurrentUser() async {
    loadCalled = true;
    if (throwOnLoad) throw Exception('load failed');
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    if (throwOnDelete) throw Exception('delete failed');
    return;
  }
}

class _FakeAllergenService extends AllergenService {
  final Map<String, String>? idToLabel;
  final List<String> labels;
  final bool shouldThrow;

  _FakeAllergenService({
    this.idToLabel,
    this.labels = const [],
    this.shouldThrow = false,
  }) : super(FakeFirebaseFirestore());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async {
    if (shouldThrow) throw Exception('boom');
    return idToLabel ?? {};
  }

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => labels;
}

void main() {
  group('ProfileController', () {
    test('fetchAllergens succeeds and fills maps', () async {
      final user = User(
        id: 'u1',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        allergies: ['a1'],
      );

      final auth = _FakeAuthProvider(user);
      final allergen = _FakeAllergenService(
        idToLabel: {'a1': 'Peanut'},
        labels: ['Peanut'],
      );

      final controller = ProfileController(
        authProvider: auth,
        allergenService: allergen,
      );

      // wait for constructor-triggered fetch
      await Future.delayed(Duration.zero);

      expect(controller.isLoadingAllergens, isFalse);
      expect(controller.allergenIdToLabel['a1'], 'Peanut');
      expect(controller.selectedAllergenLabels.contains('Peanut'), isTrue);
    });

    test('fetchAllergens failure sets error', () async {
      final auth = _FakeAuthProvider(null);
      final allergen = _FakeAllergenService(shouldThrow: true);

      final controller = ProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      expect(controller.isLoadingAllergens, isFalse);
      expect(controller.allergenError, isNotNull);
    });

    test('refreshUser reloads and optionally refetches allergens', () async {
      final user = User(
        id: 'u1',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        allergies: [],
      );
      final auth = _FakeAuthProvider(user);
      final allergen = _FakeAllergenService(idToLabel: {});

      final controller = ProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      final ok = await controller.refreshUser(reloadAllergens: false);
      expect(ok, isTrue);
      expect(auth.loadCalled, isTrue);

      auth.loadCalled = false;
      final ok2 = await controller.refreshUser(reloadAllergens: true);
      expect(ok2, isTrue);
      expect(auth.loadCalled, isTrue);
    });

    test(
      'deleteAccount returns true on success and false on exception',
      () async {
        final auth = _FakeAuthProvider(null);
        final allergen = _FakeAllergenService(idToLabel: {});
        final controller = ProfileController(
          authProvider: auth,
          allergenService: allergen,
        );

        final ok = await controller.deleteAccount('p');
        expect(ok, isTrue);

        auth.throwOnDelete = true;
        final ok2 = await controller.deleteAccount('p');
        expect(ok2, isFalse);
      },
    );
  });
}
