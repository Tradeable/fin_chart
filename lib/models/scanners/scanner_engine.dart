import 'dart:math' as math;
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/scanners/scanner_properties.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';
import 'package:flutter/material.dart';

// #region Helper Functions & Enums

double _bodySize(ICandle candle) => (candle.close - candle.open).abs();
double _totalRange(ICandle candle) => candle.high - candle.low;
double _upperShadow(ICandle candle) =>
    candle.high - (_isBullish(candle) ? candle.close : candle.open);
double _lowerShadow(ICandle candle) =>
    (_isBullish(candle) ? candle.open : candle.close) - candle.low;
bool _isBullish(ICandle candle) => candle.close > candle.open;
bool _isBearish(ICandle candle) => candle.open > candle.close;
bool _isDoji(ICandle candle, {double threshold = 0.1}) {
  final range = _totalRange(candle);
  return range > 0 && (_bodySize(candle) / range) < threshold;
}

List<double> _calculateSMA(List<ICandle> candles, int period) {
  List<double> smaValues = [];
  if (candles.length < period) return smaValues;

  for (int i = 0; i < candles.length; i++) {
    if (i < period - 1) {
      smaValues.add(0);
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
  List<double> emaValues = List.filled(candles.length, 0);
  if (candles.length < period) return emaValues;

  double smoothing = 2.0 / (period + 1);
  double sum = 0;
  for (int i = 0; i < period; i++) {
    sum += candles[i].close;
  }
  emaValues[period - 1] = sum / period;

  for (int i = period; i < candles.length; i++) {
    emaValues[i] =
        (candles[i].close - emaValues[i - 1]) * smoothing + emaValues[i - 1];
  }
  return emaValues;
}

List<double> _calculateMFI(List<ICandle> candles, int period) {
  List<double> mfiValues = [];
  if (candles.length <= period) return mfiValues;

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
    mfiValues.add(math.min(100, math.max(0, mfiValue)));
  }
  return mfiValues;
}
// #endregion

// #region Consolidated Scan Functions
List<ScannerResult> _scanMovingAverage(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int period = properties['period'] as int;
  final MovingAverageType maType = properties['maType'] as MovingAverageType;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.length < period) return scanners;

  final maValues = maType == MovingAverageType.sMA
      ? _calculateSMA(candles, period)
      : _calculateEMA(candles, period);

  for (int i = period - 1; i < candles.length; i++) {
    if (maValues[i] == 0) continue;

    bool conditionMet = (comparison == PriceComparison.above)
        ? candles[i].close > maValues[i]
        : candles[i].close < maValues[i];

    if (conditionMet) {
      scanners.add(ScannerResult(
        scannerType: type,
        label: type.label,
        targetIndex: i,
        highlightedIndices: [i],
        highlightColor:
            comparison == PriceComparison.above ? Colors.green : Colors.red,
      ));
    }
  }
  return scanners;
}

List<ScannerResult> _scanOscillator(List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int period = properties['period'] as int;
  final double threshold = properties['threshold'] as double;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.length <= period) return scanners;

  final oscillatorValues = _calculateMFI(candles, period);
  int startIndex = period;

  for (int i = 0; i < oscillatorValues.length; i++) {
    final value = oscillatorValues[i];
    final candleIndex = startIndex + i;

    bool conditionMet = (comparison == PriceComparison.above)
        ? value > threshold
        : value < threshold;

    if (conditionMet) {
      scanners.add(ScannerResult(
        scannerType: type,
        label: type.label,
        targetIndex: candleIndex,
        highlightedIndices: [candleIndex],
        highlightColor:
            comparison == PriceComparison.above ? Colors.red : Colors.green,
      ));
    }
  }
  return scanners;
}
// #endregion

