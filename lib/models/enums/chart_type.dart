enum ChartType {
  candlestick,
  line,
}

extension ChartTypeParsingExtension on String {
  ChartType toChartType({bool ignoreCase = true}) {
    final input = ignoreCase ? toLowerCase() : this;

    for (final type in ChartType.values) {
      final typeName = type.toString().split('.').last;
      final compareValue = ignoreCase ? typeName.toLowerCase() : typeName;

      if (input == compareValue) {
        return type;
      }
    }

    return ChartType.candlestick; // Default
  }
}
