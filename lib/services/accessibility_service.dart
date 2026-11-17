import 'package:material_ui/material_ui.dart';

class AccessibilityService extends ChangeNotifier {
  double _fontScale = 1.0;
  bool _highContrast = false;
  Color _primaryColor = const Color(0xFF1565C0); // Deep Accessible Blue

  double get fontScale => _fontScale;
  bool get isHighContrast => _highContrast;
  Color get primaryColor => _primaryColor;

  static const List<Color> availableThemeColors = [
    Color(0xFF1565C0), // Deep Blue
    Color(0xFF2E7D32), // Forest Green
    Color(0xFF6A1B9A), // Royal Purple
    Color(0xFFD84315), // Deep Orange / Terracotta
    Color(0xFF00695C), // Deep Teal
  ];

  void setFontScale(double scale) {
    if (scale >= 0.85 && scale <= 1.35) {
      _fontScale = scale;
      notifyListeners();
    }
  }

  void increaseFont() {
    final next = (_fontScale + 0.1).clamp(0.85, 1.35);
    setFontScale(double.parse(next.toStringAsFixed(2)));
  }

  void decreaseFont() {
    final prev = (_fontScale - 0.1).clamp(0.85, 1.35);
    setFontScale(double.parse(prev.toStringAsFixed(2)));
  }

  void toggleHighContrast(bool enabled) {
    _highContrast = enabled;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  ThemeData get themeData {
    if (_highContrast) {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 56),
            textStyle: TextStyle(
              fontSize: 18 * _fontScale,
              fontWeight: FontWeight.bold,
            ),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: const Size(120, 56),
            textStyle: TextStyle(
              fontSize: 18 * _fontScale,
              fontWeight: FontWeight.bold,
            ),
            side: const BorderSide(color: Colors.black, width: 2.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
    }

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 54),
          textStyle: TextStyle(
            fontSize: 18 * _fontScale,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          minimumSize: const Size(120, 54),
          textStyle: TextStyle(
            fontSize: 18 * _fontScale,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: _primaryColor, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
    );
  }
}
