import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class BullishHaramiCrossScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bullishHaramiCross;

  @override
  String get name => 'Bullish Harami Cross';

  @override
  Color get color => Colors.lightBlue.shade400;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    const int lookbackPeriod = 10;

    if (candles.length < lookbackPeriod) {
      return scanners;
    }

    // Start at index 1 since we need a previous candle
    for (int i = 1; i < candles.length; i++) {
      final previousCandle = candles[i - 1];
      final currentCandle = candles[i];

      // 1. Previous candle must be bearish (red)
      if (previousCandle.open <= previousCandle.close) continue;

      // 2. Check if the current candle is a Doji
      final currentBodySize = (currentCandle.close - currentCandle.open).abs();
      final currentTotalRange = currentCandle.high - currentCandle.low;
      // A Doji has a very small body compared to its total range
      bool isDoji =
          currentTotalRange > 0 && (currentBodySize / currentTotalRange) < 0.1;

      if (!isDoji) continue;

      // 3. The body of the Doji must be contained within the body of the previous (red) candle
      bool isHarami = currentCandle.high < previousCandle.open &&
          currentCandle.low > previousCandle.close;

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
          label: 'Bullish Harami Cross',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
