import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:nomnom_safe/views/sign_up_account_view.dart';
import 'package:nomnom_safe/views/sign_up_allergen_view.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/theme/screen_insets.dart';
import 'package:nomnom_safe/widgets/back_button_row.dart';
import 'package:nomnom_safe/widgets/nomnom_snackbar.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with RouteAware {
  bool _showAllergenView = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Shared state variables
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> selectedAllergenIds = [];

  void _goToAllergenView() => setState(() => _showAllergenView = true);
  void _goBackToAccountView() => setState(() => _showAllergenView = false);

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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    currentRouteName = AppRoutes.signUp;
  }

  @override
  void didPopNext() {
    currentRouteName = AppRoutes.signUp;
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authStateProvider = context.read<AuthStateProvider>();

    try {
      await authStateProvider.signUp(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        allergies: selectedAllergenIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          NomNomSnackBar(
            context: context,
            message: UserFeedbackMessages.signUpSuccess,
          ),
        );
        replaceIfNotCurrent(
          context,
          AppRoutes.home,
          blockIfCurrent: [AppRoutes.home],
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
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
    final viewTitle = _showAllergenView ? 'Select Allergens' : 'Create Account';

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
                  viewTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 32),
          _showAllergenView
              ? SignUpAllergenView(
                  isLoading: _isLoading,
                  selectedAllergenIds: selectedAllergenIds,
                  onChanged: (ids) => setState(() => selectedAllergenIds = ids),
                  onBack: _goBackToAccountView,
                  onSubmit: _handleSignUp,
                )
              : SignUpAccountView(
                  formKey: _formKey,
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  onNext: _goToAllergenView,
                ),
        ],
      ),
    );
  }
}
