import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/views/edit_profile_body.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/models/profile_update_result.dart';

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

class _FakeAuthProvider extends AuthStateProvider {
  bool updateProfileCalled = false;

  _FakeAuthProvider(User user) : super() {
    _user = user;
  }
  User? _user;
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
    updateProfileCalled = true;
    return ProfileUpdateResult.ok();
  }

  @override
  Future<bool> verifyPassword(String currentPassword) async {
    return true;
  }

  @override
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    return null;
  }
}

void main() {
  testWidgets('EditProfileBody shows fields and reacts to controller', (
    WidgetTester tester,
  ) async {
    final user = User(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.com',
      allergies: ['a1'],
    );

    // create a controller with fake allergen service
    final allergen = _FakeAllergenService(
      idToLabel: {'a1': 'Peanut'},
      labelToId: {'Peanut': 'a1'},
      labelsForIds: ['Peanut'],
    );

    // Provide a typed auth provider that returns the user
    final fakeAuth = _FakeAuthProvider(user);
    final controller = EditProfileController(
      authProvider: fakeAuth,
      allergenService: allergen,
    );
    final formModel = ProfileFormModel.fromUser(user);

    await tester.pumpWidget(
      ChangeNotifierProvider<EditProfileController>.value(
        value: controller,
        child: MaterialApp(
          home: Scaffold(
            body: EditProfileBody(controller: controller, formModel: formModel),
          ),
        ),
      ),
    );

    // allow async init
    await tester.pumpAndSettle();

    // should show first/last name and email fields
    expect(find.byKey(const Key('firstNameField')), findsOneWidget);
    expect(find.byKey(const Key('lastNameField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);

    // enter text
    await tester.enterText(
      find.byKey(const Key('firstNameField')),
      user.firstName,
    );
    await tester.enterText(
      find.byKey(const Key('lastNameField')),
      user.lastName,
    );
    await tester.enterText(find.byKey(const Key('emailField')), user.email);

    // call saveChanges directly
    await controller.saveChanges(
      firstName: 'Anna',
      lastName: 'Smith',
      email: 'anna@example.com',
      password: 'pw',
      confirmPassword: 'pw',
    );

    // assert provider was called
    expect(fakeAuth.updateProfileCalled, isTrue);
    expect(controller.errorMessage, isNull);
  });
}
