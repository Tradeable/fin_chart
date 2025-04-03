import 'package:fin_chart/data/candle_data_json.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/atr_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Atr extends Indicator {
  int period;
  Color lineColor;

  final List<double> atrValues = [];
  final List<ICandle> candles = [];

  Atr({
    this.period = 14,
    this.lineColor = Colors.red,
  }) : super(
            id: generateV4(),
            type: IndicatorType.atr,
            displayMode: DisplayMode.panel);

  Atr._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 14,
    this.lineColor = Colors.purple,
  });

  @override
  calculateYValueRange(List<ICandle> data) {
    _calculateATR(data);

    // Find min and max values for dynamic scaling
    double minValue = atrValues.isEmpty
        ? double.infinity
        : atrValues
            .where((value) => value > 0)
            .fold(double.infinity, (min, value) => math.min(min, value));
    double maxValue = atrValues.isEmpty
        ? double.negativeInfinity
        : atrValues.fold(
            double.negativeInfinity, (max, value) => math.max(max, value));

    // Add padding to min/max
    double range = maxValue - minValue;
    minValue = math.max(0, minValue - range * 0.1); // Don't go below 0
    maxValue = maxValue + range * 0.1;

    if (yMinValue == 0 && yMaxValue == 1) {
      yMinValue = minValue;
      yMaxValue = maxValue;
    } else {
      yMinValue = math.min(minValue, yMinValue);
      yMaxValue = math.max(maxValue, yMaxValue);
    }

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);

    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || atrValues.isEmpty || candles.length <= period) {
      return;
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    // Draw from the first valid ATR value (after period-1)
    for (int i = period - 1;
        i < math.min(atrValues.length, candles.length);
        i++) {
      if (atrValues[i] <= 0) continue; // Skip invalid values

      final x = toX(i.toDouble());
      final y = toY(atrValues[i]);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    // If our candles list is empty, initialize it
    if (candles.isEmpty) {
      candles.addAll(data);
    } else {
      // Only add new candles
      int existingCount = candles.length;
      if (data.length > existingCount) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    // Calculate ATR values by explicitly passing candles
    _calculateATR(candles);

    // Call calculateYValueRange instead of implementing the logic here
    calculateYValueRange(data);
  }

  void _calculateATR(List<ICandle> candles) {
    atrValues.clear();

    if (candles.length < period + 1) {
      return; // Need at least period+1 candles
    }

    // Initialize array with zeros - use exact candle length
    atrValues.addAll(List.filled(data.length, 0));

    // Calculate first true range
    double tr = candles[0].high - candles[0].low;

    // Calculate subsequent true ranges
    for (int i = 1; i < candles.length; i++) {
      double highLow = candles[i].high - candles[i].low;
      double highPrevClose = (candles[i].high - candles[i - 1].close).abs();
      double lowPrevClose = (candles[i].low - candles[i - 1].close).abs();

      tr = [highLow, highPrevClose, lowPrevClose]
          .reduce((curr, next) => curr > next ? curr : next);

      // Just calculate TR values here, don't store them in a separate list

      // For the first period-1 candles, ATR is 0
      if (i >= period) {
        // Calculate ATR using smoothing formula
        atrValues[i] = (atrValues[i - 1] * (period - 1) + tr) / period;
      } else if (i == period - 1) {
        // Calculate first ATR (simple average for first 'period' days)
        double sum = 0;
        for (int j = 0; j < period; j++) {
          // Need to recalculate TR for previous days
          double prevTR;
          if (j == 0) {
            prevTR = candles[j].high - candles[j].low;
          } else {
            double prevHighLow = candles[j].high - candles[j].low;
            double prevHighPrevClose =
                (candles[j].high - candles[j - 1].close).abs();
            double prevLowPrevClose =
                (candles[j].low - candles[j - 1].close).abs();
            prevTR = [prevHighLow, prevHighPrevClose, prevLowPrevClose]
                .reduce((curr, next) => curr > next ? curr : next);
          }
          sum += prevTR;
        }
        atrValues[i] = sum / period;
      }
    }
  }

  @override
  void showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog<Atr>(
      context: context,
      builder: (context) => AtrSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['period'] = period;
    json['lineColor'] = colorToJson(lineColor);
    return json;
  }

  factory Atr.fromJson(Map<String, dynamic> json) {
    return Atr._(
      id: json['id'],
      type: IndicatorType.atr,
      displayMode: DisplayMode.panel,
      period: json['period'] ?? 14,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.red,
    );
  }
}
