class ContractionSession {
  const ContractionSession({
    required this.id,
    required this.childId,
    required this.startedAt,
    this.endedAt,
  });

  final String id;
  final String childId;
  final DateTime startedAt;
  final DateTime? endedAt;
}
