import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class DarkCloudCoverScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.darkCloudCover;

  @override
  String get name => 'Dark Cloud Cover';

  @override
  Color get color => Colors.red.shade700;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a two-candle pattern, so start at index 1
    for (int i = 1; i < candles.length; i++) {
      final first = candles[i - 1];
      final second = candles[i];

      // 1. First candle must be bullish (green).
      bool isFirstBullish = first.close > first.open;

      // 2. Second candle must be bearish (red).
      bool isSecondBearish = second.open > second.close;

      // 3. Second candle must open above the high of the first.
      bool opensAboveHigh = second.open > first.high;

      // 4. Second candle must close below the midpoint of the first candle's body.
      final firstBodyMidpoint = (first.open + first.close) / 2;
      bool closesBelowMidpoint = second.close < firstBodyMidpoint;

      // 5. Second candle must close above the open of the first candle.
      bool closesAboveOpen = second.close > first.open;

      if (isFirstBullish &&
          isSecondBearish &&
          opensAboveHigh &&
          closesBelowMidpoint &&
          closesAboveOpen) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Dark Cloud',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
