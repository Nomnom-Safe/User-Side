import 'package:flutter/foundation.dart';
import 'package:nomnom_safe/models/profile_update_result.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/services/auth_service.dart';

/// AuthStateProvider notifies listeners when authentication state changes
class AuthStateProvider extends ChangeNotifier {
  AuthService? _authService;

  AuthStateProvider([AuthService? authService]) : _authService = authService;

  bool get isSignedIn => (_authService ??= AuthService()).isSignedIn;

  /// Sign up and notify listeners
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    final error = await (_authService ??= AuthService()).signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      allergies: allergies,
    );
    if (error != null) throw Exception(error);
    notifyListeners();
  }

  /// Sign in and notify listeners
  Future<void> signIn({required String email, required String password}) async {
    final error = await (_authService ??= AuthService()).signIn(
      email: email,
      password: password,
    );
    if (error != null) throw Exception(error);
    notifyListeners();
  }

  /// Sign out and notify listeners
  Future<void> signOut() async {
    await (_authService ??= AuthService()).signOut();
    notifyListeners();
  }

  /// Update profile and notify listeners
  Future<ProfileUpdateResult> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    final result = await (_authService ??= AuthService()).updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      allergies: allergies,
    );
    notifyListeners();
    return result;
  }

  Future<void> loadCurrentUser() async {
    await (_authService ??= AuthService()).loadCurrentUser();
    notifyListeners();
  }

  /// Verify current password
  Future<bool> verifyPassword(String password) async {
    try {
      return await (_authService ??= AuthService()).verifyPassword(password);
    } catch (_) {
      return false;
    }
  }

  /// Update password with confirmation
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final error = await (_authService ??= AuthService()).updatePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    notifyListeners();
    return error;
  }

  Future<void> deleteAccount({required String password}) async {
    final success = await (_authService ??= AuthService()).verifyPassword(
      password,
    );
    if (!success) {
      throw Exception('Please log in again before deleting your account.');
    }

    await (_authService ??= AuthService()).deleteAccount(); // your backend call
    notifyListeners();
  }

  /// Get current user (for profile display)
  User? get currentUser => (_authService ??= AuthService()).currentUser;
}
