class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.childId,
    required this.timestamp,
    required this.title,
    required this.body,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String childId;
  final DateTime timestamp;
  final String title;
  final String body;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}
