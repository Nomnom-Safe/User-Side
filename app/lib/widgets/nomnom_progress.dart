import 'package:flutter/material.dart';

/// Sized loading indicators (`docs/demo_preparation.md` §4.6).
abstract final class NomNomProgress {
  NomNomProgress._();

  static const double pageIndicatorSize = 36;
  static const double inlineIndicatorSize = 20;

  /// Spinner used in lists, menus, and full-width loading slots.
  static Widget pageIndicator({double size = pageIndicatorSize}) => SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(),
  );

  /// Same dimensions as [pageIndicator], centered (e.g. expanded panels).
  static Widget centeredPage({double size = pageIndicatorSize}) =>
      Center(child: pageIndicator(size: size));

  /// Buttons and compact actions (`strokeWidth` aligned with existing auth forms).
  static Widget inline({double size = inlineIndicatorSize}) => SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(strokeWidth: 2),
  );
}
