import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/edit_profile_body.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/profile_update_result.dart';
import 'package:nomnom_safe/models/user.dart';

class _NoopAuth extends AuthStateProvider {
  _NoopAuth() : super();

  @override
  User? get currentUser => null;
}

class _NoopAllergen extends AllergenService {
  _NoopAllergen() : super(FakeFirebaseFirestore());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {};

  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {};

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => [];
}

class _FakeAuthProvider extends AuthStateProvider {
  _FakeAuthProvider() : super();

  @override
  User? get currentUser => null;

  @override
  Future<ProfileUpdateResult> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    return ProfileUpdateResult.ok();
  }

  @override
  Future<bool> verifyPassword(String password) async => true;

  @override
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async => null;
}

class _FakeAllergenService extends AllergenService {
  _FakeAllergenService() : super(FakeFirebaseFirestore());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {'a': 'A'};

  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {'A': 'a'};

  @override
  Future<List<String>> idsToLabels(List<String> ids) async =>
      ids.map((e) => 'A').toList();
}

void main() {
  testWidgets('EditProfileBody widget builds for edit profile state', (
    tester,
  ) async {
    final controller = EditProfileController(
      authProvider: _NoopAuth(),
      allergenService: _NoopAllergen(),
    );
    controller.viewState = ProfileViewState.editProfile;
    final formModel = ProfileFormModel(
      firstName: TextEditingController(),
      lastName: TextEditingController(),
      email: TextEditingController(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditProfileBody(controller: controller, formModel: formModel),
        ),
      ),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets(
    'EditProfileBody shows EditProfileView when controller is editProfile',
    (tester) async {
      final controller = EditProfileController(
        authProvider: _FakeAuthProvider(),
        allergenService: _FakeAllergenService() as dynamic,
      );
      controller.viewState = ProfileViewState.editProfile;
      final formModel = ProfileFormModel(
        firstName: TextEditingController(),
        lastName: TextEditingController(),
        email: TextEditingController(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfileBody(controller: controller, formModel: formModel),
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
    },
  );

  testWidgets(
    'EditProfileBody shows VerifyCurrentPasswordView when controller requests verify',
    (tester) async {
      final controller = EditProfileController(
        authProvider: _FakeAuthProvider(),
        allergenService: _FakeAllergenService() as dynamic,
      );
      controller.viewState = ProfileViewState.verifyCurrentPassword;
      final formModel = ProfileFormModel(
        firstName: TextEditingController(),
        lastName: TextEditingController(),
        email: TextEditingController(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfileBody(controller: controller, formModel: formModel),
          ),
        ),
      );

      expect(find.text('Enter Current Password'), findsOneWidget);
    },
  );

  testWidgets(
    'EditProfileBody shows UpdatePasswordView when controller requests update',
    (tester) async {
      final controller = EditProfileController(
        authProvider: _FakeAuthProvider(),
        allergenService: _FakeAllergenService() as dynamic,
      );
      controller.viewState = ProfileViewState.updatePassword;
      final formModel = ProfileFormModel(
        firstName: TextEditingController(),
        lastName: TextEditingController(),
        email: TextEditingController(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfileBody(controller: controller, formModel: formModel),
          ),
        ),
      );

      expect(find.text('Enter New Password'), findsOneWidget);
    },
  );
}
