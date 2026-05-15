class TimelineEntry<T> {
  const TimelineEntry({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.data,
  });

  final String id;
  final DateTime timestamp;
  final String category;
  final T data;
}

class TimelineFilterCategory {
  const TimelineFilterCategory({
    required this.key,
    required this.label,
    this.matchesAll = false,
  });

  final String key;
  final String label;
  final bool matchesAll;
}
