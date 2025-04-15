import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/stochastic_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Stochastic extends Indicator {
  int kPeriod = 14;
  int dPeriod = 3;
  Color kLineColor = Colors.blue;
  Color dLineColor = Colors.red;

  final List<double> kValues = [];
  final List<double> dValues = [];
  final List<ICandle> candles = [];

  Stochastic({
    this.kPeriod = 14,
    this.dPeriod = 3,
    this.kLineColor = Colors.blue,
    this.dLineColor = Colors.red,
  }) : super(
            id: generateV4(),
            type: IndicatorType.stochastic,
            displayMode: DisplayMode.panel);

  Stochastic._({
    required super.id,
    this.kPeriod = 14,
    this.dPeriod = 3,
    this.kLineColor = Colors.blue,
    this.dLineColor = Colors.red,
  }) : super(type: IndicatorType.stochastic, displayMode: DisplayMode.panel);

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || kValues.isEmpty) return;

    // Drawing %K line
    _drawLine(canvas, kValues, kLineColor);

    // Drawing %D line
    _drawLine(canvas, dValues, dLineColor);

    // Draw overbought line (80)
    canvas.drawLine(
      Offset(leftPos, toY(80)),
      Offset(rightPos, toY(80)),
      Paint()
        ..color = Colors.red.withAlpha(128)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw oversold line (20)
    canvas.drawLine(
      Offset(leftPos, toY(20)),
      Offset(rightPos, toY(20)),
      Paint()
        ..color = Colors.green.withAlpha(128)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw middle line (50)
    canvas.drawLine(
      Offset(leftPos, toY(50)),
      Offset(rightPos, toY(50)),
      Paint()
        ..color = Colors.grey.withAlpha(90)
        ..strokeWidth = 3
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
    int startIndex = kPeriod + dPeriod - 2;
    if (startIndex >= values.length) return;

    path.moveTo(toX(startIndex.toDouble()), toY(values[startIndex]));

    // Draw the rest of the line
    for (int i = startIndex + 1; i < values.length; i++) {
      path.lineTo(toX(i.toDouble()), toY(values[i]));
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
      // Find where to start adding new data
      int existingCount = candles.length;

      // Only add candles that come after our existing ones
      if (existingCount < data.length) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    // Set fixed bounds for Stochastic (0-100) - MOVED ABOVE
    yMinValue = 0;
    yMaxValue = 100;

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));

    // Calculate after setting the y-axis values
    _calculateStochastic();
  }

  void _calculateStochastic() {
    kValues.clear();
    dValues.clear();

    if (candles.length <= kPeriod) {
      return; // Not enough data
    }

    // Calculate %K values
    List<double> tempKValues = List.filled(candles.length, 0);

    for (int i = kPeriod - 1; i < candles.length; i++) {
      // Get highest high and lowest low over the look-back period
      double highestHigh = double.negativeInfinity;
      double lowestLow = double.infinity;

      for (int j = i - (kPeriod - 1); j <= i; j++) {
        highestHigh = math.max(highestHigh, candles[j].high);
        lowestLow = math.min(lowestLow, candles[j].low);
      }

      // Calculate %K: ((Current Close - Lowest Low) / (Highest High - Lowest Low)) * 100
      double range = highestHigh - lowestLow;

      if (range > 0) {
        tempKValues[i] = ((candles[i].close - lowestLow) / range) * 100;
      } else {
        // If range is zero, set to 50 (middle)
        tempKValues[i] = 50;
      }
    }

    kValues.addAll(tempKValues);

    // Calculate %D (simple moving average of %K)
    List<double> tempDValues = List.filled(candles.length, 0);

    for (int i = kPeriod + dPeriod - 2; i < candles.length; i++) {
      double sum = 0;
      for (int j = i - (dPeriod - 1); j <= i; j++) {
        sum += kValues[j];
      }
      tempDValues[i] = sum / dPeriod;
    }

    dValues.addAll(tempDValues);
  }

  @override
  showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => StochasticSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['kPeriod'] = kPeriod;
    json['dPeriod'] = dPeriod;
    json['kLineColor'] = colorToJson(kLineColor);
    json['dLineColor'] = colorToJson(dLineColor);
    return json;
  }

  factory Stochastic.fromJson(Map<String, dynamic> json) {
    return Stochastic._(
      id: json['id'] ?? generateV4(),
      kPeriod: json['kPeriod'] ?? 14,
      dPeriod: json['dPeriod'] ?? 3,
      kLineColor: json['kLineColor'] != null
          ? colorFromJson(json['kLineColor'])
          : Colors.blue,
      dLineColor: json['dLineColor'] != null
          ? colorFromJson(json['dLineColor'])
          : Colors.red,
    );
  }
}
