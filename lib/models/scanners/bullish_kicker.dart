import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class BullishKickerScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.bullishKicker;

  @override
  String get name => 'Bullish Kicker';

  @override
  Color get color => Colors.blue.shade600;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
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
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Kicker',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
