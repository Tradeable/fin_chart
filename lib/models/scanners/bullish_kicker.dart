import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class BullishKickerScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bullishKicker;

  @override
  String get name => 'Bullish Kicker';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    // This is a two-candle pattern, so start at index 1
    for (int i = 1; i < candles.length; i++) {
      final first = candles[i - 1];
      final second = candles[i];

      // 1. First candle must be bearish (red).
      bool isFirstBearish = first.open > first.close;

      // 2. Second candle must be bullish (green).
      bool isSecondBullish = second.close > second.open;

      // 3. The open of the second candle must be higher than the high of the first candle (the gap up).
      bool isGapUp = second.open > first.high;

      if (isFirstBearish && isSecondBullish && isGapUp) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Kicker',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
        ));
      }
    }
    return scanners;
  }
}
