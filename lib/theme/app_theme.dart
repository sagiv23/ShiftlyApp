import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftly/utils/app_page_route.dart';

/// Design tokens and Material 3 themes for Shiftly Premium Dark Fintech.
class AppTheme {
  AppTheme._();

  // ── Shiftly Brand Palette ──────────────────────────────────────────
  // Backgrounds
  static const Color darkBackground = Color(0xFF070B18); // Primary Background
  static const Color darkSecondaryBackground = Color(
    0xFF0B1224,
  ); // Secondary Background
  static const Color darkCard = Color(0xFF111C32); // Elevated Surface
  static const Color darkSurfaceElevated = Color(
    0xFF15233D,
  ); // Alternative Surface

  static const Color lightBackground = Color(0xFFF2F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE9EEF4);
  static const Color lightBorder = Color(0xFFD6DFEB);

  // Primary Accents
  static const Color electricCyan = Color(0xFF38E8FF); // Electric Cyan
  static const Color brightCyan = Color(0xFF00C8F0); // Bright Cyan
  static const Color primary = electricCyan;
  static const Color primaryDark = brightCyan;
  static const Color primaryGlow = Color(0x4D38E8FF);

  // Secondary Accents
  static const Color neonViolet = Color(0xFF8B5CF6); // Neon Violet
  static const Color softLavender = Color(0xFFA78BFA); // Soft Lavender
  static const Color secondary = neonViolet;
  static const Color tertiary = softLavender;

  // Additional Accents
  static const Color mintGreen = Color(0xFF45E0B1); // Mint Green
  static const Color warmAmber = Color(0xFFFFBF69); // Warm Amber
  static const Color softCoral = Color(0xFFFF718A); // Soft Coral

  // Semantic mappings
  static const Color profit = mintGreen;
  static const Color profitSoft = Color(0xFF34D399);
  static const Color expense = softCoral;
  static const Color expenseSoft = Color(0xFFF87171);
  static const Color warning = warmAmber;
  static const Color warningSoft = Color(0xFFF59E0B);

  // Typography Colors
  static const Color primaryText = Color(0xFFF4F7FF);
  static const Color secondaryText = Color(0xFFA8B5CC);
  static const Color mutedText = Color(0xFF78869F);

  // Borders
  static const Color darkBorder = Color(
    0x2194B4E6,
  ); // Subtle Border: rgba(148, 180, 230, 0.13)
  static const Color highlightBorder = Color(
    0x4D38E8FF,
  ); // Highlight Border: rgba(56, 232, 255, 0.3)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [electricCyan, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [electricCyan, brightCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0x26111C32), Color(0x1A0B1224)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
      onSurface: isDark ? primaryText : const Color(0xFF0F172A),
      surfaceContainerHighest: isDark
          ? darkSurfaceElevated
          : lightSurfaceElevated,
      outline: isDark ? darkBorder : lightBorder,
      outlineVariant: isDark ? highlightBorder : lightBorder,
      error: expenseSoft,
    ).copyWith(secondary: secondary, tertiary: profit);

    final cardColor = isDark ? darkCard : lightCard;
    final borderColor = isDark ? darkBorder : lightBorder;
    final inputFill = isDark
        ? darkSecondaryBackground
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
          color: colorScheme.onSurface,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: colorScheme.onSurface,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: colorScheme.onSurface,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        titleSmall: baseText.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? secondaryText : const Color(0xFF475569),
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? mutedText : const Color(0xFF64748B),
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: colorScheme.onSurface,
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
          color: isDark ? secondaryText : const Color(0xFF475569),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: isDark ? mutedText : const Color(0xFF94A3B8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: primaryGlow,
          backgroundColor: primary,
          foregroundColor: const Color(0xFF040711),
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
          side: BorderSide(color: isDark ? highlightBorder : borderColor),
          foregroundColor: colorScheme.onSurface,
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
          backgroundColor: isDark ? darkSurfaceElevated : lightSurfaceElevated,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF040711),
        elevation: 8,
        highlightElevation: 12,
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
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary.withValues(alpha: isDark ? 0.25 : 0.15);
            }
            return isDark ? darkSecondaryBackground : lightSurfaceElevated;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }
            return isDark ? secondaryText : const Color(0xFF475569);
          }),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        backgroundColor: isDark ? darkSurfaceElevated : lightSurfaceElevated,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? darkCard : const Color(0xFF1E293B),
        contentTextStyle: const TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          side: BorderSide(color: borderColor),
        ),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: borderColor),
        ),
        backgroundColor: cardColor,
        elevation: 16,
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
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF040711);
          }
          if (states.contains(WidgetState.disabled)) {
            return isDark ? Colors.white24 : Colors.black12;
          }
          return isDark ? secondaryText : const Color(0xFF475569);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          if (states.contains(WidgetState.disabled)) {
            return isDark ? Colors.white10 : Colors.black12;
          }
          return isDark ? darkSecondaryBackground : const Color(0xFFCBD5E1);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? darkBorder : const Color(0xFF94A3B8);
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
        unselectedLabelColor: isDark ? secondaryText : const Color(0xFF64748B),
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
          ? darkCard.withValues(alpha: 0.85)
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
        ? darkCard.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.85);

    return BoxDecoration(
      color: fillColor ?? defaultFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? defaultBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
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
