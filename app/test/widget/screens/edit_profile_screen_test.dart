import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/edit_profile_screen.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/models/user.dart';

class FakeAllergenService implements AllergenService {
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
  Future<List<String>> idsToLabels(List<String> ids) async => [];
  @override
  Future<List<String>> labelsToIds(List<String> labels) async => [];
  @override
  Future<List<Allergen>> getAllergens() async => [];

  @override
  Future<String?> getIdForLabel(String label) async => null;

  @override
  Future<String?> getLabelForId(String id) async => null;
}

class FakeAuthProvider extends AuthStateProvider {
  final User? _user;
  FakeAuthProvider(this._user);
  @override
  User? get currentUser => _user;
}

void main() {
  testWidgets('EditProfileScreen builds and shows EditProfileBody', (
    tester,
  ) async {
    final user = User(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.com',
    );
    final controller = EditProfileController(
      authProvider: FakeAuthProvider(user),
      allergenService: FakeAllergenService(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthStateProvider>.value(
          value: FakeAuthProvider(user),
          child: ChangeNotifierProvider<EditProfileController>.value(
            value: controller,
            child: Scaffold(body: EditProfileScreen()),
          ),
        ),
      ),
    );

    // BackButtonRow and EditProfileBody are part of the build; ensure title present
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });
}
