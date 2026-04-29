enum PregnancyLogType {
  kickCounter,
  waterIntake,
  weight,
  bloodPressure,
  medication,
  mood,
}

extension PregnancyLogTypeCodec on PregnancyLogType {
  int get storedValue => switch (this) {
    PregnancyLogType.kickCounter => 0,
    PregnancyLogType.bloodPressure => 1,
    PregnancyLogType.waterIntake => 2,
    PregnancyLogType.medication => 3,
    PregnancyLogType.weight => 5,
    PregnancyLogType.mood => 6,
  };

  static PregnancyLogType fromStoredValue(int value) {
    return switch (value) {
      0 => PregnancyLogType.kickCounter,
      1 => PregnancyLogType.bloodPressure,
      2 => PregnancyLogType.waterIntake,
      3 => PregnancyLogType.medication,
      4 => PregnancyLogType.medication,
      5 => PregnancyLogType.weight,
      6 => PregnancyLogType.mood,
      _ => PregnancyLogType.medication,
    };
  }
}
