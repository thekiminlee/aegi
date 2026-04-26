import 'package:aegi/core/enums/units.dart';

class AppSettings {
  const AppSettings({
    required this.selectedChildId,
    required this.volumeUnit,
    required this.weightUnit,
    required this.lengthUnit,
    required this.temperatureUnit,
    required this.notificationsEnabled,
    required this.weeklyPregnancyReminderEnabled,
    required this.trackingReminderEnabled,
  });

  final String selectedChildId;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  final TemperatureUnit temperatureUnit;
  final bool notificationsEnabled;
  final bool weeklyPregnancyReminderEnabled;
  final bool trackingReminderEnabled;
}
