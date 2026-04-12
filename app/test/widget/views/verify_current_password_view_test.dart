import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/verify_current_password_view.dart';

void main() {
  testWidgets('VerifyCurrentPasswordView renders and toggles loading', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerifyCurrentPasswordView(
            controller: controller,
            isVisible: false,
            onToggleVisibility: () {},
            onContinue: () async {},
            isLoading: false,
          ),
        ),
      ),
    );

    expect(find.text('Enter Current Password'), findsOneWidget);
    // PasswordField is required so label renders with a trailing '*'
    expect(find.text('Current Password *'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Rebuild with loading true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerifyCurrentPasswordView(
            controller: controller,
            isVisible: false,
            onToggleVisibility: () {},
            onContinue: () async {},
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
