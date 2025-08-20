import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';

abstract class PatternScanner {
  /// The unique type of this scanner.
  ScannerType get type;

  /// A user-friendly name for the scanner.
  String get name;

  /// The core logic that scans data and returns visual layers.
  List<ScannerLayer> scan(List<ICandle> candles);
}
