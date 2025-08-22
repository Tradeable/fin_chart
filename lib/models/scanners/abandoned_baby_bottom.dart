import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class AbandonedBabyBottomScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.abandonedBabyBottom;

  @override
  String get name => 'Abandoned Baby Bottom';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final first = candles[i - 2];
      final doji = candles[i - 1];
      final third = candles[i];

      // 1. First candle must be bearish (red).
      bool isFirstBearish = first.open > first.close;

      // 2. Second candle must be a Doji.
      final dojiBodySize = (doji.close - doji.open).abs();
      final dojiTotalRange = doji.high - doji.low;
      bool isDoji = dojiTotalRange > 0 && (dojiBodySize / dojiTotalRange) < 0.1;

      // 3. The Doji must gap down, with no shadow overlap.
      bool isGapDown = doji.high < first.low;

      // 4. Third candle must be bullish (green).
      bool isThirdBullish = third.close > third.open;

      // 5. The third candle must gap up from the Doji, with no shadow overlap.
      bool isGapUp = third.low > doji.high;

      // 6. The third candle should close well into the body of the first candle.
      bool closesInBody = third.close > (first.open + first.close) / 2;

      if (isFirstBearish &&
          isDoji &&
          isGapDown &&
          isThirdBullish &&
          isGapUp &&
          closesInBody) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Abandoned Baby B',
          targetIndex: i - 1, // Point to the Doji in the middle
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
        ));
      }
    }
    return scanners;
  }
}
