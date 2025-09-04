import 'dart:math' as math;
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/pivot_point.dart';
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

class PeriodData {
  final int startIndex;
  final int endIndex;
  final List<ICandle> candles;

  PeriodData({
    required this.startIndex,
    required this.endIndex,
    required this.candles,
  });
}

class PivotLevel {
  final int startIndex;
  final int endIndex;
  final double pivot;
  final double r1, r2, r3;
  final double s1, s2, s3;

  PivotLevel({
    required this.startIndex,
    required this.endIndex,
    required this.pivot,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.s1,
    required this.s2,
    required this.s3,
  });
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

List<double> _calculateRSI(List<ICandle> candles, int period) {
  List<double> rsiValues = [];
  if (candles.length <= period) return rsiValues;

  List<double> gains = [];
  List<double> losses = [];

  // Calculate initial gains and losses
  for (int i = 1; i <= period; i++) {
    double change = candles[i].close - candles[i - 1].close;
    gains.add(change > 0 ? change : 0);
    losses.add(change < 0 ? -change : 0);
  }

  // Calculate first RSI value
  double avgGain = gains.reduce((a, b) => a + b) / period;
  double avgLoss = losses.reduce((a, b) => a + b) / period;

  if (avgLoss == 0) {
    rsiValues.add(100);
  } else {
    double rs = avgGain / avgLoss;
    rsiValues.add(100 - (100 / (1 + rs)));
  }

  // Calculate remaining RSI values
  for (int i = period + 1; i < candles.length; i++) {
    double change = candles[i].close - candles[i - 1].close;
    double currentGain = change > 0 ? change : 0;
    double currentLoss = change < 0 ? -change : 0;

    avgGain = ((avgGain * (period - 1)) + currentGain) / period;
    avgLoss = ((avgLoss * (period - 1)) + currentLoss) / period;

    if (avgLoss == 0) {
      rsiValues.add(100);
    } else {
      double rs = avgGain / avgLoss;
      rsiValues.add(100 - (100 / (1 + rs)));
    }
  }
  return rsiValues;
}

List<double> _calculateEMAFromValues(List<double> prices, int period) {
  List<double> emaValues = List.filled(prices.length, 0);

  if (prices.length >= period) {
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += prices[i];
    }
    emaValues[period - 1] = sum / period;

    double multiplier = 2 / (period + 1);

    for (int i = period; i < prices.length; i++) {
      emaValues[i] =
          (prices[i] - emaValues[i - 1]) * multiplier + emaValues[i - 1];
    }
  }
  return emaValues;
}

List<double> _calculateMacdLine(
    List<ICandle> candles, int fastPeriod, int slowPeriod) {
  if (candles.length < slowPeriod) return [];

  final prices = candles.map((c) => c.close).toList();
  final fastEMA = _calculateEMAFromValues(prices, fastPeriod);
  final slowEMA = _calculateEMAFromValues(prices, slowPeriod);

  List<double> macdLine = List.filled(candles.length, 0.0);
  for (int i = slowPeriod - 1; i < candles.length; i++) {
    if (i < fastEMA.length && i < slowEMA.length) {
      macdLine[i] = fastEMA[i] - slowEMA[i];
    }
  }
  return macdLine;
}

({List<double> macdLine, List<double> signalLine}) _calculateMacdAndSignalLines(
    List<ICandle> candles, int fastPeriod, int slowPeriod, int signalPeriod) {
  if (candles.length < slowPeriod + signalPeriod) {
    return (macdLine: [], signalLine: []);
  }

  final prices = candles.map((c) => c.close).toList();
  final fastEMA = _calculateEMAFromValues(prices, fastPeriod);
  final slowEMA = _calculateEMAFromValues(prices, slowPeriod);

  List<double> macdLine = List.filled(candles.length, 0.0);
  for (int i = slowPeriod - 1; i < candles.length; i++) {
    if (i < fastEMA.length && i < slowEMA.length) {
      macdLine[i] = fastEMA[i] - slowEMA[i];
    }
  }

  final signalLine = _calculateEMAFromValues(macdLine, signalPeriod);

  return (macdLine: macdLine, signalLine: signalLine);
}

