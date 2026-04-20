import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/widgets/nomnom_snackbar.dart';

/// Custom AppBar widget for consistency across the app
class NomnomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NomnomAppBar({super.key, this.title = 'NomNom Safe'});

  void _handleSignOut(BuildContext context) async {
    final authStateProvider = context.read<AuthStateProvider>();
    await authStateProvider.signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        NomNomSnackBar(
          context: context,
          message: UserFeedbackMessages.signedOutSuccess,
        ),
      );
      replaceIfNotCurrent(
        context,
        AppRoutes.home,
        blockIfCurrent: [AppRoutes.home],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSignedIn;
    try {
      isSignedIn = context.watch<AuthStateProvider>().isSignedIn;
    } catch (_) {
      // In tests the provider may not be present; treat as signed out.
      isSignedIn = false;
    }

    return AppBar(
      title: InkWell(
        onTap: () => replaceIfNotCurrent(
          context,
          AppRoutes.home,
          blockIfCurrent: [AppRoutes.home],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(title),
        ),
      ),
      automaticallyImplyLeading: false, // Disable automatic back arrow
      actions: [
        if (isSignedIn) ...[
          // Sign Out button
          TextButton(
            onPressed: () => _handleSignOut(context),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else ...[
          // Sign In button
          TextButton(
            onPressed: () => navigateIfNotCurrent(
              context,
              AppRoutes.signIn,
              blockIfCurrent: [AppRoutes.signIn],
            ),
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
          // Sign Up button
          TextButton(
            onPressed: () => navigateIfNotCurrent(
              context,
              AppRoutes.signUp,
              blockIfCurrent: [AppRoutes.signUp],
            ),
            child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
