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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => replaceIfNotCurrent(
                context,
                AppRoutes.home,
                blockIfCurrent: [AppRoutes.home],
              ),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
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
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final isValid =
                                  _formKey.currentState?.validate() ?? false;

                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fix the errors above.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              _handleSignIn();
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Text('Sign In'),
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
