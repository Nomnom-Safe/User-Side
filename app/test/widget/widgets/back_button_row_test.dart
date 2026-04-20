import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/back_button_row.dart';

void main() {
  testWidgets('BackButtonRow renders with back icon and tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BackButtonRow.home())),
    );

    final iconFinder = find.byIcon(Icons.arrow_back);
    final tooltipFinder = find.byTooltip('Back');

    expect(iconFinder, findsOneWidget);
    expect(tooltipFinder, findsOneWidget);
  });

  testWidgets('BackButtonRow.home custom tooltip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BackButtonRow.home(tooltipText: 'Back to Home')),
      ),
    );
    expect(find.byTooltip('Back to Home'), findsOneWidget);
  });
}
