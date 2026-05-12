import 'package:aegi/core/enums/baby_log_type.dart';

class BabyLog {
  const BabyLog({
    required this.id,
    required this.childId,
    required this.type,
    required this.timestamp,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final BabyLogType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
}
