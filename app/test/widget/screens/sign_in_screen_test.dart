import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/screens/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen shows title and inline validation on submit', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignInScreen())));

    expect(find.text('Welcome Back'), findsOneWidget);

    // Tap the Sign In button without filling inputs to trigger validation
    await tester.tap(find.text('Sign In'));
    await tester.pump(); // start validation

    expect(find.text('Email is required'), findsOneWidget);
  });
}
