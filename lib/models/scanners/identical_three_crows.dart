import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class IdenticalThreeCrowsScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.identicalThreeCrows;

  @override
  String get name => 'Identical Three Crows';

  @override
  Color get color => Colors.red.shade900;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final first = candles[i - 2];
      final second = candles[i - 1];
      final third = candles[i];

      // 1. All three candles must be bearish (red).
      bool areAllBearish = (first.open > first.close) &&
          (second.open > second.close) &&
          (third.open > third.close);

      if (!areAllBearish) continue;

      // 2. Each candle should open at or very near the close of the previous one.
      // We'll use a small tolerance (e.g., 5% of the previous candle's range).
      final firstRange = first.high - first.low;
      final secondRange = second.high - second.low;
      bool opensAtPrevClose =
          (second.open - first.close).abs() < (firstRange * 0.05) &&
              (third.open - second.close).abs() < (secondRange * 0.05);

      // 3. Each candle should close progressively lower.
      bool closesLower =
          second.close < first.close && third.close < second.close;

      // 4. Each candle should have a very small lower wick.
      bool smallLowerWicks = (first.close - first.low) < (firstRange * 0.1) &&
          (second.close - second.low) < (secondRange * 0.1) &&
          (third.close - third.low) < ((third.high - third.low) * 0.1);

      if (opensAtPrevClose && closesLower && smallLowerWicks) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: '3 Crows',
          targetIndex: i,
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
