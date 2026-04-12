import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';

/// AuthService manages user authentication and session state using Firebase Firestore.
class AuthService {
  final AuthAdapter _auth;
  final FirestoreAdapter _firestore;
  static AuthService? _instance;

  User? _currentUser;

  AuthService._internal(this._auth, this._firestore);

  /// Factory returns a singleton. Provide `auth` and `firestore` adapters
  /// to inject test doubles (fakes/mocks) during unit tests. If no adapters
  /// are provided, production adapters that wrap Firebase SDKs are used.
  factory AuthService({AuthAdapter? auth, FirestoreAdapter? firestore}) {
    _instance ??= AuthService._internal(
      auth ?? FirebaseAuthAdapter(),
      firestore ?? FirebaseFirestoreAdapter(),
    );
    return _instance!;
  }

  /// Test helper: reset the singleton so tests can create a fresh instance
  /// by calling the factory with test adapters.
  static void clearInstanceForTests() {
    _instance = null;
  }

  /// Get the currently logged-in user, or null if not authenticated
  User? get currentUser => _currentUser;

  Future<void> loadCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      final doc = _firestore.collection('users').doc(fbUser.uid);
      final userData = await doc.get();
      if (userData != null) {
        _currentUser = User.fromJson({...userData, 'id': fbUser.uid});
      }
    }
  }

  /// Check if a user is currently logged in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign up a new user with validation.
  Future<String?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    // Validate inputs
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (password.isEmpty || password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // userCredential may be the SDK's UserCredential or a fake; try to
      // extract uid robustly.
      final uid = userCredential is Map && userCredential['user'] != null
          ? userCredential['user'].uid
          : (userCredential.user?.uid);

      if (uid == null) return 'Error signing up.';

      final newUser = User(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        allergies: allergies ?? [],
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());
      _currentUser = newUser;
    } on fb_auth.FirebaseAuthException {
      return 'Error signing up.';
    }

    return null;
  }

  /// Sign in with email and password.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadCurrentUser();
      if (_currentUser == null) return 'User profile not found';
    } on fb_auth.FirebaseAuthException {
      return 'Error signing in.';
    }

    return null;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  /// Update the current user's profile information
  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    final fbUser = _auth.currentUser;
    final uid = fbUser?.uid;
    if (uid == null || _currentUser == null) {
      return 'No user is currently signed in';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    final updates = <String, dynamic>{};

    // Compare each field
    if (firstName != _currentUser!.firstName) updates['first_name'] = firstName;
    if (lastName != _currentUser!.lastName) updates['last_name'] = lastName;
    if (allergies != null &&
        allergies.toSet() != _currentUser!.allergies.toSet()) {
      updates['allergies'] = allergies;
    }

    // Handle email change
    if (email != fbUser?.email) {
      await fbUser?.verifyBeforeUpdateEmail(email);
      updates['pending_email'] = email;
    }

    // Only write if something changed
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
      await loadCurrentUser(); // Refresh local copy
    }

    return null; // success
  }

  Future<bool> verifyPassword(String password) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || fbUser.email == null) {
      return false;
    }

    final credential = fb_auth.EmailAuthProvider.credential(
      email: fbUser.email!,
      password: password,
    );

    try {
      await fbUser.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update password with confirmation, return error string if invalid
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return 'No user is currently signed in';
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    try {
      await fbUser.updatePassword(newPassword);
      return null; // success
    } on fb_auth.FirebaseAuthException {
      return 'Password update failed.';
    }
  }

  Future<String?> deleteAccount() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return 'No user is currently signed in';
    }

    try {
      // Delete Firestore user document
      await _firestore.collection('users').doc(fbUser.uid).delete();

      // Delete Firebase Auth user
      await fbUser.delete();

      // Clear local state
      _currentUser = null;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please log in again before deleting your account.';
      } else {
        return 'Account deletion failed.';
      }
    } catch (e) {
      return 'Unexpected error.';
    }

    return null;
  }
}
