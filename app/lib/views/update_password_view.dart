import 'package:flutter/material.dart';
import 'package:nomnom_safe/utils/form_validation_utils.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/widgets/password_field.dart';

class UpdatePasswordView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

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
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter New Password',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
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
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final isValid =
                              formKey.currentState?.validate() ?? false;
                          if (!isValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fix the errors above.'),
                              ),
                            );
                            return;
                          }

                          onSubmit();
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
