import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:flutter/material.dart';

class HammerScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.hammer;

  @override
  Color get color => Colors.green.shade700;

  @override
  String get name => 'Hammer Candlestick';

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
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
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Hammer',
          targetIndex: i,
          highlightedIndices: [i],
          color: color,
        ));
      }
    }
    return scanners;
  }
}
