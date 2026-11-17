import 'package:material_ui/material_ui.dart';

/// Central design system for senior‑friendly UI.
class AppDesign {
  // Primary colors – users can switch in Settings (not needed for Stage 1).
  static const List<MaterialColor> primaryPalette = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  // Text styles – large, high‑contrast.
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle body = TextStyle(fontSize: 20, color: Colors.black87);

  static const TextStyle button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Spacing – multiples of 8.
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;

  // Minimum touch target (48dp).
  static const double minTouchTarget = 48.0;
}
