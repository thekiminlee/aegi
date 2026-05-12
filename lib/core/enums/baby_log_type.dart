enum BabyLogType {
  bottleFeed,
  breastMilk,
  diaperWet,
  diaperDirty,
  nap,
  nightSleep,
}

extension BabyLogTypeCodec on BabyLogType {
  int get storedValue => switch (this) {
    BabyLogType.bottleFeed => 0,
    BabyLogType.breastMilk => 1,
    BabyLogType.diaperWet => 2,
    BabyLogType.diaperDirty => 3,
    BabyLogType.nap => 4,
    BabyLogType.nightSleep => 5,
  };

  static BabyLogType fromStoredValue(int value) {
    return switch (value) {
      0 => BabyLogType.bottleFeed,
      1 => BabyLogType.breastMilk,
      2 => BabyLogType.diaperWet,
      3 => BabyLogType.diaperDirty,
      4 => BabyLogType.nap,
      5 => BabyLogType.nightSleep,
      _ => BabyLogType.bottleFeed,
    };
  }
}