/// Main consolidated scanner function.
List<ScannerResult> runScanner(ScannerType type, List<ICandle> candles,
    {TrendData? trendData}) {
  // Handle grouped/parameterized scanner types first
  if (type.name.contains('SMA') || type.name.contains('EMA')) {
    return _scanMovingAverage(candles, type);
  }
  if (type.name.startsWith('mfi')) {
    return _scanOscillator(candles, type);
  }

  // Handle individual candlestick patterns
  final scanners = <ScannerResult>[];

  switch (type) {
    case ScannerType.hammer:
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (_totalRange(candle) > 0 &&
            _bodySize(candle) < _totalRange(candle) * 0.33 &&
            _lowerShadow(candle) >= _bodySize(candle) * 2 &&
            _upperShadow(candle) < _bodySize(candle) * 0.5) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i]));
        }
      }
      break;

    case ScannerType.hangingMan:
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (_totalRange(candle) > 0 &&
            _bodySize(candle) < _totalRange(candle) * 0.33 &&
            _lowerShadow(candle) >= _bodySize(candle) * 2 &&
            _upperShadow(candle) < _bodySize(candle) * 0.5) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i]));
        }
      }
      break;

    case ScannerType.invertedHammer:
    case ScannerType.shootingStar:
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (_totalRange(candle) > 0 &&
            _upperShadow(candle) >= _bodySize(candle) * 2 &&
            _lowerShadow(candle) < _bodySize(candle)) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i]));
        }
      }
      break;

    case ScannerType.dragonflyDoji:
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (_isDoji(candle) &&
            (_upperShadow(candle) < _totalRange(candle) * 0.1)) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i]));
        }
      }
      break;

    case ScannerType.bullishEngulfing:
      for (int i = 1; i < candles.length; i++) {
        if (_isBearish(candles[i - 1]) &&
            _isBullish(candles[i]) &&
            candles[i].close > candles[i - 1].open &&
            candles[i].open < candles[i - 1].close) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i - 1, i]));
        }
      }
      break;

    case ScannerType.bearishEngulfing:
      for (int i = 1; i < candles.length; i++) {
        if (_isBullish(candles[i - 1]) &&
            _isBearish(candles[i]) &&
            candles[i].open > candles[i - 1].close &&
            candles[i].close < candles[i - 1].open) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i - 1, i]));
        }
      }
      break;

    case ScannerType.piercingLine:
      for (int i = 1; i < candles.length; i++) {
        final first = candles[i - 1];
        final second = candles[i];
        final firstBodyMidpoint = (first.open + first.close) / 2;
        if (_isBearish(first) &&
            _isBullish(second) &&
            second.open < first.low &&
            second.close > firstBodyMidpoint &&
            second.close < first.open) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i - 1, i]));
        }
      }
      break;

    case ScannerType.darkCloudCover:
      for (int i = 1; i < candles.length; i++) {
        final first = candles[i - 1];
        final second = candles[i];
        final firstBodyMidpoint = (first.open + first.close) / 2;
        if (_isBullish(first) &&
            _isBearish(second) &&
            second.open > first.high &&
            second.close < firstBodyMidpoint &&
            second.close > first.open) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i - 1, i]));
        }
      }
      break;

    case ScannerType.bullishKicker:
      for (int i = 1; i < candles.length; i++) {
        if (_isBearish(candles[i - 1]) &&
            _isBullish(candles[i]) &&
            candles[i].open > candles[i - 1].high) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i - 1, i]));
        }
      }
      break;

    case ScannerType.morningStar:
      for (int i = 2; i < candles.length; i++) {
        final first = candles[i - 2];
        final second = candles[i - 1];
        final third = candles[i];
        final firstBodyMidpoint = (first.open + first.close) / 2;

        if (_isBearish(first) &&
            _isDoji(second, threshold: 0.3) &&
            (_isBullish(second) ? second.open : second.close) < first.close &&
            _isBullish(third) &&
            third.close > firstBodyMidpoint) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i - 1,
              highlightedIndices: [i - 2, i - 1, i]));
        }
      }
      break;

    // Fallback for un-migrated candlestick patterns
    default:
      // You can add the logic for other candlestick patterns here following the same structure.
      break;
  }
  return scanners;
}
