import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/views/allergen_section.dart';
import 'package:nomnom_safe/views/profile_header.dart';
import 'package:nomnom_safe/theme/screen_insets.dart';
import 'package:nomnom_safe/widgets/delete_account_dialog.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/widgets/nomnom_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _deleteAccountError;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final user = controller.authProvider.currentUser;

        if (user == null) {
          return Padding(
            padding: ScreenInsets.content,
            child: Center(child: Text('Please sign in to view your profile.')),
          );
        }

        return SingleChildScrollView(
          padding: ScreenInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_deleteAccountError != null) ...[
                ErrorBanner(_deleteAccountError!),
                const SizedBox(height: 16),
              ],
              ProfileHeader(fullName: user.fullName),
              // Email
              Text('Email', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              // Allergies
              Text(
                'Selected Allergens',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              AllergenSection(controller: controller),
              const SizedBox(height: 32),
              // Edit button
              ElevatedButton(
                onPressed: () async {
                  final success = await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.editProfile);

                  if (success == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      NomNomSnackBar(
                        context: context,
                        message: UserFeedbackMessages.profileUpdatedSuccess,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    await controller.refreshUser(reloadAllergens: true);
                  }
                },
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 20),
              // Delete account button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  setState(() => _deleteAccountError = null);
                  final success = await showDeleteAccountDialog(
                    context,
                    controller,
                  );
                  if (success == true && context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  } else if (success == false && mounted) {
                    setState(() {
                      _deleteAccountError =
                          UserFeedbackMessages.accountDeletionFailed;
                    });
                  }
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
        );
      },
    );
  }
}
