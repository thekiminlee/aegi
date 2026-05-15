import 'dart:math' as math;

import 'package:flutter/material.dart';

class MonthTrackerColorScheme {
  const MonthTrackerColorScheme({
    required this.gradientColors,
    required this.textColor,
  });

  final List<Color> gradientColors;
  final Color textColor;
}

int monthAgeFromBirthDate(DateTime birthDate, {DateTime? now}) {
  final current = now ?? DateTime.now();
  int months =
      (current.year - birthDate.year) * 12 + (current.month - birthDate.month);
  if (current.day < birthDate.day) months--;
  return math.max(0, months);
}

MonthTrackerColorScheme monthTrackerColorSchemeForMonth(int monthAge) {
  final clampedMonth = monthAge.clamp(1, 24);
  return _monthTrackerSchemes[clampedMonth - 1];
}

const List<MonthTrackerColorScheme> _monthTrackerSchemes = [
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFF1F2),
      Color(0xFFFFDDE1),
      Color(0xFFFFC2CC),
      Color(0xFFFFA7B7),
    ],
    textColor: Color(0xFF5A1E2A),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFF4E6),
      Color(0xFFFFE1BF),
      Color(0xFFFFCC99),
      Color(0xFFFFB36B),
    ],
    textColor: Color(0xFF5E3512),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFF9D9),
      Color(0xFFFFF0A8),
      Color(0xFFFFE67A),
      Color(0xFFFFDA4F),
    ],
    textColor: Color(0xFF5A4300),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF2FCD9),
      Color(0xFFE3F8B6),
      Color(0xFFD1F08A),
      Color(0xFFBCE55F),
    ],
    textColor: Color(0xFF27440E),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE7FBE9),
      Color(0xFFC9F2D0),
      Color(0xFFA8E8B7),
      Color(0xFF86DDA0),
    ],
    textColor: Color(0xFF15422A),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE5FDF7),
      Color(0xFFBFF8EA),
      Color(0xFF97EFD9),
      Color(0xFF6EE5C8),
    ],
    textColor: Color(0xFF0F3F39),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE7F9FF),
      Color(0xFFC5EEFF),
      Color(0xFF9EE0FF),
      Color(0xFF73D1FF),
    ],
    textColor: Color(0xFF103B58),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFEAF4FF),
      Color(0xFFCCE2FF),
      Color(0xFFAED0FF),
      Color(0xFF8DBDFF),
    ],
    textColor: Color(0xFF173C66),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFEDF1FF),
      Color(0xFFD8DFFF),
      Color(0xFFC2CBFF),
      Color(0xFFAAB5FF),
    ],
    textColor: Color(0xFF262E66),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF2EEFF),
      Color(0xFFE2D8FF),
      Color(0xFFD0C0FF),
      Color(0xFFBCA7FF),
    ],
    textColor: Color(0xFF3A2862),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF8EEFF),
      Color(0xFFEED6FF),
      Color(0xFFE1BCFF),
      Color(0xFFD39FFF),
    ],
    textColor: Color(0xFF4C255D),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFEEFA),
      Color(0xFFFFD8EF),
      Color(0xFFFFBDDf),
      Color(0xFFFFA0CD),
    ],
    textColor: Color(0xFF5A204A),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFEFF3),
      Color(0xFFFFD5E0),
      Color(0xFFFFB8CB),
      Color(0xFFFF9AAF),
    ],
    textColor: Color(0xFF5C2334),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFF1E8),
      Color(0xFFFFDEC8),
      Color(0xFFFFC7A8),
      Color(0xFFFFAF86),
    ],
    textColor: Color(0xFF5B2F17),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFFF6E7),
      Color(0xFFFFE7BE),
      Color(0xFFFFD793),
      Color(0xFFFFC66A),
    ],
    textColor: Color(0xFF5A3B10),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFFAFAE6),
      Color(0xFFF0F2BF),
      Color(0xFFE4E999),
      Color(0xFFD6DF73),
    ],
    textColor: Color(0xFF47440C),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF2FBE8),
      Color(0xFFDEF2C4),
      Color(0xFFC9E89E),
      Color(0xFFB1DD7B),
    ],
    textColor: Color(0xFF264213),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFEAF9EE),
      Color(0xFFCFF0D9),
      Color(0xFFB1E5C1),
      Color(0xFF91D9A8),
    ],
    textColor: Color(0xFF17412C),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE6FBF6),
      Color(0xFFC6F3E7),
      Color(0xFFA4E9D7),
      Color(0xFF82DFC6),
    ],
    textColor: Color(0xFF114038),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE7F9FA),
      Color(0xFFC9EEF2),
      Color(0xFFA8E1E9),
      Color(0xFF85D4DF),
    ],
    textColor: Color(0xFF103A45),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFE7F2FA),
      Color(0xFFCBE2F4),
      Color(0xFFAED2ED),
      Color(0xFF8EC0E5),
    ],
    textColor: Color(0xFF16395A),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFEBEFFA),
      Color(0xFFD6DCF4),
      Color(0xFFBEC8ED),
      Color(0xFFA5B2E3),
    ],
    textColor: Color(0xFF252F59),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF0EDFA),
      Color(0xFFE0D8F4),
      Color(0xFFCEBFEA),
      Color(0xFFBCA5DF),
    ],
    textColor: Color(0xFF3A2B57),
  ),
  MonthTrackerColorScheme(
    gradientColors: [
      Color(0xFFF6EDFA),
      Color(0xFFEBD7F3),
      Color(0xFFDDBEE8),
      Color(0xFFCFA4DD),
    ],
    textColor: Color(0xFF4B2554),
  ),
];
