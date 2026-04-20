import 'package:flutter/material.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/views/edit_profile_view.dart';
import 'package:nomnom_safe/views/update_password_view.dart';
import 'package:nomnom_safe/views/verify_current_password_view.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/widgets/nomnom_snackbar.dart';

class EditProfileBody extends StatelessWidget {
  final EditProfileController controller;
  final ProfileFormModel formModel;
  final bool showHeading;

  const EditProfileBody({
    super.key,
    required this.controller,
    required this.formModel,
    this.showHeading = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (controller.viewState) {
      case ProfileViewState.editProfile:
        return _buildEditProfileView(context);
      case ProfileViewState.verifyCurrentPassword:
        return _buildVerifyPasswordView(context);
      case ProfileViewState.updatePassword:
        return _buildUpdatePasswordView(context);
    }
  }

  Widget _buildEditProfileView(BuildContext context) {
    return EditProfileView(
      formKey: formModel.formKey,
      firstNameController: formModel.firstName,
      lastNameController: formModel.lastName,
      emailController: formModel.email,
      onSave: () async {
        final result = await controller.saveChanges(
          firstName: formModel.firstName.text.trim(),
          lastName: formModel.lastName.text.trim(),
          email: formModel.email.text.trim(),
          password: formModel.password.text,
          confirmPassword: formModel.confirmPassword.text,
        );

        if (!result.isSuccess || !context.mounted) return;
        if (result.userMessage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            NomNomSnackBar(context: context, message: result.userMessage!),
          );
        }
        Navigator.of(context).pop(true);
      },
      onChangePassword: controller.goToVerifyPassword,
      isLoading: controller.isLoading,
      allAllergenLabels: controller.allergenIdToLabel.values.toList(),
      selectedAllergenLabels: controller.selectedAllergenLabels,
      onAllergenChanged: controller.toggleAllergen,
      showHeading: showHeading,
    );
  }

  Widget _buildVerifyPasswordView(BuildContext context) {
    return VerifyCurrentPasswordView(
      controller: formModel.currentPassword,
      isVisible: controller.arePasswordsVisible,
      onToggleVisibility: controller.togglePasswordVisibility,
      showHeading: showHeading,
      onContinue: () async {
        await controller.verifyCurrentPassword(formModel.currentPassword.text);
        if (controller.errorMessage != null) {
          formModel.currentPassword.clear();
        }
      },
      isLoading: controller.isLoading,
      errorMessage: controller.errorMessage,
    );
  }

  Widget _buildUpdatePasswordView(BuildContext context) {
    return UpdatePasswordView(
      formKey: formModel.formKey,
      newPasswordController: formModel.newPassword,
      confirmPasswordController: formModel.confirmNewPassword,
      isVisible: controller.arePasswordsVisible,
      onToggleVisibility: controller.togglePasswordVisibility,
      onBack: controller.goBackToEditProfile,
      showHeading: showHeading,
      onSubmit: () async {
        await controller.updatePassword(
          newPassword: formModel.newPassword.text,
          confirmPassword: formModel.confirmNewPassword.text,
        );
        if (!context.mounted) return;
        if (controller.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            NomNomSnackBar(
              context: context,
              message: UserFeedbackMessages.passwordChangeSuccess,
            ),
          );
        }
      },
      isLoading: controller.isLoading,
      errorMessage: controller.errorMessage,
    );
  }
}
