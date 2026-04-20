import 'package:flutter/material.dart';

/// Shared layout spacing (`docs/demo_preparation.md` §4.3).
abstract final class ScreenInsets {
  ScreenInsets._();

  /// Primary padding for scrollable flows, forms, and primary screen bodies.
  static const EdgeInsets content = EdgeInsets.all(24);
}
