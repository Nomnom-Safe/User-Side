import 'package:flutter/material.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/service_utils.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/widgets/multi_select_checkbox_list.dart';
import 'package:nomnom_safe/widgets/nomnom_progress.dart';
import 'package:nomnom_safe/widgets/loading_elevated_button.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';

class SignUpAllergenView extends StatefulWidget {
  final bool isLoading;
  final List<String> selectedAllergenIds;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const SignUpAllergenView({
    super.key,
    required this.isLoading,
    required this.selectedAllergenIds,
    required this.onChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<SignUpAllergenView> createState() => _SignUpAllergenViewState();
}

class _SignUpAllergenViewState extends State<SignUpAllergenView> {
  late AllergenService _allergenService;
  Map<String, String> allergenIdToLabel = {};
  Map<String, String> _allergenLabelToId = {};
  Set<String> _selectedAllergenLabels = {};
  bool isLoadingAllergens = true;
  String? allergenError;
  bool _allergenFetchStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_allergenFetchStarted) return;
    _allergenFetchStarted = true;
    _allergenService = getAllergenService(context);
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    if (mounted) {
      setState(() {
        allergenError = null;
        isLoadingAllergens = true;
      });
    }
    try {
      final idToLabel = await _allergenService.getAllergenIdToLabelMap();
      final labelToId = await _allergenService.getAllergenLabelToIdMap();
      final selectedLabels = await _allergenService.idsToLabels(
        widget.selectedAllergenIds,
      );

      if (mounted) {
        setState(() {
          allergenIdToLabel = idToLabel;
          _allergenLabelToId = labelToId;
          _selectedAllergenLabels = selectedLabels.toSet();
          isLoadingAllergens = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          allergenError = UserFeedbackMessages.loadAllergensFailed;
          isLoadingAllergens = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingAllergens) {
      return NomNomProgress.centeredPage();
    }
    if (allergenError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorBanner(allergenError!),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadAllergens,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }
    if (allergenIdToLabel.isEmpty && !isLoadingAllergens) {
      return const Center(child: Text('No allergens available'));
    }

    return Column(
      children: [
        MultiSelectCheckboxList(
          options: allergenIdToLabel.values.toList(),
          selected: _selectedAllergenLabels,
          onChanged: (label, checked) {
            final id = _allergenLabelToId[label];
            if (id == null) return;

            final updated = widget.selectedAllergenIds.toSet();
            if (checked) {
              updated.add(id);
            } else {
              updated.remove(id);
            }

            setState(() {
              _selectedAllergenLabels = updated
                  .map((id) => allergenIdToLabel[id] ?? id)
                  .toSet();
            });

            widget.onChanged(updated.toList());
          },
        ),
        const SizedBox(height: 24),
        LoadingElevatedButton(
          label: 'Create Account',
          isLoading: widget.isLoading,
          onPressed: widget.onSubmit,
        ),
        TextButton(onPressed: widget.onBack, child: const Text('Back')),
      ],
    );
  }
}
