import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/macd_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Macd extends Indicator {
  Color macdLineColor = Colors.blue;
  Color signalLineColor = Colors.red;
  Color posHistogramColor = Colors.green;
  Color negHistogramColor = Colors.red;

  int fastPeriod = 12;
  int slowPeriod = 26;
  int signalPeriod = 9;

  final List<double> macdValues = [];
  final List<double> signalValues = [];
  final List<double> histogramValues = [];
  final List<ICandle> candles = [];

  Macd({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
    Color macdLineColor = Colors.blue,
    Color signalLineColor = Colors.red,
    Color posHistogramColor = Colors.green,
    Color negHistogramColor = Colors.red,
  }) : super(
            id: generateV4(),
            type: IndicatorType.macd,
            displayMode: DisplayMode.panel);

  Macd._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
    this.macdLineColor = Colors.blue,
    this.signalLineColor = Colors.red,
    this.posHistogramColor = Colors.green,
    this.negHistogramColor = Colors.red,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || macdValues.isEmpty) return;

    // Draw MACD and signal lines
    _drawLine(canvas, macdValues, macdLineColor);
    _drawLine(canvas, signalValues, signalLineColor);

    // Draw histogram
    _drawHistogram(canvas, histogramValues);

    // Draw the zero line
    canvas.drawLine(
      Offset(leftPos, toY(0)),
      Offset(rightPos, toY(0)),
      Paint()
        ..color = Colors.grey.withAlpha(180)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLine(Canvas canvas, List<double> values, Color color) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Start from the first valid value (after sufficient periods)
    int startIndex = slowPeriod + signalPeriod - 1;
    if (startIndex >= values.length || startIndex >= candles.length) return;

    path.moveTo(toX(startIndex.toDouble()), toY(values[startIndex]));

    // Only draw up to the number of candles we actually have
    int endIndex = math.min(values.length, candles.length);

    for (int i = startIndex + 1; i < endIndex; i++) {
      path.lineTo(toX(i.toDouble()), toY(values[i]));
    }

    canvas.drawPath(path, paint);
  }

  void _drawHistogram(Canvas canvas, List<double> values) {
    if (values.isEmpty) return;

    final histWidth = xStepWidth * 0.4;

    // Start from the first valid value (after sufficient periods)
    int startIndex = slowPeriod + signalPeriod - 1;
    if (startIndex >= values.length || startIndex >= candles.length) return;

    // Only draw up to the number of candles we actually have
    int endIndex = math.min(values.length, candles.length);

    for (int i = startIndex; i < endIndex; i++) {
      final x = toX(i.toDouble());
      final zero = toY(0);
      final y = toY(values[i]);

      canvas.drawRect(
          Rect.fromPoints(
              Offset(x - histWidth, zero), Offset(x + histWidth, y)),
          Paint()
            ..color = values[i] > 0 ? posHistogramColor : negHistogramColor
            ..style = PaintingStyle.fill);
    }
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    candles.addAll(data.sublist(candles.isEmpty ? 0 : candles.length));

    // Calculate indicators and find min/max for y-axis values
    _calculateIndicators();

    // Determine min and max values for y-axis
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (int i = 0; i < macdValues.length; i++) {
      if (i >= slowPeriod + signalPeriod - 1) {
        minValue = math.min(minValue, macdValues[i]);
        minValue = math.min(minValue, signalValues[i]);
        minValue = math.min(minValue, histogramValues[i]);

        maxValue = math.max(maxValue, macdValues[i]);
        maxValue = math.max(maxValue, signalValues[i]);
        maxValue = math.max(maxValue, histogramValues[i]);
      }
    }

    // Add a bit of padding
    double range = maxValue - minValue;
    if (range > 0) {
      minValue -= range * 0.1;
      maxValue += range * 0.1;
    } else {
      // Provide default values if range is zero
      minValue = -1;
      maxValue = 1;
    }

    // Ensure zero is included in the range
    if (minValue > 0) minValue = 0;
    if (maxValue < 0) maxValue = 0;

    yMinValue = minValue;
    yMaxValue = maxValue;

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculateIndicators() {
    macdValues.clear();
    signalValues.clear();
    histogramValues.clear();

    if (candles.isEmpty) return;

    // Calculate EMAs
    List<double> prices = candles.map((c) => c.close).toList();
    List<double> fastEMA = _calculateEMA(prices, fastPeriod);
    List<double> slowEMA = _calculateEMA(prices, slowPeriod);

    // Calculate MACD values
    macdValues.clear();
    macdValues.addAll(List.filled(prices.length, 0));
    for (int i = slowPeriod - 1; i < prices.length; i++) {
      macdValues[i] = fastEMA[i] - slowEMA[i];
    }

    // Calculate signal line (EMA of MACD)
    signalValues.clear();
    signalValues.addAll(_calculateEMA(macdValues, signalPeriod));

    // Calculate histogram
    histogramValues.clear();
    histogramValues.addAll(List.filled(prices.length, 0));
    // Only calculate histogram where we have valid signal values
    int validStartIndex = slowPeriod + signalPeriod - 2;
    for (int i = validStartIndex; i < macdValues.length; i++) {
      histogramValues[i] = macdValues[i] - signalValues[i];
    }
  }

  List<double> _calculateEMA(List<double> prices, int period) {
    List<double> emaValues = List.filled(prices.length, 0);

    // Initialize SMA for first EMA value
    if (prices.length >= period) {
      // Same logic as before but use emaValues instead
      double sum = 0;
      for (int i = 0; i < period; i++) {
        sum += prices[i];
      }
      emaValues[period - 1] = sum / period;

      // Calculate multiplier: (2 / (period + 1))
      double multiplier = 2 / (period + 1);

      // Calculate EMA values
      for (int i = period; i < prices.length; i++) {
        emaValues[i] =
            (prices[i] - emaValues[i - 1]) * multiplier + emaValues[i - 1];
      }
    }

    return emaValues;
  }

  @override
  showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => MacdSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['fastPeriod'] = fastPeriod;
    json['slowPeriod'] = slowPeriod;
    json['signalPeriod'] = signalPeriod;
    json['macdLineColor'] = colorToJson(macdLineColor);
    json['signalLineColor'] = colorToJson(signalLineColor);
    json['posHistogramColor'] = colorToJson(posHistogramColor);
    json['negHistogramColor'] = colorToJson(negHistogramColor);
    return json;
  }

  factory Macd.fromJson(Map<String, dynamic> json) {
    return Macd._(
      id: json['id'],
      type: IndicatorType.macd,
      displayMode: DisplayMode.panel,
      fastPeriod: json['fastPeriod'] ?? 12,
      slowPeriod: json['slowPeriod'] ?? 26,
      signalPeriod: json['signalPeriod'] ?? 9,
      macdLineColor: json['macdLineColor'] != null
          ? colorFromJson(json['macdLineColor'])
          : Colors.blue,
      signalLineColor: json['signalLineColor'] != null
          ? colorFromJson(json['signalLineColor'])
          : Colors.red,
      posHistogramColor: json['posHistogramColor'] != null
          ? colorFromJson(json['posHistogramColor'])
          : Colors.green,
      negHistogramColor: json['negHistogramColor'] != null
          ? colorFromJson(json['negHistogramColor'])
          : Colors.red,
    );
  }
}
