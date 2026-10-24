import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftly/utils/app_page_route.dart';

/// Design tokens and Material 3 themes for Shiftly.
class AppTheme {
  AppTheme._();

  // ── Brand & Surfaces ──────────────────────────────────────────────
  static const Color primary = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0EA5E9);
  static const Color primaryGlow = Color(0x5538BDF8);

  static const Color secondary = Color(0xFF818CF8);
  static const Color tertiary = Color(0xFFC084FC);

  static const Color lightBackground = Color(0xFFF2F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE9EEF4);
  static const Color lightBorder = Color(0xFFD6DFEB);

  static const Color darkBackground = Color(0xFF0C111B);
  static const Color darkCard = Color(0xFF131C2E);
  static const Color darkSurfaceElevated = Color(0xFF1D2A44);
  static const Color darkBorder = Color(0xFF273856);

  // ── Semantic Colors ───────────────────────────────────────────────
  static const Color profit = Color(0xFF34D399);
  static const Color profitSoft = Color(0xFF10B981);
  static const Color expense = Color(0xFFF87171);
  static const Color expenseSoft = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSoft = Color(0xFFF59E0B);

  // ── Spacing Scale ─────────────────────────────────────────────────
  static const double spaceXs = 8;
  static const double spaceSm = 16;
  static const double spaceMd = 24;
  static const double spaceLg = 32;
  static const double spaceXl = 40;

  // ── Radii ─────────────────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  // ── Global Font ───────────────────────────────────────────────────
  static const String fontFamily = 'sans-serif';

  // ── Typography Helpers ────────────────────────────────────────────
  static const TextStyle monoNumber = TextStyle(
    fontFamily: 'monospace',
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      surface: isDark ? darkBackground : lightBackground,
      onSurface: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      surfaceContainerHighest: isDark
          ? darkSurfaceElevated
          : lightSurfaceElevated,
      outline: isDark ? darkBorder : lightBorder,
      outlineVariant: isDark ? darkBorder.withValues(alpha: 0.6) : lightBorder,
      error: expenseSoft,
    ).copyWith(secondary: primaryDark, tertiary: profit);

    final cardColor = isDark ? darkCard : lightCard;
    final borderColor = isDark ? darkBorder : lightBorder;
    final inputFill = isDark
        ? darkCard.withValues(alpha: 0.8)
        : const Color(0xFFF1F5F9);

    final baseText = Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
          fontFamily: fontFamily,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        },
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 26,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: baseText.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.65),
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceSm,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: expense, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: expenseSoft, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.60),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: primaryGlow,
          backgroundColor: primary,
          foregroundColor: const Color(0xFF07090E),
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: spaceMd),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF07090E),
        elevation: 6,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.comfortable,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor.withValues(alpha: 0.6),
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        backgroundColor: cardColor,
        elevation: 12,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceSm,
          vertical: 4,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: spaceSm + 4,
          vertical: spaceXs,
        ),
        childrenPadding: EdgeInsets.zero,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) {
            return isDark ? Colors.white24 : Colors.black12;
          }
          return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryDark;
          if (states.contains(WidgetState.disabled)) {
            return isDark ? Colors.white10 : Colors.black12;
          }
          return isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryDark;
          return isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8);
        }),
        trackOutlineWidth: const WidgetStatePropertyAll(1.5),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.15),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Soft section container used to group form fields.
  static BoxDecoration sectionDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? darkCard.withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(color: isDark ? darkBorder : lightBorder, width: 1),
    );
  }

  /// Soft glass section container decoration used to group fields and cards.
  static BoxDecoration glassDecoration(
    BuildContext context, {
    double borderRadius = radiusLg,
    Color? borderColor,
    Color? fillColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder = isDark ? darkBorder : lightBorder;
    final defaultFill = isDark
        ? darkCard.withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.85);

    return BoxDecoration(
      color: fillColor ?? defaultFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? defaultBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static IconData iconForJobName(String? name) {
    if (name == null) return Icons.work_outline_rounded;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('מזנון') || lowerName.contains('buffet')) {
      return Icons.restaurant_rounded;
    }
    if (lowerName.contains('סדרן') || lowerName.contains('steward')) {
      return Icons.confirmation_number_outlined;
    }
    if (lowerName.contains('פריקה') || lowerName.contains('unloading')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.work_outline_rounded;
  }
}

/// Scales down slightly on press for tactile micro-interaction with accessibility semantics.
class ScalePress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? buttonLabel;
  final String? buttonHint;

  const ScalePress({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.buttonLabel,
    this.buttonHint,
  });

  @override
  State<ScalePress> createState() => _ScalePressState();
}

class _ScalePressState extends State<ScalePress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.buttonLabel,
      hint: widget.buttonHint,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                setState(() => _pressed = false);
                widget.onTap?.call();
              },
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
