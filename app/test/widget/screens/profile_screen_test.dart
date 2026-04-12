import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/profile_screen.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
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
  User? _user;
  FakeAuthProvider([this._user]);
  @override
  User? get currentUser => _user;
}

void main() {
  testWidgets('ProfileScreen prompts to sign in when no user', (tester) async {
    final controller = ProfileController(
      authProvider: FakeAuthProvider(null),
      allergenService: FakeAllergenService(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthStateProvider>.value(
          value: FakeAuthProvider(null),
          child: ChangeNotifierProvider<ProfileController>.value(
            value: controller,
            child: Scaffold(body: ProfileScreen()),
          ),
        ),
      ),
    );

    expect(find.text('Please sign in to view your profile.'), findsOneWidget);
  });

  testWidgets('ProfileScreen shows user info when present', (tester) async {
    final user = User(
      id: 'u1',
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.com',
    );
    final controller = ProfileController(
      authProvider: FakeAuthProvider(user),
      allergenService: FakeAllergenService(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthStateProvider>.value(
          value: FakeAuthProvider(user),
          child: ChangeNotifierProvider<ProfileController>.value(
            value: controller,
            child: Scaffold(body: ProfileScreen()),
          ),
        ),
      ),
    );

    expect(find.text(user.email), findsOneWidget);
    expect(find.text(user.fullName), findsOneWidget);
  });
}
