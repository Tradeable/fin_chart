import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class BearishHaramiCrossScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bearishHaramiCross;

  @override
  String get name => 'Bearish Harami Cross';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    const int lookbackPeriod = 10;

    if (candles.length < lookbackPeriod) {
      return scanners;
    }

    // Start at index 1 since we need a previous candle
    for (int i = lookbackPeriod; i < candles.length; i++) {
      final previousCandle = candles[i - 1];
      final currentCandle = candles[i];

      // 1. Previous candle must be bullish (green)
      if (previousCandle.close <= previousCandle.open) continue;

      // 2. Check if the current candle is a Doji
      final currentBodySize = (currentCandle.close - currentCandle.open).abs();
      final currentTotalRange = currentCandle.high - currentCandle.low;
      // A Doji has a very small body compared to its total range
      bool isDoji =
          currentTotalRange > 0 && (currentBodySize / currentTotalRange) < 0.1;

      if (!isDoji) continue;

      // 3. The body of the Doji must be contained within the body of the previous (green) candle
      bool isHarami = currentCandle.high < previousCandle.close &&
          currentCandle.low > previousCandle.open;

      // 4. Check if the previous candle was relatively "long"
      double avgBodySize = 0;
      for (int j = i - lookbackPeriod; j < i; j++) {
        avgBodySize += (candles[j].close - candles[j].open).abs();
      }
      avgBodySize /= lookbackPeriod;

      final previousBodySize = previousCandle.close - previousCandle.open;
      bool isPreviousLong = previousBodySize > avgBodySize;

      if (isHarami && isPreviousLong) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Bearish Harami Cross',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
        ));
      }
    }
    return scanners;
  }
}
