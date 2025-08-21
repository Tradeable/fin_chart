import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class EngulfingPatternScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bullishEngulfing;

  @override
  String get name => 'Bullish Engulfing';

  @override
  Color get color => Colors.blue.shade700;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // Start at index 1 since we need to look at the previous candle
    for (int i = 1; i < candles.length; i++) {
      final previousCandle = candles[i - 1];
      final currentCandle = candles[i];

      // Bullish Engulfing Criteria:
      // 1. Previous candle is bearish (red).
      // 2. Current candle is bullish (green).
      // 3. Current candle's body "engulfs" the previous candle's body.
      bool isBearishPrevious = previousCandle.open > previousCandle.close;
      bool isBullishCurrent = currentCandle.close > currentCandle.open;
      bool isEngulfing = currentCandle.close > previousCandle.open &&
          currentCandle.open < previousCandle.close;

      if (isBearishPrevious && isBullishCurrent && isEngulfing) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Bullish Engulfing',
          targetIndex: i,
          // Highlight both the current and previous candle
          highlightedIndices: [i - 1, i],
          color: color,
        ));
      }
    }
    return scanners;
  }
}
