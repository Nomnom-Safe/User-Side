import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/profile_update_result.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

enum ProfileViewState { editProfile, verifyCurrentPassword, updatePassword }

class EditProfileController extends ChangeNotifier {
  final AuthStateProvider authProvider;
  final AllergenService allergenService;

  bool isLoading = false;
  String? errorMessage;
  bool arePasswordsVisible = false;
  ProfileViewState viewState = ProfileViewState.editProfile;

  Map<String, String> allergenIdToLabel = {};
  Map<String, String> allergenLabelToId = {};
  Set<String> selectedAllergenIds = {};
  Set<String> selectedAllergenLabels = {};
  bool isLoadingAllergens = true;

  EditProfileController({
    required this.authProvider,
    AllergenService? allergenService,
  }) : allergenService = allergenService ?? AllergenService() {
    _initUser();
    _fetchAllergens();
  }

  void _initUser() {
    final user = authProvider.currentUser;
    if (user != null) {
      selectedAllergenIds = user.allergies.toSet();
    }
  }

  Future<void> _fetchAllergens() async {
    try {
      final idToLabel = await allergenService.getAllergenIdToLabelMap();
      final labelToId = await allergenService.getAllergenLabelToIdMap();
      final labels = await allergenService.idsToLabels(
        selectedAllergenIds.toList(),
      );

      allergenIdToLabel = idToLabel;
      allergenLabelToId = labelToId;
      selectedAllergenLabels = labels.toSet();
      isLoadingAllergens = false;
      notifyListeners();
    } catch (e) {
      allergenIdToLabel = {};
      allergenLabelToId = {};
      selectedAllergenLabels = {};
      isLoadingAllergens = false;
      errorMessage = UserFeedbackMessages.loadAllergensFailed;
      notifyListeners();
    }
  }

  void toggleAllergen(String label, bool checked) {
    final id = allergenLabelToId[label];
    if (id == null) return;

    if (checked) {
      selectedAllergenIds.add(id);
      selectedAllergenLabels.add(label);
    } else {
      selectedAllergenIds.remove(id);
      selectedAllergenLabels.remove(label);
    }
    notifyListeners();
  }

  Future<ProfileUpdateResult> saveChanges({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await authProvider.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      allergies: selectedAllergenIds.toList(),
    );

    isLoading = false;
    errorMessage = result.error;
    notifyListeners();
    return result;
  }

  Future<void> verifyCurrentPassword(String currentPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await authProvider.verifyPassword(currentPassword);

    isLoading = false;
    viewState = success
        ? ProfileViewState.updatePassword
        : ProfileViewState.verifyCurrentPassword;
    errorMessage = success ? null : 'Incorrect password';
    notifyListeners();
  }

  Future<void> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final error = await authProvider.updatePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    isLoading = false;
    errorMessage = error;
    if (error == null) {
      viewState = ProfileViewState.editProfile;
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    arePasswordsVisible = !arePasswordsVisible;
    notifyListeners();
  }

  void goToVerifyPassword() {
    viewState = ProfileViewState.verifyCurrentPassword;
    notifyListeners();
  }

  void goBackToEditProfile() {
    viewState = ProfileViewState.editProfile;
    notifyListeners();
  }
}
