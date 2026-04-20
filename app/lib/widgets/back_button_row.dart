import 'package:flutter/material.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

/// Back navigation using [replaceIfNotCurrent] (`docs/demo_preparation.md` §4.1).
///
/// Does not use the AppBar; keeps a single pattern across auth, menu, and profile flows.
class BackButtonRow extends StatelessWidget {
  final String targetRoute;
  final Object? routeArguments;
  final List<String> blockIfCurrent;
  final String tooltip;

  const BackButtonRow({
    super.key,
    required this.targetRoute,
    this.routeArguments,
    this.blockIfCurrent = const [],
    this.tooltip = 'Back',
  });

  /// Replace with Search (home).
  const BackButtonRow.home({super.key, String tooltipText = 'Back'})
    : targetRoute = AppRoutes.home,
      routeArguments = null,
      blockIfCurrent = const [AppRoutes.home],
      tooltip = tooltipText;

  /// Replace with Profile (from Edit Profile).
  const BackButtonRow.toProfile({super.key})
    : targetRoute = AppRoutes.profile,
      routeArguments = null,
      blockIfCurrent = const [AppRoutes.profile],
      tooltip = 'Back';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => replaceIfNotCurrent(
          context,
          targetRoute,
          arguments: routeArguments,
          blockIfCurrent: blockIfCurrent,
        ),
        tooltip: tooltip,
      ),
    );
  }
}
