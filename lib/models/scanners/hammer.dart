import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class HammerScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.hammer;

  @override
  String get name => 'Hammer Candlestick';

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

      if (totalRange > 0 &&
          bodySize < totalRange * 0.33 &&
          lowerShadow >= bodySize * 2 &&
          upperShadow < bodySize * 0.5) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Hammer',
          targetIndex: i,
          highlightedIndices: [i],
        ));
      }
    }
    return scanners;
  }
}
