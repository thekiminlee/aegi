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
    required this.progressInactive,
    required this.infoTint,
  });

  final Color appBackground;
  final Color cardBackground;
  final Color outline;
  final Color weakText;
  final Color ctaBackground;
  final Color ctaForeground;
  final Color activeBorder;
  final Color progressInactive;
  final Color infoTint;

  @override
  AppColors copyWith({
    Color? appBackground,
    Color? cardBackground,
    Color? outline,
    Color? weakText,
    Color? ctaBackground,
    Color? ctaForeground,
    Color? activeBorder,
    Color? progressInactive,
    Color? infoTint,
  }) {
    return AppColors(
      appBackground: appBackground ?? this.appBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      outline: outline ?? this.outline,
      weakText: weakText ?? this.weakText,
      ctaBackground: ctaBackground ?? this.ctaBackground,
      ctaForeground: ctaForeground ?? this.ctaForeground,
      activeBorder: activeBorder ?? this.activeBorder,
      progressInactive: progressInactive ?? this.progressInactive,
      infoTint: infoTint ?? this.infoTint,
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
      progressInactive: Color.lerp(
        progressInactive,
        other.progressInactive,
        t,
      )!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
    );
  }
}

ThemeData buildThemeData(AppThemeKey key) {
  final bool isSoftMint = key == AppThemeKey.softMint;
  final colors = AppColors(
    appBackground: isSoftMint
        ? const Color(0xFFF5F9F6)
        : const Color(0xFFFAF9F7),
    cardBackground: Colors.white,
    outline: const Color(0xFFC7C6CA),
    weakText: const Color.fromARGB(255, 44, 44, 48),
    ctaBackground: const Color(0xFF1C1C1E),
    ctaForeground: Colors.white,
    activeBorder: const Color(0xFF1C1C1E),
    progressInactive: const Color(0xFFD8D8DC),
    infoTint: isSoftMint ? const Color(0xFFE4F2EB) : const Color(0xFFF7F0E3),
  );

  final base = ThemeData(
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: colors.appBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1C1C1E),
      brightness: Brightness.light,
      surface: colors.cardBackground,
    ),
    useMaterial3: true,
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
      headlineMedium: const TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
        color: Colors.black,
        fontFamily: "DM Sans"
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        fontFamily: "DM Sans"
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: "DM Sans"
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFamily: "DM Sans"
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFamily: "DM Sans"
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: "DM Sans"
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[colors],
  );
}

extension AppThemeColorsX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? _fallbackColors;
}

const AppColors _fallbackColors = AppColors(
  appBackground: Color(0xFFFAF9F7),
  cardBackground: Colors.white,
  outline: Color(0xFFC7C6CA),
  weakText: Color(0xFF64646B),
  ctaBackground: Color(0xFF1C1C1E),
  ctaForeground: Colors.white,
  activeBorder: Color(0xFF1C1C1E),
  progressInactive: Color(0xFFD8D8DC),
  infoTint: Color(0xFFF7F0E3),
);
