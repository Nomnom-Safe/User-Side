import 'package:flutter/material.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';

Future<bool?> showDeleteAccountDialog(
  BuildContext context,
  ProfileController controller,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) =>
        _DeleteAccountDialogContent(controller: controller),
  );
}

class _DeleteAccountDialogContent extends StatefulWidget {
  final ProfileController controller;

  const _DeleteAccountDialogContent({required this.controller});

  @override
  State<_DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<_DeleteAccountDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDelete() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isDeleting = true);
    final success = await widget.controller.deleteAccount(
      _passwordController.text,
    );
    if (!mounted) return;
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Account Deletion'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion.'),
            const SizedBox(height: 12),
            TextFormFieldWithController(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              isRequired: true,
              enabled: !_isDeleting,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _onDelete,
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
