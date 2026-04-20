import 'package:flutter/material.dart';
import 'package:nomnom_safe/utils/form_validation_utils.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';
import 'package:nomnom_safe/widgets/multi_select_checkbox_list.dart';
import 'package:nomnom_safe/widgets/loading_elevated_button.dart';

class EditProfileView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final VoidCallback onSave;
  final VoidCallback onChangePassword;
  final bool isLoading;
  final List<String> allAllergenLabels;
  final Set<String> selectedAllergenLabels;
  final void Function(String id, bool checked) onAllergenChanged;
  final bool showHeading;

  const EditProfileView({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.onSave,
    required this.onChangePassword,
    required this.isLoading,
    required this.allAllergenLabels,
    required this.selectedAllergenLabels,
    required this.onAllergenChanged,
    this.showHeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (showHeading) ...[
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
          TextFormFieldWithController(
            fieldKey: const Key('firstNameField'),
            controller: firstNameController,
            label: 'First Name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          TextFormFieldWithController(
            fieldKey: const Key('lastNameField'),
            controller: lastNameController,
            label: 'Last Name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          TextFormFieldWithController(
            fieldKey: const Key('emailField'),
            controller: emailController,
            label: 'Email',
            isRequired: true,
            validator: FormValidators.email,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Allergens',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          MultiSelectCheckboxList(
            options: allAllergenLabels,
            selected: selectedAllergenLabels,
            onChanged: onAllergenChanged,
          ),
          const SizedBox(height: 32),
          LoadingElevatedButton(
            label: 'Save Changes',
            isLoading: isLoading,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave();
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onChangePassword,
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}
