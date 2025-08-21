import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class HangingManScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.hangingMan;

  @override
  String get name => 'Hanging Man';

  @override
  Color get color => Colors.orange.shade700;

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

      // Hanging Man Criteria (identical shape to Hammer):
      // 1. Body is in the upper third of the candle.
      // 2. Lower shadow is at least 2x the body size.
      // 3. Very small or no upper shadow.
      if (totalRange > 0 &&
          bodySize < totalRange * 0.33 &&
          lowerShadow >= bodySize * 2 &&
          upperShadow < bodySize * 0.5) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Hanging Man',
          targetIndex: i,
          highlightedIndices: [i], // Highlight just this candle
          color: color,
        ));
      }
    }
    return scanners;
  }
}
