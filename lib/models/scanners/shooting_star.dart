import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class ShootingStarScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.shootingStar;

  @override
  String get name => 'Shooting Star';

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

      // Shooting Star Criteria:
      // 1. Long upper shadow (at least 2x the body size).
      // 2. Very small or no lower shadow.
      // 3. Body is at the lower end of the trading range.
      if (totalRange > 0 &&
          upperShadow >= bodySize * 2 &&
          lowerShadow < bodySize) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Shooting Star',
          targetIndex: i,
          highlightedIndices: [i], // Highlight just this candle
        ));
      }
    }
    return scanners;
  }
}
