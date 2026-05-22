import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

String bottleFeedKind(BabyLog log) {
  final kind = log.metadata['feedKind'] as String?;
  return kind == 'expressed' ? 'expressed' : 'formula';
}

List<String> babyLogTitle(
  BabyLog log, {
  VolumeUnit volumeUnit = VolumeUnit.oz,
}) {
  switch (log.type) {
    case BabyLogType.bottleFeed:
      final amount = (log.metadata['displayAmount'] as num?)?.toDouble();
      final unitLabel = volumeUnit.name;
      final kindLabel = switch (bottleFeedKind(log)) {
        'expressed' => 'Expressed',
        _ => 'Formula',
      };
      return amount != null
          ? [
              kindLabel,
              '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} $unitLabel',
            ]
          : [kindLabel, '--'];
    case BabyLogType.breastMilk:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      final side = log.metadata['side'] as String?;
      final parts = <String>[];
      if (duration != null) parts.add('$duration min');
      if (side != null) parts.add(side.toUpperCase());
      return [
        "Breast Feed",
        (parts.isNotEmpty ? parts.join(' - ') : 'Breast feed'),
      ];
    case BabyLogType.diaperWet:
      return ["Diaper", "Wet"];
    case BabyLogType.diaperDirty:
      return ["Diaper", "Dirty"];
    case BabyLogType.nap:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      return ["Nap", duration == null ? '--' : "$duration min"];
    case BabyLogType.nightSleep:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      return ["Sleep", duration == null ? '--' : "$duration min"];
  }
}

(IconData, Color) babyLogIconAndColor(BabyLogType type) {
  return switch (type) {
    BabyLogType.bottleFeed => (
      Symbols.pediatrics_rounded,
      const Color(0xFFA8DADC),
    ),
    BabyLogType.breastMilk => (
      Symbols.breastfeeding_rounded,
      const Color(0xFFB5C7ED),
    ),
    BabyLogType.diaperWet => (
      Symbols.humidity_high,
      const Color(0xFF90BE6D),
    ),
    BabyLogType.diaperDirty => (Icons.cloud_outlined, const Color(0xFFF6BD60)),
    BabyLogType.nap => (Icons.bedtime_outlined, const Color(0xFF84A59D)),
    BabyLogType.nightSleep => (
      Icons.nights_stay_outlined,
      const Color(0xFFF28482),
    ),
  };
}
