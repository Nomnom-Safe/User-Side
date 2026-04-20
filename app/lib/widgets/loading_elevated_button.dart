import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/nomnom_progress.dart';

/// [ElevatedButton] that shows a consistent inline spinner while [isLoading] (`docs/demo_preparation.md` §5.4).
class LoadingElevatedButton extends StatelessWidget {
  const LoadingElevatedButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final FutureOr<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading || onPressed == null
          ? null
          : () {
              onPressed!();
            },
      child: isLoading ? NomNomProgress.inline() : Text(label),
    );
  }
}
