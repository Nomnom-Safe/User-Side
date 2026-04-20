import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/utils/form_validation_utils.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:nomnom_safe/widgets/password_field.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/theme/screen_insets.dart';
import 'package:nomnom_safe/widgets/back_button_row.dart';
import 'package:nomnom_safe/widgets/loading_elevated_button.dart';
import 'package:nomnom_safe/widgets/nomnom_snackbar.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with RouteAware {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    routeObserver.unsubscribe(this);

    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    currentRouteName = AppRoutes.signIn;
  }

  @override
  void didPopNext() {
    currentRouteName = AppRoutes.signIn;
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthStateProvider>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        final user = context.read<AuthStateProvider>().currentUser;
        final first = (user?.firstName ?? '').trim();
        final welcome = first.isNotEmpty
            ? UserFeedbackMessages.signInWelcome(first)
            : UserFeedbackMessages.signInWelcomeGeneric;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(NomNomSnackBar(context: context, message: welcome));
        replaceIfNotCurrent(
          context,
          AppRoutes.home,
          blockIfCurrent: [AppRoutes.home],
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ScreenInsets.content,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const BackButtonRow.home(),
              Expanded(
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null) ErrorBanner(_errorMessage!),
          if (_errorMessage != null) const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormFieldWithController(
                  fieldKey: const Key('emailField'),
                  controller: _emailController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: FormValidators.email,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  fieldKey: const Key('passwordField'),
                  controller: _passwordController,
                  label: 'Password',
                  isRequired: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoadingElevatedButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: () {
                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (!isValid) return;
                        _handleSignIn();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: () {
                  navigateIfNotCurrent(
                    context,
                    AppRoutes.signUp,
                    blockIfCurrent: [AppRoutes.signUp],
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
