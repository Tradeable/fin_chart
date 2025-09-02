import 'dart:math' as math;
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';
import 'package:fin_chart/models/enums/scanner_display_type.dart';
import 'package:flutter/material.dart';

enum OscillatorType { mFI }

class OscillatorScanner extends PatternScanner {
  final OscillatorType oscillatorType;
  final int period;
  final double threshold;
  final PriceComparison comparison;
  final ScannerType _type;

  OscillatorScanner({
    required this.oscillatorType,
    required this.period,
    required this.threshold,
    required this.comparison,
    required ScannerType type,
  }) : _type = type;

  @override
  ScannerDisplayType get displayType => ScannerDisplayType.areaShade;

  @override
  ScannerType get type => _type;

  @override
  String get name {
    String condition =
        comparison == PriceComparison.above ? 'Overbought' : 'Oversold';
    return '${oscillatorType.name} $condition';
  }

  String get label =>
      '${oscillatorType.name} ${comparison == PriceComparison.above ? '>' : '<'} ${threshold.toInt()}';

  List<double> _calculateMFI(List<ICandle> candles) {
    List<double> mfiValues = [];
    if (candles.length <= period) {
      return mfiValues;
    }

    List<double> typicalPrices = [];
    List<double> positiveFlows = [];
    List<double> negativeFlows = [];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      typicalPrices.add(typicalPrice);
      final rawMoneyFlow = typicalPrice * candle.volume;

      if (i > 0) {
        if (typicalPrice > typicalPrices[i - 1]) {
          positiveFlows.add(rawMoneyFlow);
          negativeFlows.add(0);
        } else if (typicalPrice < typicalPrices[i - 1]) {
          positiveFlows.add(0);
          negativeFlows.add(rawMoneyFlow);
        } else {
          positiveFlows.add(0);
          negativeFlows.add(0);
        }
      } else {
        positiveFlows.add(0);
        negativeFlows.add(0);
      }
    }

    for (int i = period; i < candles.length; i++) {
      double sumPositiveFlow = 0;
      double sumNegativeFlow = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sumPositiveFlow += positiveFlows[j];
        sumNegativeFlow += negativeFlows[j];
      }
      double moneyRatio =
          sumNegativeFlow == 0 ? 100 : sumPositiveFlow / sumNegativeFlow;
      double mfiValue = 100 - (100 / (1 + moneyRatio));
      mfiValue = math.min(100, math.max(0, mfiValue));
      mfiValues.add(mfiValue);
    }
    return mfiValues;
  }

  @override
  List<ScannerResult> scan(List<ICandle> candles, {TrendData? trendData}) {
    final scanners = <ScannerResult>[];
    if (candles.length <= period) {
      return scanners;
    }

    final oscillatorValues = _calculateMFI(candles);
    int startIndex = period;

    for (int i = 0; i < oscillatorValues.length; i++) {
      final value = oscillatorValues[i];
      final candleIndex = startIndex + i;

      bool conditionMet = false;
      Color? color;

      if (comparison == PriceComparison.above) {
        if (value > threshold) {
          conditionMet = true;
          color = Colors.red; // Overbought is typically bearish/red
        }
      } else {
        // Below
        if (value < threshold) {
          conditionMet = true;
          color = Colors.green; // Oversold is typically bullish/green
        }
      }

      if (conditionMet) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: label,
          targetIndex: candleIndex,
          highlightedIndices: [candleIndex],
          highlightColor: color,
        ));
      }
    }
    return scanners;
  }
}
