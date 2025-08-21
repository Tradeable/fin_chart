import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class InvertedHammerScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.invertedHammer;

  @override
  String get name => 'Inverted Hammer';

  @override
  Color get color => Colors.lightGreen.shade700;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final bodySize = (candle.close - candle.open).abs();
      final upperShadow = candle.high -
          (candle.open > candle.close ? candle.open : candle.close);
      final lowerShadow =
          (candle.open < candle.close ? candle.open : candle.close) -
              candle.low;
      final totalRange = candle.high - candle.low;

      // Inverted Hammer Criteria:
      // 1. Long upper shadow (at least 2x the body size).
      // 2. Very small or no lower shadow.
      // 3. Body is at the lower end of the trading range.
      if (totalRange > 0 &&
          upperShadow >= bodySize * 2 &&
          lowerShadow < bodySize) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Inv Hammer',
          targetIndex: i,
          highlightedIndices: [i], // Highlight just this candle
          color: color,
        ));
      }
    }
    return scanners;
  }
}
