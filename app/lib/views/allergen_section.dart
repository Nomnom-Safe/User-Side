import 'package:flutter/material.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/widgets/nomnom_progress.dart';

class AllergenSection extends StatelessWidget {
  final ProfileController controller;
  const AllergenSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingAllergens) {
      return NomNomProgress.centeredPage();
    }
    if (controller.allergenError != null) {
      return Column(
        children: [
          Text(
            controller.allergenError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(
            onPressed: controller.fetchAllergens,
            child: const Text('Retry'),
          ),
        ],
      );
    }
    if (controller.selectedAllergenLabels.isEmpty) {
      return Text(
        'No allergens selected',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      );
    }
    return Wrap(
      spacing: 8,
      children: [
        for (final label in controller.selectedAllergenLabels)
          Chip(label: Text(label)),
      ],
    );
  }
}
