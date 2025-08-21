import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class ThreeWhiteSoldiersScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.threeWhiteSoldiers;

  @override
  String get name => 'Three White Soldiers';

  @override
  Color get color => Colors.lightGreen.shade600;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final first = candles[i - 2];
      final second = candles[i - 1];
      final third = candles[i];

      // 1. All three candles must be bullish (green).
      bool areAllBullish = (first.close > first.open) &&
          (second.close > second.open) &&
          (third.close > third.open);

      if (!areAllBullish) continue;

      // 2. Each candle should open within the previous candle's body.
      bool opensInBody =
          (second.open > first.open && second.open < first.close) &&
              (third.open > second.open && third.open < second.close);

      // 3. Each candle should close higher than the previous candle's high.
      bool closesHigher =
          second.close > first.high && third.close > second.high;

      // 4. Each candle should have a relatively small upper wick (strong close).
      final firstBody = first.close - first.open;
      final secondBody = second.close - second.open;
      final thirdBody = third.close - third.open;
      bool smallWicks = (first.high - first.close) < firstBody * 0.3 &&
          (second.high - second.close) < secondBody * 0.3 &&
          (third.high - third.close) < thirdBody * 0.3;

      if (opensInBody && closesHigher && smallWicks) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: '3W Soldiers',
          targetIndex: i,
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
