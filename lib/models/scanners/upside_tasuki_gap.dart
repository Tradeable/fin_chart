import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class UpsideTasukiGapScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.upsideTasukiGap;

  @override
  String get name => 'Upside Tasuki Gap';

  @override
  Color get color => Colors.teal.shade600;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final firstCandle = candles[i - 2];
      final secondCandle = candles[i - 1];
      final thirdCandle = candles[i];

      // 1. First candle must be bullish (green).
      bool isFirstBullish = firstCandle.close > firstCandle.open;

      // 2. Second candle must be bullish and gap up from the first.
      bool isSecondBullish = secondCandle.close > secondCandle.open;
      bool isGapUp = secondCandle.low > firstCandle.high;

      // 3. Third candle must be bearish (red).
      bool isThirdBearish = thirdCandle.open > thirdCandle.close;

      // 4. Third candle opens within the body of the second.
      bool opensInBody = thirdCandle.open < secondCandle.close &&
          thirdCandle.open > secondCandle.open;

      // 5. Third candle closes within the gap.
      bool closesInGap = thirdCandle.close > firstCandle.high &&
          thirdCandle.close < secondCandle.low;

      if (isFirstBullish &&
          isSecondBullish &&
          isGapUp &&
          isThirdBearish &&
          opensInBody &&
          closesInGap) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'U Tasuki Gap',
          targetIndex: i,
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
