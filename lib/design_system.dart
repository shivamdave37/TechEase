import 'package:material_ui/material_ui.dart';

/// Central design system for senior‑friendly UI.
/// Designed for maximum legibility, comfort, tactile feedback, and accessibility.
class AppDesign {
  // Primary colors – users can switch in Settings.
  static const List<MaterialColor> primaryPalette = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  // Modern Accessible Theme Palette Colors
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color accentCyan = Color(0xFF0284C7);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color dangerRed = Color(0xFFDC2626);
  static const Color neutralDark = Color(0xFF1E293B);
  static const Color neutralMuted = Color(0xFF64748B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;

  // Text styles – large, high‑contrast, senior-optimized.
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    letterSpacing: -0.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 20,
    color: Colors.black87,
    height: 1.35,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: Color(0xFF475569),
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Spacing – multiples of 8.
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceExtraLarge = 32.0;

  // Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;

  // Minimum touch target (48dp). Senior standard recommends 52dp+ for primary actions.
  static const double minTouchTarget = 48.0;
  static const double primaryButtonHeight = 54.0;

  // Soft Card Elevation Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get tactileShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  // Category Theme Accent Gradients and Icons
  static LinearGradient getCategoryGradient(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('whatsapp')) {
      return const LinearGradient(
        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('basic')) {
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('map')) {
      return const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('qr')) {
      return const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('photo') || lower.contains('gallery')) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('internet') || lower.contains('brows')) {
      return const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('scam') || lower.contains('safe') || lower.contains('shield')) {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static IconData getCategoryIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('whatsapp')) return Icons.chat_bubble_rounded;
    if (lower.contains('basic')) return Icons.phone_android_rounded;
    if (lower.contains('map')) return Icons.map_rounded;
    if (lower.contains('qr')) return Icons.qr_code_scanner_rounded;
    if (lower.contains('photo') || lower.contains('gallery')) return Icons.photo_library_rounded;
    if (lower.contains('internet') || lower.contains('brows')) return Icons.public_rounded;
    if (lower.contains('scam') || lower.contains('safe') || lower.contains('shield')) return Icons.shield_rounded;
    return Icons.auto_stories_rounded;
  }
}
