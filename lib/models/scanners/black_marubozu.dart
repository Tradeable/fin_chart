import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:flutter/material.dart';

class BlackMarubozuScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.blackMarubozu;

  @override
  String get name => 'Black Marubozu';

  @override
  Color get color => Colors.red.shade700;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    const int lookbackPeriod = 10; // Period to average body size

    if (candles.length < lookbackPeriod) {
      return scanners; // Not enough data
    }

    for (int i = lookbackPeriod; i < candles.length; i++) {
      final candle = candles[i];

      // 1. Must be a bearish candle
      if (candle.open <= candle.close) continue;

      // 2. Calculate the average body size over the lookback period
      double avgBodySize = 0;
      for (int j = i - lookbackPeriod; j < i; j++) {
        avgBodySize += (candles[j].close - candles[j].open).abs();
      }
      avgBodySize /= lookbackPeriod;

      final bodySize = candle.open - candle.close;
      final totalRange = candle.high - candle.low;

      // 3. A "long" body is significantly larger than the average
      bool isLongBody = bodySize > (avgBodySize * 1.5);

      // 4. Shadows should be tiny (e.g., less than 5% of the total range)
      final shadowThreshold = totalRange * 0.05;
      bool hasNoShadows = (candle.high - candle.open) < shadowThreshold &&
          (candle.close - candle.low) < shadowThreshold;

      if (isLongBody && hasNoShadows) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'B Marubozu',
          targetIndex: i,
          highlightedIndices: [i],
          color: color,
        ));
      }
    }
    return scanners;
  }
}
