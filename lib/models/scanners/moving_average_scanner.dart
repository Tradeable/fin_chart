import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';
import 'package:fin_chart/models/enums/scanner_display_type.dart';
import 'package:flutter/material.dart';

enum MovingAverageType { sMA, eMA }

class MovingAverageScanner extends PatternScanner {
  final int period;
  final MovingAverageType maType;
  final PriceComparison comparison;
  final ScannerType _type;

  MovingAverageScanner({
    required this.period,
    required this.maType,
    required this.comparison,
    required ScannerType type,
  }) : _type = type;

  @override
  ScannerDisplayType get displayType => ScannerDisplayType.areaShade;

  @override
  ScannerType get type => _type;

  @override
  String get name =>
      'Price ${comparison == PriceComparison.above ? 'Above' : 'Below'} ${period}D ${maType.name}';

  String get label =>
      'Price ${comparison == PriceComparison.above ? '>' : '<'} $period${maType.name}';

  List<double> _calculateSMA(List<ICandle> candles, int period) {
    List<double> smaValues = [];
    if (candles.length < period) {
      return smaValues;
    }

    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        smaValues.add(0); // Placeholder for earlier values
      } else {
        double sum = 0;
        for (int j = i - (period - 1); j <= i; j++) {
          sum += candles[j].close;
        }
        smaValues.add(sum / period);
      }
    }
    return smaValues;
  }

  List<double> _calculateEMA(List<ICandle> candles, int period) {
    List<double> emaValues = [];
    if (candles.length < period) {
      return emaValues;
    }
    double smoothing = 2.0 / (period + 1);
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
    }
    double firstEma = sum / period;
    for (int i = 0; i < period - 1; i++) {
      emaValues.add(0);
    }
    emaValues.add(firstEma);
    for (int i = period; i < candles.length; i++) {
      double currentPrice = candles[i].close;
      double previousEma = emaValues.last;
      double currentEma =
          (currentPrice - previousEma) * smoothing + previousEma;
      emaValues.add(currentEma);
    }
    return emaValues;
  }

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    if (candles.length < period) {
      return scanners;
    }

    final maValues = maType == MovingAverageType.sMA
        ? _calculateSMA(candles, period)
        : _calculateEMA(candles, period);

    for (int i = period - 1; i < candles.length; i++) {
      final candle = candles[i];
      final maValue = maValues[i];

      if (maValue == 0) continue; // Skip placeholders

      bool conditionMet = false;
      Color? color;
      if (comparison == PriceComparison.above) {
        if (candle.close > maValue) {
          conditionMet = true;
          color = Colors.green;
        }
      } else {
        if (candle.close < maValue) {
          conditionMet = true;
          color = Colors.red;
        }
      }

      if (conditionMet) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: label,
          targetIndex: i,
          highlightedIndices: [i],
          highlightColor: color,
        ));
      }
    }
    return scanners;
  }
}
