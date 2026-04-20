import 'package:flutter/material.dart';

/// NomNom Theme Constants
class NomNomThemeConstants {
  static const Color linkBlue = Colors.blue;
  static const Color iconColor = Color(0xFF034c53);
  static const double linkIconSize = 16;

  static TextStyle linkTextStyle() {
    return TextStyle(
      color: linkBlue,
      decoration: TextDecoration.underline,
      decorationColor: linkBlue,
    );
  }
}
