import 'dart:math' as math;
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/vwap_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Vwap extends Indicator {
  Color lineColor = Colors.purple;
  double strokeWidth = 2.0;
  bool useSessionReset = true; // Whether to reset VWAP daily
  int sessionStartHour = 9; // Market open hour (for session reset)
  int sessionStartMinute = 0; // Market open minute

  // Band properties
  double standardDeviations = 2.0; // Multiplier for bands
  Color upperBandColor =
      Colors.purple.withValues(alpha: (0.3 * 255).toDouble());
  Color lowerBandColor =
      Colors.purple.withValues(alpha: (0.3 * 255).toDouble());
  bool showBands = true;

  final List<double> vwapValues = [];
  final List<double> upperBandValues = [];
  final List<double> lowerBandValues = [];
  final List<ICandle> candles = [];

  Vwap({
    this.lineColor = Colors.purple,
    this.strokeWidth = 2.0,
    this.useSessionReset = true,
    this.sessionStartHour = 9,
    this.sessionStartMinute = 0,
    this.standardDeviations = 2.0,
    this.upperBandColor = Colors.green,
    this.lowerBandColor = Colors.green,
    this.showBands = true,
  }) : super(
            id: generateV4(),
            type: IndicatorType.vwap,
            displayMode: DisplayMode.main);

  Vwap._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.lineColor = Colors.purple,
    this.strokeWidth = 2.0,
    this.useSessionReset = true,
    this.sessionStartHour = 9,
    this.sessionStartMinute = 0,
    this.standardDeviations = 2.0,
    this.upperBandColor = Colors.green,
    this.lowerBandColor = Colors.green,
    this.showBands = true,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || vwapValues.isEmpty) return;

    // Draw shaded area between bands first
    if (showBands && upperBandValues.isNotEmpty && lowerBandValues.isNotEmpty) {
      _drawBandShading(canvas);
      _drawBandLine(canvas, upperBandValues, upperBandColor);
      _drawBandLine(canvas, lowerBandValues, lowerBandColor);
    }

    // Draw main VWAP line
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool isFirstPoint = true;

    for (int i = 0; i < vwapValues.length; i++) {
      if (vwapValues[i] > 0) {
        // Only draw if VWAP value is valid
        final x = toX(i.toDouble());
        final y = toY(vwapValues[i]);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawBandShading(Canvas canvas) {
    final shadingPaint = Paint()
      ..color = Colors.green.withValues(alpha: (0.1 * 255).toDouble())
      ..style = PaintingStyle.fill;

    final path = Path();
    bool isFirstPoint = true;

    // Draw upper band path
    for (int i = 0; i < upperBandValues.length; i++) {
      if (upperBandValues[i] > 0 &&
          i < vwapValues.length &&
          vwapValues[i] > 0) {
        final x = toX(i.toDouble());
        final y = toY(upperBandValues[i]);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    // Draw lower band path in reverse
    for (int i = lowerBandValues.length - 1; i >= 0; i--) {
      if (lowerBandValues[i] > 0 &&
          i < vwapValues.length &&
          vwapValues[i] > 0) {
        final x = toX(i.toDouble());
        final y = toY(lowerBandValues[i]);
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, shadingPaint);
  }

  void _drawBandLine(Canvas canvas, List<double> values, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool isFirstPoint = true;

    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0 && i < vwapValues.length && vwapValues[i] > 0) {
        final x = toX(i.toDouble());
        final y = toY(values[i]);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    candles.clear();
    candles.addAll(data);
    vwapValues.clear();
    upperBandValues.clear();
    lowerBandValues.clear();

    _calculateVWAP();
  }

  void _calculateVWAP() {
    vwapValues.clear();
    upperBandValues.clear();
    lowerBandValues.clear();

    if (candles.isEmpty) return;

    double cumulativeVolume = 0;
    double cumulativeVolumePrice = 0;
    double cumulativeSquaredDifference = 0;
    DateTime? lastSessionDate;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Check if we need to reset for a new session
      bool shouldReset = false;
      if (useSessionReset && lastSessionDate != null) {
        // Reset if it's a new day or if we've crossed the session start time
        final currentDate =
            DateTime(candle.date.year, candle.date.month, candle.date.day);
        final lastDate = DateTime(
            lastSessionDate.year, lastSessionDate.month, lastSessionDate.day);

        if (currentDate.isAfter(lastDate)) {
          shouldReset = true;
        } else if (currentDate == lastDate) {
          // Same day - check if we've crossed session start time
          final sessionStart = DateTime(
            candle.date.year,
            candle.date.month,
            candle.date.day,
            sessionStartHour,
            sessionStartMinute,
          );

          final lastSessionStart = DateTime(
            lastSessionDate.year,
            lastSessionDate.month,
            lastSessionDate.day,
            sessionStartHour,
            sessionStartMinute,
          );

          if (lastSessionDate.isBefore(lastSessionStart) &&
              candle.date.isAfter(sessionStart)) {
            shouldReset = true;
          }
        }
      }

      if (shouldReset || i == 0) {
        // Reset cumulative values for new session
        cumulativeVolume = 0;
        cumulativeVolumePrice = 0;
        cumulativeSquaredDifference = 0;
      }

      // Calculate typical price: (High + Low + Close) / 3
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;

      // Add to cumulative values
      cumulativeVolumePrice += typicalPrice * candle.volume;
      cumulativeVolume += candle.volume;

      // Calculate VWAP
      double vwapValue = 0;
      if (cumulativeVolume > 0) {
        vwapValue = cumulativeVolumePrice / cumulativeVolume;
      }
      vwapValues.add(vwapValue);

      // Calculate variance for standard deviation bands
      if (vwapValue > 0) {
        final priceDifference = typicalPrice - vwapValue;
        cumulativeSquaredDifference +=
            (priceDifference * priceDifference) * candle.volume;

        // Calculate standard deviation
        final variance = cumulativeSquaredDifference / cumulativeVolume;
        final standardDeviation = math.sqrt(variance);

        // Calculate band values
        final upperBand = vwapValue + (standardDeviations * standardDeviation);
        final lowerBand = vwapValue - (standardDeviations * standardDeviation);

        upperBandValues.add(upperBand);
        lowerBandValues.add(lowerBand);
      } else {
        upperBandValues.add(0);
        lowerBandValues.add(0);
      }

      lastSessionDate = candle.date;
    }
  }

  @override
  showIndicatorSettings({
    required BuildContext context,
    required Function(Indicator) onUpdate,
  }) {
    showDialog(
      context: context,
      builder: (context) => VwapSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['lineColor'] = colorToJson(lineColor);
    json['strokeWidth'] = strokeWidth;
    json['useSessionReset'] = useSessionReset;
    json['sessionStartHour'] = sessionStartHour;
    json['sessionStartMinute'] = sessionStartMinute;
    json['standardDeviations'] = standardDeviations;
    json['upperBandColor'] = colorToJson(upperBandColor);
    json['lowerBandColor'] = colorToJson(lowerBandColor);
    json['showBands'] = showBands;
    return json;
  }

  factory Vwap.fromJson(Map<String, dynamic> json) {
    return Vwap._(
      id: json['id'] ?? generateV4(),
      type: IndicatorType.vwap,
      displayMode: DisplayMode.main,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.purple,
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
      useSessionReset: json['useSessionReset'] ?? true,
      sessionStartHour: json['sessionStartHour'] ?? 9,
      sessionStartMinute: json['sessionStartMinute'] ?? 0,
      standardDeviations: json['standardDeviations']?.toDouble() ?? 2.0,
      upperBandColor: json['upperBandColor'] != null
          ? colorFromJson(json['upperBandColor'])
          : Colors.green,
      lowerBandColor: json['lowerBandColor'] != null
          ? colorFromJson(json['lowerBandColor'])
          : Colors.green,
      showBands: json['showBands'] ?? true,
    );
  }
}
