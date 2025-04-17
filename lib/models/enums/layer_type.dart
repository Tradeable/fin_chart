enum LayerType {
  circularArea,
  label,
  horizontalLine,
  horizontalBand,
  trendLine,
  rectArea,
  arrow,
  verticalLine,
  parallelChannel,
  arrowTextPointer,
  anchorText
}

extension LayerTypeExtension on LayerType {
  String get name {
    return toString().split('.').last;
  }
}

extension LayerTypeParsingExtension on String {
  LayerType? toLayerType({bool ignoreCase = true}) {
    final input = ignoreCase ? toLowerCase() : this;

    for (final type in LayerType.values) {
      final typeName = type.toString().split('.').last;
      final compareValue = ignoreCase ? typeName.toLowerCase() : typeName;

      if (input == compareValue) {
        return type;
      }
    }

    return null;
  }
}
