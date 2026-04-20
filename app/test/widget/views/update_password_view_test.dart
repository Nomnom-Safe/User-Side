import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/update_password_view.dart';

void main() {
  testWidgets('UpdatePasswordView shows fields and buttons', (tester) async {
    final formKey = GlobalKey<FormState>();
    final newPass = TextEditingController();
    final confPass = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpdatePasswordView(
            formKey: formKey,
            newPasswordController: newPass,
            confirmPasswordController: confPass,
            isVisible: false,
            onToggleVisibility: () {},
            onBack: () {},
            onSubmit: () async {},
            isLoading: false,
          ),
        ),
      ),
    );

    expect(find.text('Enter New Password'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
  });
}
