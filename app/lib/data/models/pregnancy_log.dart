import 'package:aegi/core/enums/pregnancy_log_type.dart';

class PregnancyLog {
  const PregnancyLog({
    required this.id,
    required this.childId,
    required this.type,
    required this.timestamp,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final PregnancyLogType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
}