List<double> _calculateVolumeSMA(List<ICandle> candles, int period) {
  List<double> smaValues = [];
  if (candles.length < period) return smaValues;

  for (int i = 0; i < candles.length; i++) {
    if (i < period - 1) {
      smaValues.add(0);
    } else {
      double sum = 0;
      for (int j = i - (period - 1); j <= i; j++) {
        sum += candles[j].volume;
      }
      smaValues.add(sum / period);
    }
  }
  return smaValues;
}

List<double> _calculateROC(List<ICandle> candles, int period) {
  List<double> rocValues = [];
  if (candles.length < period) return rocValues;

  for (int i = 0; i < candles.length; i++) {
    if (i < period) {
      rocValues.add(0); // Not enough data for the period
    } else {
      final currentClose = candles[i].close;
      final pastClose = candles[i - period].close;
      if (pastClose != 0) {
        final roc = ((currentClose - pastClose) / pastClose) * 100;
        rocValues.add(roc);
      } else {
        rocValues.add(0); // Avoid division by zero
      }
    }
  }
  return rocValues;
}

DateTime _getPeriodStart(DateTime date, PivotTimeframe timeframe) {
  switch (timeframe) {
    case PivotTimeframe.daily:
      return DateTime(date.year, date.month, date.day);
    case PivotTimeframe.weekly:
      final daysSinceMonday = date.weekday - 1;
      return DateTime(date.year, date.month, date.day - daysSinceMonday);
    case PivotTimeframe.monthly:
      return DateTime(date.year, date.month, 1);
  }
}

bool _isSamePeriod(
    DateTime period1, DateTime period2, PivotTimeframe timeframe) {
  switch (timeframe) {
    case PivotTimeframe.daily:
      return period1.year == period2.year &&
          period1.month == period2.month &&
          period1.day == period2.day;
    case PivotTimeframe.weekly:
      return period1.isAtSameMomentAs(period2);
    case PivotTimeframe.monthly:
      return period1.year == period2.year && period1.month == period2.month;
  }
}

List<PeriodData> _groupCandlesByPeriod(
    List<ICandle> candles, PivotTimeframe timeframe) {
  final periods = <PeriodData>[];
  if (candles.isEmpty) return periods;

  DateTime? currentPeriodStart;
  int startIndex = 0;

  for (int i = 0; i < candles.length; i++) {
    final candleDate = candles[i].date;
    final periodStart = _getPeriodStart(candleDate, timeframe);

    if (currentPeriodStart == null ||
        !_isSamePeriod(currentPeriodStart, periodStart, timeframe)) {
      if (currentPeriodStart != null && i > startIndex) {
        periods.add(PeriodData(
          startIndex: startIndex,
          endIndex: i - 1,
          candles: candles.sublist(startIndex, i),
        ));
      }
      currentPeriodStart = periodStart;
      startIndex = i;
    }
  }

  if (startIndex < candles.length) {
    periods.add(PeriodData(
      startIndex: startIndex,
      endIndex: candles.length - 1,
      candles: candles.sublist(startIndex),
    ));
  }
  return periods;
}

// #endregion

// #region Consolidated Scan Functions
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

List<ScannerResult> _scanDualOscillator(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int rsiPeriod = properties['rsiPeriod'] as int;
  final int mfiPeriod = properties['mfiPeriod'] as int;
  final double rsiThreshold = properties['rsiThreshold'] as double;
  final double mfiThreshold = properties['mfiThreshold'] as double;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.length <= math.max(rsiPeriod, mfiPeriod)) return scanners;

  final rsiValues = _calculateRSI(candles, rsiPeriod);
  final mfiValues = _calculateMFI(candles, mfiPeriod);

  // Align the start indices
  final rsiStartIndex = rsiPeriod;
  final mfiStartIndex = mfiPeriod;
  final commonStartIndex = math.max(rsiStartIndex, mfiStartIndex);

  for (int i = commonStartIndex; i < candles.length; i++) {
    // Get the correct index for each indicator's value list
    final rsiValueIndex = i - rsiStartIndex;
    final mfiValueIndex = i - mfiStartIndex;

    if (rsiValueIndex < 0 ||
        rsiValueIndex >= rsiValues.length ||
        mfiValueIndex < 0 ||
        mfiValueIndex >= mfiValues.length) {
      continue;
    }

    final rsi = rsiValues[rsiValueIndex];
    final mfi = mfiValues[mfiValueIndex];

    bool conditionMet = false;
    if (comparison == PriceComparison.above) {
      // Overbought
      conditionMet = rsi > rsiThreshold && mfi > mfiThreshold;
    } else {
      // Oversold
      conditionMet = rsi < rsiThreshold && mfi < mfiThreshold;
    }

    if (conditionMet) {
      scanners.add(ScannerResult(
        scannerType: type,
        label: type.label,
        targetIndex: i,
        highlightedIndices: [i],
        highlightColor:
            comparison == PriceComparison.above ? Colors.red : Colors.green,
      ));
    }
  }
  return scanners;
}

