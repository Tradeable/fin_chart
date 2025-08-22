import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class BearishEngulfingScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bearishEngulfing;

  @override
  String get name => 'Bearish Engulfing';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    // Start at index 1 since we need to look at the previous candle
    for (int i = 1; i < candles.length; i++) {
      final previousCandle = candles[i - 1];
      final currentCandle = candles[i];

      // Bearish Engulfing Criteria:
      // 1. Previous candle is bullish (green).
      // 2. Current candle is bearish (red).
      // 3. Current candle's body "engulfs" the previous candle's body.
      bool isBullishPrevious = previousCandle.close > previousCandle.open;
      bool isBearishCurrent = currentCandle.open > currentCandle.close;
      bool isEngulfing = currentCandle.open > previousCandle.close &&
          currentCandle.close < previousCandle.open;

      if (isBullishPrevious && isBearishCurrent && isEngulfing) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Bearish Engulfing',
          targetIndex: i,
          // Highlight both the current and previous candle
          highlightedIndices: [i - 1, i],
        ));
      }
    }
    return scanners;
  }
}
