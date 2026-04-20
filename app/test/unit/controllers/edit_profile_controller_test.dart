import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/models/profile_update_result.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';

class _FakeAuthProvider extends AuthStateProvider {
  User? _user;
  ProfileUpdateResult? updateProfileResult;
  bool verifyPasswordResult = false;
  String? updatePasswordResult;

  _FakeAuthProvider([this._user]);

  @override
  User? get currentUser => _user;

  @override
  Future<ProfileUpdateResult> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    return updateProfileResult ?? ProfileUpdateResult.ok();
  }

  @override
  Future<bool> verifyPassword(String password) async => verifyPasswordResult;

  @override
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    return updatePasswordResult;
  }
}

class _FakeAllergenService extends AllergenService {
  final Map<String, String> idToLabel;
  final Map<String, String> labelToId;
  final List<String> labelsForIds;

  _FakeAllergenService({
    required this.idToLabel,
    required this.labelToId,
    required this.labelsForIds,
  }) : super(FakeFirebaseFirestore());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => idToLabel;

  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => labelToId;

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => labelsForIds;
}

void main() {
  group('EditProfileController', () {
    test('initializes selected allergens and maps from services', () async {
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
        labelToId: {'Peanut': 'a1'},
        labelsForIds: ['Peanut'],
      );

      final controller = EditProfileController(
        authProvider: auth,
        allergenService: allergen,
      );

      // wait for async init in constructor
      await Future.delayed(Duration.zero);

      expect(controller.selectedAllergenIds.contains('a1'), isTrue);
      expect(controller.allergenIdToLabel['a1'], 'Peanut');
      expect(controller.allergenLabelToId['Peanut'], 'a1');
      expect(controller.isLoadingAllergens, isFalse);
    });

    test('toggleAllergen adds and removes by label', () async {
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
        labelToId: {'Peanut': 'a1'},
        labelsForIds: ['Peanut'],
      );

      final controller = EditProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      controller.toggleAllergen('Peanut', false);
      expect(controller.selectedAllergenIds.contains('a1'), isFalse);

      controller.toggleAllergen('Peanut', true);
      expect(controller.selectedAllergenIds.contains('a1'), isTrue);
    });

    test('saveChanges sets errorMessage from provider', () async {
      final user = User(
        id: 'u1',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        allergies: [],
      );
      final auth = _FakeAuthProvider(user);
      auth.updateProfileResult = ProfileUpdateResult.failure('some error');

      final allergen = _FakeAllergenService(
        idToLabel: {},
        labelToId: {},
        labelsForIds: [],
      );

      final controller = EditProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      await controller.saveChanges(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        password: 'p',
        confirmPassword: 'p',
      );

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, 'some error');
    });

    test(
      'verifyCurrentPassword updates viewState on success/failure',
      () async {
        final user = User(
          id: 'u1',
          firstName: 'A',
          lastName: 'B',
          email: 'a@b.com',
          allergies: [],
        );
        final auth = _FakeAuthProvider(user);
        final allergen = _FakeAllergenService(
          idToLabel: {},
          labelToId: {},
          labelsForIds: [],
        );

        final controller = EditProfileController(
          authProvider: auth,
          allergenService: allergen,
        );
        await Future.delayed(Duration.zero);

        auth.verifyPasswordResult = false;
        await controller.verifyCurrentPassword('bad');
        expect(controller.viewState, ProfileViewState.verifyCurrentPassword);
        expect(controller.errorMessage, 'Incorrect password');

        auth.verifyPasswordResult = true;
        await controller.verifyCurrentPassword('good');
        expect(controller.viewState, ProfileViewState.updatePassword);
        expect(controller.errorMessage, isNull);
      },
    );

    test('updatePassword sets viewState to editProfile on success', () async {
      final user = User(
        id: 'u1',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        allergies: [],
      );
      final auth = _FakeAuthProvider(user);
      final allergen = _FakeAllergenService(
        idToLabel: {},
        labelToId: {},
        labelsForIds: [],
      );

      final controller = EditProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      // simulate that user is on the update password view
      controller.viewState = ProfileViewState.updatePassword;

      auth.updatePasswordResult = 'bad';
      await controller.updatePassword(newPassword: 'x', confirmPassword: 'x');
      // on error the view should remain on updatePassword
      expect(controller.viewState, ProfileViewState.updatePassword);
      expect(controller.errorMessage, 'bad');

      auth.updatePasswordResult = null;
      await controller.updatePassword(newPassword: 'x', confirmPassword: 'x');
      // success should move back to edit profile
      expect(controller.viewState, ProfileViewState.editProfile);
    });

    test('togglePasswordVisibility and view transitions', () async {
      final user = User(
        id: 'u1',
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        allergies: [],
      );
      final auth = _FakeAuthProvider(user);
      final allergen = _FakeAllergenService(
        idToLabel: {},
        labelToId: {},
        labelsForIds: [],
      );

      final controller = EditProfileController(
        authProvider: auth,
        allergenService: allergen,
      );
      await Future.delayed(Duration.zero);

      expect(controller.arePasswordsVisible, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.arePasswordsVisible, isTrue);

      controller.goToVerifyPassword();
      expect(controller.viewState, ProfileViewState.verifyCurrentPassword);

      controller.goBackToEditProfile();
      expect(controller.viewState, ProfileViewState.editProfile);
    });
  });
}
