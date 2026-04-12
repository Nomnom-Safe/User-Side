import 'package:flutter/material.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';

class ProfileController extends ChangeNotifier {
  final AuthStateProvider authProvider;
  final AllergenService allergenService;

  Map<String, String> allergenIdToLabel = {};
  Set<String> selectedAllergenLabels = {};
  bool isLoadingAllergens = true;
  String? allergenError;

  ProfileController({
    required this.authProvider,
    required this.allergenService,
  }) {
    fetchAllergens();
  }

  /// Public method so UI or other controllers can trigger a refresh
  Future<void> fetchAllergens() async {
    try {
      // Reset state before fetching
      isLoadingAllergens = true;
      allergenError = null;
      notifyListeners();

      final idToLabel = await allergenService.getAllergenIdToLabelMap();
      final user = authProvider.currentUser;
      final selectedLabels = user != null
          ? await allergenService.idsToLabels(user.allergies)
          : <String>[];

      allergenIdToLabel = idToLabel;
      selectedAllergenLabels = selectedLabels.toSet();
      isLoadingAllergens = false;
      notifyListeners();
    } catch (e) {
      allergenError = UserFeedbackMessages.loadAllergensFailed;
      isLoadingAllergens = false;
      notifyListeners();
    }
  }

  /// Refreshes the user profile and optionally re-fetches allergens
  Future<bool> refreshUser({bool reloadAllergens = false}) async {
    try {
      await authProvider.loadCurrentUser();
      if (reloadAllergens) {
        await fetchAllergens();
      } else {
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      await authProvider.deleteAccount(password: password);
      return true;
    } catch (_) {
      return false;
    }
  }
}
