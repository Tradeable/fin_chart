import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class HangingManScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.hangingMan;

  @override
  String get name => 'Hanging Man';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final bodySize = (candle.close - candle.open).abs();
      final upperShadow = candle.high -
          (candle.open > candle.close ? candle.open : candle.close);
      final lowerShadow =
          (candle.open < candle.close ? candle.open : candle.close) -
              candle.low;
      final totalRange = candle.high - candle.low;

      // Hanging Man Criteria (identical shape to Hammer):
      // 1. Body is in the upper third of the candle.
      // 2. Lower shadow is at least 2x the body size.
      // 3. Very small or no upper shadow.
      if (totalRange > 0 &&
          bodySize < totalRange * 0.33 &&
          lowerShadow >= bodySize * 2 &&
          upperShadow < bodySize * 0.5) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Hanging Man',
          targetIndex: i,
          highlightedIndices: [i], // Highlight just this candle
        ));
      }
    }
    return scanners;
  }
}
