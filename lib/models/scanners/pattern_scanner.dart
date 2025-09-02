import 'package:fin_chart/models/enums/scanner_display_type.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';

abstract class PatternScanner {
  ScannerType get type;
  String get name;
  // Color get color;
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData});
  ScannerDisplayType get displayType => ScannerDisplayType.labelBox;
}
