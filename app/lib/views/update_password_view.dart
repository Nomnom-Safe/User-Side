import 'package:flutter/material.dart';
import 'package:nomnom_safe/utils/form_validation_utils.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/widgets/password_field.dart';
import 'package:nomnom_safe/widgets/loading_elevated_button.dart';

class UpdatePasswordView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final bool showHeading;

  const UpdatePasswordView({
    super.key,
    required this.formKey,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onBack,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
    this.showHeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            Text(
              'Enter New Password',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
          if (errorMessage != null) ErrorBanner(errorMessage!),
          if (errorMessage != null) const SizedBox(height: 16),
          PasswordField(
            controller: newPasswordController,
            label: 'New Password',
            isRequired: true,
            isVisible: isVisible,
            onToggleVisibility: onToggleVisibility,
            enabled: !isLoading,
            validator: FormValidators.password,
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: confirmPasswordController,
            label: 'Confirm New Password',
            isRequired: true,
            isVisible: isVisible,
            onToggleVisibility: onToggleVisibility,
            enabled: !isLoading,
            validator: (value) => FormValidators.confirmPassword(
              value,
              newPasswordController.text,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LoadingElevatedButton(
                  label: 'Change Password',
                  isLoading: isLoading,
                  onPressed: () async {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    await onSubmit();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
