import 'package:flutter/material.dart';

/// NomNom-branded snack bar: [`ColorScheme.primary`] background (see
/// [`nomnom_theme.dart`] — `0xFF034c53`) and [`ColorScheme.onPrimary`] text (white).
class NomNomSnackBar extends SnackBar {
  NomNomSnackBar({
    super.key,
    required BuildContext context,
    required String message,
    super.action,
    super.duration = const Duration(seconds: 4),
    super.behavior,
    super.margin,
    super.padding,
    super.shape,
    super.elevation,
    super.dismissDirection,
  }) : super(
         backgroundColor: Theme.of(context).chipTheme.selectedColor,
         content: Text(
           message,
           style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
         ),
       );
}
