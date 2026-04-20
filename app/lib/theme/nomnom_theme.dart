import 'package:flutter/material.dart';
import 'theme_constants.dart';

/// Nomnom theme

final _baseScheme = ColorScheme.fromSeed(seedColor: Color(0xFF034c53));

final _customScheme = _baseScheme.copyWith(
  primary: Color(0xFF034c53),
  onPrimary: Colors.white,
);

final ThemeData nomnomTheme = ThemeData(
  colorScheme: _customScheme,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF008080),
    unselectedItemColor: Colors.grey,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF008080),
    foregroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(
    color: NomNomThemeConstants.iconColor,
    size: 16,
  ),
  chipTheme: ChipThemeData(
    selectedColor: Color(0xFF3EB489),
    checkmarkColor: Colors.white,
  ),
);
