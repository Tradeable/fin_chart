import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class BearishHaramiScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bearishHarami;

  @override
  String get name => 'Bearish Harami';

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

      // 2. Current candle must be bearish (red)
      if (currentCandle.open <= currentCandle.close) continue;

      // 3. The body of the current (red) candle must be contained within the body of the previous (green) candle
      bool isHarami = currentCandle.open < previousCandle.close &&
          currentCandle.close > previousCandle.open;

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
          label: 'Bearish Harami',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
        ));
      }
    }
    return scanners;
  }
}
