import 'package:flutter/material.dart';

class HyperOSTheme {
  static ThemeData light(Color seed) {
    final scheme = _ColorScheme.fromSeed(seed);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white.withOpacity(0.8),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        surfaceTintColor: scheme.primary.withOpacity(0.05),
        shadowColor: Colors.black.withOpacity(0.04),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: scheme.primary.withOpacity(0.15),
        backgroundColor: Colors.white,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      sliderTheme: const SliderThemeData(
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Colors.grey[200],
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(4),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(Colors.grey[300]),
      ),
    );
  }

  static ThemeData dark(Color seed) {
    final scheme = _ColorScheme.fromSeed(seed);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.8),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: scheme.primary.withOpacity(0.08),
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: scheme.primary.withOpacity(0.2),
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      sliderTheme: const SliderThemeData(
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Colors.grey[700],
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(4),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(Colors.grey[600]),
      ),
    );
  }
}

class _ColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color error;

  _ColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.error,
  });

  static _ColorScheme fromSeed(Color seed) {
    final hsl = HSLColor.fromColor(seed);
    return _ColorScheme(
      primary: seed,
      onPrimary: _contrastingColor(seed),
      secondary: hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
      surface: Colors.white,
      onSurface: const Color(0xFF1C1B1F),
      error: const Color(0xFFBA1A1A),
    );
  }

  static Color _contrastingColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
