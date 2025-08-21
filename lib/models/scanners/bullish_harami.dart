import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:flutter/material.dart';

class BullishHaramiScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bullishHarami;

  @override
  String get name => 'Bullish Harami';

  @override
  Color get color => Colors.cyan.shade600;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    const int lookbackPeriod = 10;

    if (candles.length < lookbackPeriod) {
      return scanners;
    }

    // Start at index 1 since we need a previous candle
    for (int i = lookbackPeriod; i < candles.length; i++) {
      final previousCandle = candles[i - 1];
      final currentCandle = candles[i];

      // 1. Previous candle must be bearish (red)
      if (previousCandle.open <= previousCandle.close) continue;

      // 2. Current candle must be bullish (green)
      if (currentCandle.close <= currentCandle.open) continue;

      // 3. The body of the current (green) candle must be contained within the body of the previous (red) candle
      bool isHarami = currentCandle.close < previousCandle.open &&
          currentCandle.open > previousCandle.close;

      // 4. Check if the previous candle was relatively "long"
      double avgBodySize = 0;
      for (int j = i - lookbackPeriod; j < i; j++) {
        avgBodySize += (candles[j].close - candles[j].open).abs();
      }
      avgBodySize /= lookbackPeriod;

      final previousBodySize = previousCandle.open - previousCandle.close;
      bool isPreviousLong = previousBodySize > avgBodySize;

      if (isHarami && isPreviousLong) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Bullish Harami',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
