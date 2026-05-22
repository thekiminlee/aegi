import 'package:flutter/material.dart';

enum AppThemeKey { nurtureLight, softMint }

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.appBackground,
    required this.cardBackground,
    required this.outline,
    required this.weakText,
    required this.ctaBackground,
    required this.ctaForeground,
    required this.activeBorder,
    required this.selectedAccent,
    required this.progressInactive,
    required this.infoTint,
    required this.accent,
    required this.black,
    required this.white,
  });

  final Color appBackground;
  final Color cardBackground;
  final Color outline;
  final Color weakText;
  final Color ctaBackground;
  final Color ctaForeground;
  final Color activeBorder;
  final Color selectedAccent;
  final Color progressInactive;
  final Color infoTint;
  final Color accent;
  final Color black;
  final Color white;

  @override
  AppColors copyWith({
    Color? appBackground,
    Color? cardBackground,
    Color? outline,
    Color? weakText,
    Color? ctaBackground,
    Color? ctaForeground,
    Color? activeBorder,
    Color? selectedAccent,
    Color? progressInactive,
    Color? infoTint,
    Color? accent,
    Color? black,
    Color? white,
  }) {
    return AppColors(
      appBackground: appBackground ?? this.appBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      outline: outline ?? this.outline,
      weakText: weakText ?? this.weakText,
      ctaBackground: ctaBackground ?? this.ctaBackground,
      ctaForeground: ctaForeground ?? this.ctaForeground,
      activeBorder: activeBorder ?? this.activeBorder,
      selectedAccent: selectedAccent ?? this.selectedAccent,
      progressInactive: progressInactive ?? this.progressInactive,
      infoTint: infoTint ?? this.infoTint,
      accent: accent ?? this.accent,
      black: black ?? this.black,
      white: white ?? this.white
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      weakText: Color.lerp(weakText, other.weakText, t)!,
      ctaBackground: Color.lerp(ctaBackground, other.ctaBackground, t)!,
      ctaForeground: Color.lerp(ctaForeground, other.ctaForeground, t)!,
      activeBorder: Color.lerp(activeBorder, other.activeBorder, t)!,
      selectedAccent: Color.lerp(selectedAccent, other.selectedAccent, t)!,
      progressInactive: Color.lerp(
        progressInactive,
        other.progressInactive,
        t,
      )!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      black: Color.lerp(black, other.black, t)!,
      white: Color.lerp(white, other.white, t)!
    );
  }
}

ThemeData buildThemeData(AppThemeKey key) {
  final bool isSoftMint = key == AppThemeKey.softMint;
  final colors = AppColors(
    appBackground: isSoftMint
        ? const Color(0xFFF5F9F6)
        : const Color(0xFFFAF9F7),
    cardBackground: const Color.fromARGB(239, 255, 255, 255),
    outline: const Color(0xFFC7C6CA),
    weakText: const Color.fromARGB(255, 44, 44, 48),
    ctaBackground: const Color(0xFF1C1C1E),
    ctaForeground: Colors.white,
    activeBorder: const Color(0xFF1C1C1E),
    selectedAccent: const Color.fromARGB(255, 33, 192, 70),
    progressInactive: const Color(0xFFD8D8DC),
    infoTint: isSoftMint ? const Color(0xFFE4F2EB) : const Color(0xFFF7F0E3),
    accent: const Color(0xFFE8A893),
    black: Colors.grey[800]!,
    white: const Color(0xFFFDFCF8)
  );

  final base = ThemeData(
    fontFamily: 'Urbanist',
    scaffoldBackgroundColor: colors.appBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1C1C1E),
      brightness: Brightness.light,
      surface: colors.cardBackground,
    ),
    useMaterial3: true,
  );

  // Define the default text style with the requested color and letter spacing.
  // This will serve as the base for all other text styles unless explicitly overridden.
  // Note: Colors.black32 is a semi-transparent black and may visually differ
  // from the on-surface color (#1c1b1b) defined in DESIGN.md.
  TextStyle defaultTextStyle = TextStyle(
    color: Colors.grey[800], // Requested default color
    letterSpacing: -0.25, // Requested default letter spacing
    fontFamily: "Urbanist", // Ensure the default font family is applied
    fontWeight: FontWeight.w500
  );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFFB6B6BC)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.activeBorder),
      ),
    ),
    textTheme: base.textTheme.copyWith(
      // Start with the base text theme
      displayLarge: defaultTextStyle.copyWith(
        fontSize: 42,
        height: 64 / 57,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: defaultTextStyle.copyWith(
        fontSize: 36,
        height: 52 / 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: defaultTextStyle.copyWith(
        fontSize: 32,
        height: 44 / 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: defaultTextStyle.copyWith(
        fontSize: 28,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: defaultTextStyle.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: defaultTextStyle.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: defaultTextStyle.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: defaultTextStyle.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: defaultTextStyle.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: defaultTextStyle.copyWith(
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: defaultTextStyle.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: defaultTextStyle.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: defaultTextStyle.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: colors.ctaForeground, // Explicitly set for button text
        letterSpacing: 0, // Explicitly set for button text
      ),
      labelMedium: defaultTextStyle.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: colors.ctaForeground, // Explicitly set for button text
        letterSpacing: 0, // Explicitly set for button text
      ),
      labelSmall: defaultTextStyle.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: colors.ctaForeground, // Explicitly set for button text
        letterSpacing: 0, // Explicitly set for button text
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[colors],
  );
}

extension AppThemeColorsX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? _fallbackColors;
}

AppColors _fallbackColors = AppColors(
  appBackground: Color(0xFFFAF9F7),
  cardBackground: Colors.white,
  outline: Color(0xFFC7C6CA),
  weakText: Color(0xFF64646B),
  ctaBackground: Color(0xFF1C1C1E),
  ctaForeground: Colors.white,
  activeBorder: Color(0xFF1C1C1E),
  selectedAccent: Color.fromARGB(255, 41, 194, 56),
  progressInactive: Color(0xFFD8D8DC),
  infoTint: Color(0xFFF7F0E3),
  accent: Color(0xFFFFB07C),
  black: Colors.grey[800]!,
  white: const Color(0xFFFDFCF8)
);

const showCaseTitleStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 18,
  letterSpacing: -0.25
);

const showcaseDescStyle = TextStyle(
  fontFamily: "Urbanist",
  fontSize: 14
);