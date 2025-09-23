enum MCQArrangementType { grid1x2, grid2x2, grid2x3 }

extension MCQArrangementTypeParsingExtension on String {
  MCQArrangementType toMCQArrangementType({bool ignoreCase = true}) {
    final input = ignoreCase ? toLowerCase() : this;

    for (final type in MCQArrangementType.values) {
      final typeName = type.toString().split('.').last;
      final compareValue = ignoreCase ? typeName.toLowerCase() : typeName;

      if (input == compareValue) {
        return type;
      }
    }

    return MCQArrangementType.grid2x2;
  }
}
