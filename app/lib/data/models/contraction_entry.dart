class ContractionEntry {
  const ContractionEntry({
    required this.id,
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    this.intensity,
  });

  final String id;
  final String sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? intensity;

  Duration? get duration => endedAt?.difference(startedAt);
}
