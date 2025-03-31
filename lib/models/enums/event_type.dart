enum EventType {
  earnings,
  dividend,
  stockSplit,
}

extension EventTypeParsingExtension on String {
  EventType toEventType({bool ignoreCase = true}) {
    final input = ignoreCase ? toLowerCase() : this;

    for (final type in EventType.values) {
      final typeName = type.toString().split('.').last;
      final compareValue = ignoreCase ? typeName.toLowerCase() : typeName;

      if (input == compareValue) {
        return type;
      }
    }

    return EventType.earnings; // Default
  }
}