List<ScannerResult> _scanMacdCrossover(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int fastPeriod = properties['fastPeriod'] as int;
  final int slowPeriod = properties['slowPeriod'] as int;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.length <= slowPeriod) return scanners;

  final macdLine = _calculateMacdLine(candles, fastPeriod, slowPeriod);

  // Start checking from the second valid MACD value
  for (int i = slowPeriod; i < macdLine.length; i++) {
    bool conditionMet = false;

    if (comparison == PriceComparison.above) {
      // Crosses above zero
      conditionMet = macdLine[i - 1] < 0 && macdLine[i] > 0;
    } else {
      // Crosses below zero
      conditionMet = macdLine[i - 1] > 0 && macdLine[i] < 0;
    }

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

List<ScannerResult> _scanMacdSignalCrossover(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int fastPeriod = properties['fastPeriod'] as int;
  final int slowPeriod = properties['slowPeriod'] as int;
  final int signalPeriod = properties['signalPeriod'] as int;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.length < slowPeriod + signalPeriod) return scanners;

  final (:macdLine, :signalLine) = _calculateMacdAndSignalLines(
      candles, fastPeriod, slowPeriod, signalPeriod);

  // Start checking from the second valid signal value
  final startIndex = slowPeriod + signalPeriod - 1;
  for (int i = startIndex; i < candles.length; i++) {
    // Ensure we have previous data to compare
    if (i == 0) continue;

    bool conditionMet = false;

    if (comparison == PriceComparison.above) {
      // Crosses above signal
      conditionMet =
          macdLine[i - 1] < signalLine[i - 1] && macdLine[i] > signalLine[i];
    } else {
      // Crosses below signal
      conditionMet =
          macdLine[i - 1] > signalLine[i - 1] && macdLine[i] < signalLine[i];
    }

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

List<ScannerResult> _scanRsiConditions(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int rsiPeriod = properties['rsiPeriod'] as int;
  final double rsiThreshold = properties['rsiThreshold'] as double;

  if (candles.length <= rsiPeriod) return scanners;

  final rsiValues = _calculateRSI(candles, rsiPeriod);
  final rsiStartIndex = rsiPeriod;

  if (type == ScannerType.rsiBullish) {
    final int volumePeriod = properties['volumePeriod'] as int;
    final double volumeThreshold = properties['volumeThreshold'] as double;
    final avgVolume = _calculateVolumeSMA(candles, volumePeriod);
    final commonStartIndex = math.max(rsiStartIndex, volumePeriod);

    for (int i = commonStartIndex; i < candles.length; i++) {
      final rsiValueIndex = i - rsiStartIndex;
      if (rsiValueIndex < 0 || rsiValueIndex >= rsiValues.length) continue;

      final rsi = rsiValues[rsiValueIndex];
      final avgVol = avgVolume[i];
      final price = candles[i].close;

      if (rsi >= rsiThreshold && (avgVol * price) > volumeThreshold) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: type.label,
          targetIndex: i,
          highlightedIndices: [i],
          highlightColor: Colors.green,
        ));
      }
    }
  } else if (type == ScannerType.rsiBearish) {
    for (int i = 0; i < rsiValues.length; i++) {
      final candleIndex = rsiStartIndex + i;
      if (rsiValues[i] <= rsiThreshold) {
        scanners.add(ScannerResult(
          scannerType: type,
          label: type.label,
          targetIndex: candleIndex,
          highlightedIndices: [candleIndex],
          highlightColor: Colors.red,
        ));
      }
    }
  }

  return scanners;
}

