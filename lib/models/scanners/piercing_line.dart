import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class PiercingLineScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.piercingLine;

  @override
  String get name => 'Piercing Line';

  @override
  Color get color => Colors.lightGreen.shade500;

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

      // 3. Second candle must open below the low of the first.
      bool opensBelowLow = second.open < first.low;

      // 4. Second candle must close above the midpoint of the first candle's body.
      final firstBodyMidpoint = (first.open + first.close) / 2;
      bool closesAboveMidpoint = second.close > firstBodyMidpoint;

      // 5. Second candle must close below the open of the first candle.
      bool closesBelowOpen = second.close < first.open;

      if (isFirstBearish &&
          isSecondBullish &&
          opensBelowLow &&
          closesAboveMidpoint &&
          closesBelowOpen) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Piercing Line',
          targetIndex: i,
          highlightedIndices: [i - 1, i], // Highlight both candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
