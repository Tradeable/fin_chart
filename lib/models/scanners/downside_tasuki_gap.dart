import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class DownsideTasukiGapScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.downsideTasukiGap;

  @override
  String get name => 'Downside Tasuki Gap';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final firstCandle = candles[i - 2];
      final secondCandle = candles[i - 1];
      final thirdCandle = candles[i];

      // 1. First candle must be bearish (red).
      bool isFirstBearish = firstCandle.open > firstCandle.close;

      // 2. Second candle must be bearish and gap down from the first.
      bool isSecondBearish = secondCandle.open > secondCandle.close;
      bool isGapDown = secondCandle.high < firstCandle.low;

      // 3. Third candle must be bullish (green).
      bool isThirdBullish = thirdCandle.close > thirdCandle.open;

      // 4. Third candle opens within the body of the second.
      bool opensInBody = thirdCandle.open > secondCandle.close &&
          thirdCandle.open < secondCandle.open;

      // 5. Third candle closes within the gap.
      bool closesInGap = thirdCandle.close < firstCandle.low &&
          thirdCandle.close > secondCandle.high;

      if (isFirstBearish &&
          isSecondBearish &&
          isGapDown &&
          isThirdBullish &&
          opensInBody &&
          closesInGap) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'D Tasuki Gap',
          targetIndex: i,
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
        ));
      }
    }
    return scanners;
  }
}