List<ScannerResult> _scanRocConditions(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final int rocPeriod1 = properties['rocPeriod1'] as int; // 125
  final int rocPeriod2 = properties['rocPeriod2'] as int; // 21
  final int smaPeriod = properties['smaPeriod'] as int; // 20

  final requiredCandles = [rocPeriod1, rocPeriod2, smaPeriod].reduce(math.max);
  if (candles.length <= requiredCandles) return scanners;

  final roc125 = _calculateROC(candles, rocPeriod1);
  final roc21 = _calculateROC(candles, rocPeriod2);
  final sma20 = _calculateSMA(candles, smaPeriod);

  for (int i = requiredCandles; i < candles.length; i++) {
    bool conditionMet = false;
    if (type == ScannerType.rocOversold) {
      // Oversold conditions (Bullish Reversal)
      conditionMet = roc125[i] > 0 &&
          roc21[i] < -8 &&
          candles[i - 1].close < sma20[i - 1] &&
          candles[i].close > sma20[i];
    } else if (type == ScannerType.rocOverbought) {
      // Overbought conditions (Bearish Reversal)
      conditionMet = roc21[i] > 8 &&
          roc125[i] < 0 &&
          candles[i - 1].close > sma20[i - 1] &&
          candles[i].close < sma20[i];
    }

    if (conditionMet) {
      scanners.add(ScannerResult(
        scannerType: type,
        label: type.label,
        targetIndex: i,
        highlightedIndices: [i],
        highlightColor:
            type == ScannerType.rocOversold ? Colors.green : Colors.red,
      ));
    }
  }
  return scanners;
}

