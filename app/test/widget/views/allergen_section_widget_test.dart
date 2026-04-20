import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/allergen_section.dart';

import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
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

class FakeProfileController extends ProfileController {
  FakeProfileController({
    bool isLoadingAllergens = false,
    String? allergenError,
    Set<String>? selectedAllergenLabels,
  }) : super(authProvider: _NoopAuth(), allergenService: _NoopAllergen()) {
    this.isLoadingAllergens = isLoadingAllergens;
    this.allergenError = allergenError;
    this.selectedAllergenLabels = selectedAllergenLabels ?? {};
  }

  @override
  Future<void> fetchAllergens() async {
    // no-op
  }
}

void main() {
  testWidgets('AllergenSection widget shows no selection text', (tester) async {
    final c = FakeProfileController(
      isLoadingAllergens: false,
      selectedAllergenLabels: {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AllergenSection(controller: c)),
      ),
    );

    expect(find.text('No allergens selected'), findsOneWidget);
  });

  testWidgets('AllergenSection shows loading indicator when loading', (
    tester,
  ) async {
    final c = FakeProfileController(isLoadingAllergens: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AllergenSection(controller: c)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AllergenSection shows error and retry when error', (
    tester,
  ) async {
    final c = FakeProfileController(
      isLoadingAllergens: false,
      allergenError: 'Boom',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AllergenSection(controller: c)),
      ),
    );

    expect(find.text('Boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('AllergenSection shows placeholder when none selected', (
    tester,
  ) async {
    final c = FakeProfileController(
      isLoadingAllergens: false,
      selectedAllergenLabels: {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AllergenSection(controller: c)),
      ),
    );

    expect(find.text('No allergens selected'), findsOneWidget);
  });

  testWidgets('AllergenSection displays chips for selected labels', (
    tester,
  ) async {
    final c = FakeProfileController(
      isLoadingAllergens: false,
      selectedAllergenLabels: {'Peanuts', 'Dairy'},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AllergenSection(controller: c)),
      ),
    );

    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.text('Peanuts'), findsOneWidget);
    expect(find.text('Dairy'), findsOneWidget);
  });
}
