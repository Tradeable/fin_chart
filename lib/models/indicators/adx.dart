import 'dart:math';

import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/adx_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Adx extends Indicator {
  int period = 14;
  Color adxLineColor = Colors.blue;
  Color diPlusColor = Colors.green;
  Color diMinusColor = Colors.red;
  bool showDiPlus = false;
  bool showDiMinus = false;

  final List<double> adxValues = [];
  final List<double> diPlusValues = [];
  final List<double> diMinusValues = [];
  final List<ICandle> candles = [];

  Adx({
    this.period = 14,
    Color? adxLineColor,
    Color? diPlusColor,
    Color? diMinusColor,
    this.showDiPlus = false,
    this.showDiMinus = false,
  }) : super(
            id: generateV4(),
            type: IndicatorType.adx,
            displayMode: DisplayMode.panel) {
    // ... rest of constructor remains the same
  }

  Adx._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 14,
    this.adxLineColor = Colors.purple,
    this.diPlusColor = Colors.green,
    this.diMinusColor = Colors.red,
    this.showDiPlus = false,
    this.showDiMinus = false,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    // Check that we have enough data for valid ADX values
    if (candles.isEmpty || adxValues.isEmpty) return;

    // Define starting index for valid values
    int startIndex = period * 2 - 1; // ADX needs 2*period bars
    if (startIndex >= adxValues.length || startIndex >= candles.length) return;

    // Draw ADX line
    _drawLine(canvas, adxValues, adxLineColor);

    // Draw +DI line only if visible
    if (showDiPlus) {
      _drawLine(canvas, diPlusValues, diPlusColor);
    }

    // Draw -DI line only if visible
    if (showDiMinus) {
      _drawLine(canvas, diMinusValues, diMinusColor);
    }

    // Draw level lines (20, 40, 60) - these might still be useful as reference
    _drawLevelLine(canvas, 20, Colors.grey.withAlpha((0.5 * 255).toInt()));
    _drawLevelLine(canvas, 40, Colors.grey.withAlpha((0.5 * 255).toInt()));
    _drawLevelLine(canvas, 60, Colors.grey.withAlpha((0.5 * 255).toInt()));
  }

  void _drawLevelLine(Canvas canvas, double level, Color color) {
    canvas.drawLine(
      Offset(leftPos, toY(level)),
      Offset(rightPos, toY(level)),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLine(Canvas canvas, List<double> values, Color color) {
    if (values.isEmpty) return;

    final path = Path();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Start with the first valid value
    int startIndex = period * 2 - 1; // ADX needs 2*period bars
    if (startIndex >= values.length) return;

    path.moveTo(toX(startIndex.toDouble()), toY(values[startIndex]));

    // Draw the rest of the line
    for (int i = startIndex + 1; i < values.length; i++) {
      path.lineTo(toX(i.toDouble()), toY(values[i]));
    }

    // If we have more candles than calculated values, extend the last value
    if (candles.length > values.length) {
      double lastValue = values.last;
      double endX = toX((candles.length - 1).toDouble());
      path.lineTo(endX, toY(lastValue));
    }

    canvas.drawPath(path, paint);
  }

  @override
  calculateYValueRange(List<ICandle> data) {
    _calculateADX(data);

    // Find min and max values for dynamic scaling
    double minValue = adxValues.isEmpty
        ? double.infinity
        : adxValues
            .where((value) => value > 0)
            .fold(double.infinity, (min, value) => math.min(min, value));
    double maxValue = adxValues.isEmpty
        ? double.negativeInfinity
        : adxValues.fold(
            double.negativeInfinity, (max, value) => math.max(max, value));


    // if (minValue == double.infinity) minValue = 0;
    // if (maxValue == double.negativeInfinity) maxValue = 100;

    print("data values : $minValue and $maxValue");

    // Add padding to min/max
    double range = maxValue - minValue;
    minValue = max(0, minValue - range * 0.1); // Don't go below 0
    maxValue = maxValue + range * 0.1;

    print("y values : $yMinValue and $yMaxValue");

    if (data.length == period) {yValues.clear;}

    if (minValue == double.infinity && maxValue == double.negativeInfinity) {
      yMinValue = 0;
      yMaxValue = 100;
    } else {
      yMinValue = min(minValue, yMinValue);
      yMaxValue = max(maxValue, yMaxValue);
    }

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);

    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
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

    // Calculate ADX values
    _calculateADX(candles);

    // Call calculateYValueRange instead of implementing the logic here
    calculateYValueRange(data);
  }

  void _calculateADX(List<ICandle> candles) {
    adxValues.clear();
    diPlusValues.clear();
    diMinusValues.clear();

    if (candles.length < period * 2) {
      return; // Not enough data
    }

    // Initialize arrays with zeros - use exact candle length
    adxValues.addAll(List.filled(candles.length, 0));
    diPlusValues.addAll(List.filled(candles.length, 0));
    diMinusValues.addAll(List.filled(candles.length, 0));

    // Calculate True Range (TR), +DM, -DM
    List<double> trValues = [];
    List<double> plusDM = [];
    List<double> minusDM = [];

    // First value has no previous candle, initialize with 0
    trValues.add(candles[0].high - candles[0].low);
    plusDM.add(0);
    minusDM.add(0);

    // Calculate TR, +DM, -DM for subsequent candles
    for (int i = 1; i < candles.length; i++) {
      // True Range calculation
      double highLow = candles[i].high - candles[i].low;
      double highPrevClose = (candles[i].high - candles[i - 1].close).abs();
      double lowPrevClose = (candles[i].low - candles[i - 1].close).abs();
      double tr = max(highLow, max(highPrevClose, lowPrevClose));
      trValues.add(tr);

      // +DM and -DM calculation
      double upMove = candles[i].high - candles[i - 1].high;
      double downMove = candles[i - 1].low - candles[i].low;

      double dmPlus = 0;
      double dmMinus = 0;

      if (upMove > downMove && upMove > 0) {
        dmPlus = upMove;
      }

      if (downMove > upMove && downMove > 0) {
        dmMinus = downMove;
      }

      plusDM.add(dmPlus);
      minusDM.add(dmMinus);
    }

    // Calculate smoothed TR, +DM, -DM
    List<double> smoothedTR = _calculateSmoothedValues(trValues);
    List<double> smoothedPlusDM = _calculateSmoothedValues(plusDM);
    List<double> smoothedMinusDM = _calculateSmoothedValues(minusDM);

    // Calculate +DI and -DI
    for (int i = 0; i < smoothedTR.length; i++) {
      int actualIndex =
          i + period - 1; // Map the smoothed index to original index
      if (smoothedTR[i] > 0) {
        diPlusValues[actualIndex] = (smoothedPlusDM[i] / smoothedTR[i]) * 100;
        diMinusValues[actualIndex] = (smoothedMinusDM[i] / smoothedTR[i]) * 100;
      }
    }

    // Calculate DX (Directional Index)
    List<double> dx = List.filled(candles.length, 0);
    for (int i = period - 1; i < candles.length; i++) {
      double sum = diPlusValues[i] + diMinusValues[i];
      if (sum > 0) {
        dx[i] = ((diPlusValues[i] - diMinusValues[i]).abs() / sum) * 100;
      }
    }

    // First ADX value (at index period*2-1) is average of period DX values
    if (candles.length >= period * 2) {
      double sum = 0;
      for (int i = period; i < period * 2; i++) {
        sum += dx[i];
      }
      adxValues[period * 2 - 1] = sum / period;

      // Calculate subsequent ADX values using Wilder's smoothing
      for (int i = period * 2; i < candles.length; i++) {
        adxValues[i] = (adxValues[i - 1] * (period - 1) + dx[i]) / period;
      }
    }
  }

  List<double> _calculateSmoothedValues(List<double> values) {
    List<double> smoothed = [];

    // First smoothed value is average of first 'period' values
    if (values.length >= period) {
      double sum = 0;
      for (int i = 0; i < period; i++) {
        sum += values[i];
      }
      smoothed.add(sum / period);

      // Calculate rest using Wilder's smoothing method
      for (int i = period; i < values.length; i++) {
        smoothed.add(
            ((smoothed[smoothed.length - 1] * (period - 1)) + values[i]) /
                period);
      }
    }

    return smoothed;
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => AdxSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['period'] = period;
    json['adxLineColor'] = colorToJson(adxLineColor);
    json['diPlusColor'] = colorToJson(diPlusColor);
    json['diMinusColor'] = colorToJson(diMinusColor);
    json['showDiPlus'] = showDiPlus;
    json['showDiMinus'] = showDiMinus;
    return json;
  }

  factory Adx.fromJson(Map<String, dynamic> json) {
    return Adx._(
      id: json['id'],
      type: IndicatorType.adx,
      displayMode: DisplayMode.panel,
      period: json['period'] ?? 14,
      adxLineColor: json['adxLineColor'] != null
          ? colorFromJson(json['adxLineColor'])
          : Colors.purple,
      diPlusColor: json['diPlusColor'] != null
          ? colorFromJson(json['diPlusColor'])
          : Colors.green,
      diMinusColor: json['diMinusColor'] != null
          ? colorFromJson(json['diMinusColor'])
          : Colors.red,
      showDiPlus: json['showDiPlus'] ?? true,
      showDiMinus: json['showDiMinus'] ?? true,
    );
  }
}