List<ScannerResult> _scanPivotPoints(
    List<ICandle> candles, ScannerType type, PivotTimeframe timeframe) {
  final scanners = <ScannerResult>[];
  final properties = type.properties;
  final String levelKey = properties['level'] as String;
  final PriceComparison comparison =
      properties['comparison'] as PriceComparison;

  if (candles.isEmpty) return scanners;

  final periods = _groupCandlesByPeriod(candles, timeframe);
  if (periods.length < 2) return scanners;

  final pivotLevels = <PivotLevel>[];
  for (int i = 1; i < periods.length; i++) {
    final previousPeriod = periods[i - 1];
    final currentPeriod = periods[i];

    if (previousPeriod.candles.isEmpty) continue;

    final high = previousPeriod.candles
        .map((c) => c.high)
        .reduce((a, b) => a > b ? a : b);
    final low = previousPeriod.candles
        .map((c) => c.low)
        .reduce((a, b) => a < b ? a : b);
    final close = previousPeriod.candles.last.close;

    final pivot = (high + low + close) / 3;
    final r1 = (2 * pivot) - low;
    final r2 = pivot + (high - low);
    final r3 = high + 2 * (pivot - low);
    final s1 = (2 * pivot) - high;
    final s2 = pivot - (high - low);
    final s3 = low - 2 * (high - pivot);

    pivotLevels.add(PivotLevel(
      startIndex: currentPeriod.startIndex,
      endIndex: currentPeriod.endIndex,
      pivot: pivot,
      r1: r1,
      r2: r2,
      r3: r3,
      s1: s1,
      s2: s2,
      s3: s3,
    ));
  }

  for (final level in pivotLevels) {
    for (int i = level.startIndex; i <= level.endIndex; i++) {
      if (i >= candles.length) continue;

      double levelValue;
      switch (levelKey) {
        case 'r1':
          levelValue = level.r1;
          break;
        case 'r2':
          levelValue = level.r2;
          break;
        case 'r3':
          levelValue = level.r3;
          break;
        case 's1':
          levelValue = level.s1;
          break;
        case 's2':
          levelValue = level.s2;
          break;
        case 's3':
          levelValue = level.s3;
          break;
        default:
          continue;
      }

      bool conditionMet = (comparison == PriceComparison.above)
          ? candles[i].close > levelValue
          : candles[i].close < levelValue;

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
  }

  return scanners;
}

List<ScannerResult> _scanHighLowRecovery(
    List<ICandle> candles, ScannerType type) {
  final scanners = <ScannerResult>[];
  if (candles.isEmpty) return scanners;

  // Logic for 52-Week Scanners
  if (type == ScannerType.recoveryFrom52WeekLow ||
      type == ScannerType.fallFrom52WeekHigh) {
    const int week52 = 260; // Approximate trading days in 52 weeks
    if (candles.length < week52) return scanners;

    for (int i = week52; i < candles.length; i++) {
      final lookbackCandles = candles.sublist(i - week52, i);
      final high52w = lookbackCandles.map((c) => c.high).reduce(math.max);
      final low52w = lookbackCandles.map((c) => c.low).reduce(math.min);
      final currentClose = candles[i].close;

      if (type == ScannerType.recoveryFrom52WeekLow) {
        final percentRecovery = ((currentClose - low52w) / low52w) * 100;
        if (percentRecovery > 5) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i],
              highlightColor: Colors.green));
        }
      } else if (type == ScannerType.fallFrom52WeekHigh) {
        final percentFall = ((high52w - currentClose) / high52w) * 100;
        if (percentFall > 10) {
          scanners.add(ScannerResult(
              scannerType: type,
              label: type.label,
              targetIndex: i,
              highlightedIndices: [i],
              highlightColor: Colors.red));
        }
      }
    }
  }

  // Logic for Weekly Scanners
  if (type == ScannerType.recoveryFromWeekLow ||
      type == ScannerType.fallFromWeekHigh) {
    DateTime? currentWeekStart;
    double weekHigh = double.negativeInfinity;
    double weekLow = double.infinity;

    for (int i = 0; i < candles.length; i++) {
      final candleDate = candles[i].date;
      final periodStart = _getPeriodStart(candleDate, PivotTimeframe.weekly);

      if (currentWeekStart == null ||
          !_isSamePeriod(
              currentWeekStart, periodStart, PivotTimeframe.weekly)) {
        currentWeekStart = periodStart;
        weekHigh = double.negativeInfinity;
        weekLow = double.infinity;
      }

      weekHigh = math.max(weekHigh, candles[i].high);
      weekLow = math.min(weekLow, candles[i].low);
      final currentClose = candles[i].close;

      if (type == ScannerType.recoveryFromWeekLow) {
        if (weekLow > 0) {
          final percentRecovery = ((currentClose - weekLow) / weekLow) * 100;
          if (percentRecovery > 10) {
            scanners.add(ScannerResult(
                scannerType: type,
                label: type.label,
                targetIndex: i,
                highlightedIndices: [i],
                highlightColor: Colors.green));
          }
        }
      } else if (type == ScannerType.fallFromWeekHigh) {
        if (weekHigh > 0) {
          final percentFall = ((weekHigh - currentClose) / weekHigh) * 100;
          if (percentFall > 5) {
            scanners.add(ScannerResult(
                scannerType: type,
                label: type.label,
                targetIndex: i,
                highlightedIndices: [i],
                highlightColor: Colors.red));
          }
        }
      }
    }
  }

  return scanners;
}
// #endregion

/// Main consolidated scanner function.
List<ScannerResult> runScanner(ScannerType type, List<ICandle> candles,
    {TrendData? trendData, PivotTimeframe? pivotTimeframe}) {
  // Handle grouped/parameterized scanner types first
  if (type.name.contains('SMA') || type.name.contains('EMA')) {
    return _scanMovingAverage(candles, type);
  }
  if (type.name.startsWith('mfi')) {
    return _scanOscillator(candles, type);
  }
  if (type.name.startsWith('dual')) {
    return _scanDualOscillator(candles, type);
  }
  if (type.name.startsWith('macdCross')) {
    if (type.name.contains('Zero')) {
      return _scanMacdCrossover(candles, type);
    } else if (type.name.contains('Signal')) {
      return _scanMacdSignalCrossover(candles, type);
    }
  }
  if (type.name.startsWith('rsiB')) {
    return _scanRsiConditions(candles, type);
  }
  if (type.name.startsWith('rocO')) {
    return _scanRocConditions(candles, type);
  }
  if (type.name.startsWith('pivotPoint')) {
    return _scanPivotPoints(
        candles, type, pivotTimeframe ?? PivotTimeframe.daily);
  }
  if (type.name.contains('Week')) {
    return _scanHighLowRecovery(candles, type);
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
