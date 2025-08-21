import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class AbandonedBabyTopScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.abandonedBabyTop;

  @override
  String get name => 'Abandoned Baby Top';

  @override
  Color get color => Colors.purple.shade700;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final first = candles[i - 2];
      final doji = candles[i - 1];
      final third = candles[i];

      // 1. First candle must be bullish (green).
      bool isFirstBullish = first.close > first.open;

      // 2. Second candle must be a Doji.
      final dojiBodySize = (doji.close - doji.open).abs();
      final dojiTotalRange = doji.high - doji.low;
      bool isDoji = dojiTotalRange > 0 && (dojiBodySize / dojiTotalRange) < 0.1;

      // 3. The Doji must gap up, with no shadow overlap.
      bool isGapUp = doji.low > first.high;

      // 4. Third candle must be bearish (red).
      bool isThirdBearish = third.open > third.close;

      // 5. The third candle must gap down from the Doji, with no shadow overlap.
      bool isGapDown = third.high < doji.low;

      // 6. The third candle should close well into the body of the first candle.
      bool closesInBody = third.close < (first.open + first.close) / 2;

      if (isFirstBullish &&
          isDoji &&
          isGapUp &&
          isThirdBearish &&
          isGapDown &&
          closesInBody) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Abandoned Baby T',
          targetIndex: i - 1, // Point to the Doji in the middle
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
