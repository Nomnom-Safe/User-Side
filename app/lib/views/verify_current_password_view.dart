import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/widgets/password_field.dart';
import 'package:nomnom_safe/widgets/loading_elevated_button.dart';

class VerifyCurrentPasswordView extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final Future<void> Function() onContinue;
  final bool isLoading;
  final String? errorMessage;
  final bool showHeading;

  const VerifyCurrentPasswordView({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onContinue,
    required this.isLoading,
    this.errorMessage,
    this.showHeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeading) ...[
          Text(
            'Enter Current Password',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
        if (errorMessage != null) ErrorBanner(errorMessage!),
        if (errorMessage != null) const SizedBox(height: 16),
        PasswordField(
          controller: controller,
          label: 'Current Password',
          isVisible: isVisible,
          isRequired: true,
          onToggleVisibility: onToggleVisibility,
          enabled: !isLoading,
        ),
        const SizedBox(height: 32),
        LoadingElevatedButton(
          label: 'Continue',
          isLoading: isLoading,
          onPressed: () {
            onContinue();
          },
        ),
      ],
    );
  }
}
