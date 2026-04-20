import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/theme/screen_insets.dart';
import 'package:nomnom_safe/widgets/back_button_row.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/views/edit_profile_body.dart';

String _titleForEditProfileFlow(ProfileViewState state) {
  switch (state) {
    case ProfileViewState.editProfile:
      return 'Edit Profile';
    case ProfileViewState.verifyCurrentPassword:
      return 'Enter Current Password';
    case ProfileViewState.updatePassword:
      return 'Enter New Password';
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late ProfileFormModel _formModel;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthStateProvider>();
    _formModel = ProfileFormModel.fromUser(authProvider.currentUser);
  }

  @override
  void dispose() {
    _formModel.dispose();
    super.dispose();
  }

  Widget _titleRow(BuildContext context, ProfileViewState viewState) {
    return Row(
      children: [
        const BackButtonRow.toProfile(),
        Expanded(
          child: Text(
            _titleForEditProfileFlow(viewState),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileController>(
      builder: (context, controller, _) {
        final auth = context.watch<AuthStateProvider>();
        if (auth.currentUser == null) {
          return SingleChildScrollView(
            padding: ScreenInsets.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _titleRow(context, ProfileViewState.editProfile),
                const SizedBox(height: 20),
                const ErrorBanner('Please sign in to edit your profile.'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: ScreenInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _titleRow(context, controller.viewState),
              const SizedBox(height: 20),
              if (controller.errorMessage != null &&
                  controller.viewState !=
                      ProfileViewState.verifyCurrentPassword)
                ErrorBanner(controller.errorMessage!),
              if (controller.errorMessage != null) const SizedBox(height: 16),
              EditProfileBody(
                controller: controller,
                formModel: _formModel,
                showHeading: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
