import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class MorningStarScanner extends PatternScanner {
  @override
  ScannerType get type => ScannerType.morningStar;

  @override
  String get name => 'Morning Star';

  @override
  Color get color => Colors.yellow.shade800;

  @override
  List<ScannerLayer> scan(List<ICandle> candles) {
    final scanners = <ScannerLayer>[];
    // This is a three-candle pattern, so start at index 2
    for (int i = 2; i < candles.length; i++) {
      final first = candles[i - 2];
      final second = candles[i - 1]; // The "star"
      final third = candles[i];

      // 1. First candle must be bearish (red).
      bool isFirstBearish = first.open > first.close;

      // 2. Second candle (the star) must have a small body and gap down from the first.
      final secondBodySize = (second.close - second.open).abs();
      final secondRange = second.high - second.low;
      bool isStar =
          secondRange > 0 && (secondBodySize / secondRange) < 0.3; // Small body
      bool isGapDown =
          (second.open > second.close ? second.open : second.close) <
              first.close;

      // 3. Third candle must be bullish (green).
      bool isThirdBullish = third.close > third.open;

      // 4. The third candle must close above the midpoint of the first candle's body.
      final firstBodyMidpoint = (first.open + first.close) / 2;
      bool closesAboveMidpoint = third.close > firstBodyMidpoint;

      if (isFirstBearish &&
          isStar &&
          isGapDown &&
          isThirdBullish &&
          closesAboveMidpoint) {
        scanners.add(ScannerLayer(
          scannerType: type,
          label: 'Morning Star',
          targetIndex: i - 1, // Point to the star in the middle
          highlightedIndices: [i - 2, i - 1, i], // Highlight all three candles
          color: color,
        ));
      }
    }
    return scanners;
  }
}
