import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

List<String> babyLogTitle(BabyLog log) {
  switch (log.type) {
    case BabyLogType.bottleFeed:
      final amount = (log.metadata['amount'] as num?)?.toDouble()
          ?? (log.metadata['amountOz'] as num?)?.toDouble();
      final unit = (log.metadata['unit'] as String?) ?? 'oz';
      return amount != null
          ? ['Feed', '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} $unit']
          : ['Feed', '--'];
    case BabyLogType.breastMilk:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      final side = log.metadata['side'] as String?;
      final parts = <String>[];
      if (duration != null) parts.add('$duration min');
      if (side != null) parts.add(side.toUpperCase());
      return ["Feed", (parts.isNotEmpty ? parts.join(' - ') : 'Breast milk')];
    case BabyLogType.diaperWet:
      return ["Diaper", "Wet"];
    case BabyLogType.diaperDirty:
      return ["Diaper", "Dirty"];
    case BabyLogType.nap:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      return ["Nap", "$duration min"];
    case BabyLogType.nightSleep:
      final duration = (log.metadata['durationMin'] as num?)?.toInt();
      return ["Sleep", "$duration min"];
  }
}

(IconData, Color) babyLogIconAndColor(BabyLogType type) {
  return switch (type) {
    BabyLogType.bottleFeed => (Symbols.pediatrics_rounded, const Color(0xFFA8DADC)),
    BabyLogType.breastMilk => (Symbols.breastfeeding_rounded, const Color(0xFFB5C7ED)),
    BabyLogType.diaperWet => (Icons.water_drop_outlined, const Color(0xFF90BE6D)),
    BabyLogType.diaperDirty => (Icons.cloud_outlined, const Color(0xFFF6BD60)),
    BabyLogType.nap => (Icons.bedtime_outlined, const Color(0xFF84A59D)),
    BabyLogType.nightSleep => (Icons.nights_stay_outlined, const Color(0xFFF28482)),
  };
}
