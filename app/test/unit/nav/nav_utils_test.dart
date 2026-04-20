import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

void main() {
  testWidgets(
    'navigateIfNotCurrent pushes when target different from current',
    (tester) async {
      BuildContext? captured;
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.home,
          routes: {
            AppRoutes.home: (context) => Builder(
              builder: (context) {
                captured = context;
                return Scaffold(body: Center(child: Text('HOME')));
              },
            ),
            AppRoutes.menu: (context) =>
                Scaffold(body: Center(child: Text('MENU'))),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Ensure captured context is available
      expect(captured, isNotNull);

      // Navigate to menu
      navigateIfNotCurrent(captured!, AppRoutes.menu);
      await tester.pumpAndSettle();

      expect(find.text('MENU'), findsOneWidget);
    },
  );

  testWidgets('navigateIfNotCurrent does not push when target equals current', (
    tester,
  ) async {
    BuildContext? captured;
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => Builder(
            builder: (context) {
              captured = context;
              return Scaffold(body: Center(child: Text('HOME')));
            },
          ),
          AppRoutes.menu: (context) =>
              Scaffold(body: Center(child: Text('MENU'))),
        },
      ),
    );

    await tester.pumpAndSettle();

    // Try navigating to same route
    navigateIfNotCurrent(captured!, AppRoutes.home);
    await tester.pumpAndSettle();

    // Still on home
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('MENU'), findsNothing);
  });

  testWidgets('navigateIfNotCurrent respects blockIfCurrent', (tester) async {
    BuildContext? captured;
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => Builder(
            builder: (context) {
              captured = context;
              return Scaffold(body: Center(child: Text('HOME')));
            },
          ),
          AppRoutes.menu: (context) =>
              Scaffold(body: Center(child: Text('MENU'))),
        },
      ),
    );

    await tester.pumpAndSettle();

    // block navigation when current route is home
    navigateIfNotCurrent(
      captured!,
      AppRoutes.menu,
      blockIfCurrent: [AppRoutes.home],
    );
    await tester.pumpAndSettle();

    expect(find.text('MENU'), findsNothing);
  });

  testWidgets('replaceIfNotCurrent replaces when target different', (
    tester,
  ) async {
    BuildContext? captured;
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => Builder(
            builder: (context) {
              captured = context;
              return Scaffold(body: Center(child: Text('HOME')));
            },
          ),
          AppRoutes.menu: (context) =>
              Scaffold(body: Center(child: Text('MENU'))),
        },
      ),
    );

    await tester.pumpAndSettle();
    replaceIfNotCurrent(captured!, AppRoutes.menu);
    await tester.pumpAndSettle();

    // menu is displayed
    expect(find.text('MENU'), findsOneWidget);

    // HOME should no longer be in the widget tree because it was replaced
    expect(find.text('HOME'), findsNothing);
  });

  test('getNavIndexForRoute returns correct indices and defaults to 0', () {
    expect(getNavIndexForRoute(AppRoutes.home), 0);
    expect(getNavIndexForRoute(AppRoutes.profile), 1);
    expect(getNavIndexForRoute(AppRoutes.editProfile), 1);
    expect(getNavIndexForRoute('/unknown-route'), 0);
    expect(getNavIndexForRoute(null), 0);
  });
}
