import 'package:flutter/material.dart';
import 'package:nomnom_safe/nav/nav_destination.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

void navigateIfNotCurrent(
  BuildContext context,
  String targetRoute, {
  Object? arguments,
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(context).pushNamed(targetRoute, arguments: arguments);
  }
}

void replaceIfNotCurrent(
  BuildContext context,
  String targetRoute, {
  Object? arguments,
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(
      context,
    ).pushReplacementNamed(targetRoute, arguments: arguments);
  }
}

int getNavIndexForRoute(String? routeName) {
  if (routeName == AppRoutes.editProfile) {
    return bottomNavDestinations.indexWhere(
      (d) => d.route == AppRoutes.profile,
    );
  }
  final index = bottomNavDestinations.indexWhere((d) => d.route == routeName);
  return index >= 0 ? index : 0;
}
