import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

class DragonflyDojiScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.dragonflyDoji;

  @override
  String get name => 'Dragonfly Doji';

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final totalRange = candle.high - candle.low;
      final bodySize = (candle.open - candle.close).abs();

      // Criteria for Dragonfly Doji:
      // 1. Body is extremely small (a tiny percentage of the total range).
      // 2. The close is near the high (very small upper shadow).
      bool isDojiBody = totalRange > 0 && (bodySize / totalRange) < 0.1;
      bool isNearHigh = (candle.high - candle.close) < (totalRange * 0.1);

      if (isDojiBody && isNearHigh) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: 'Doji',
          targetIndex: i,
          highlightedIndices: [i],
        ));
      }
    }
    return scanners;
  }
}
