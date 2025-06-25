import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/supertrend_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Supertrend extends Indicator {
  int period;
  double multiplier;
  Color uptrendColor;
  Color downtrendColor;
  double strokeWidth;

  final List<double> supertrendValues = [];
  final List<bool> trendDirection = []; // true for uptrend, false for downtrend
  final List<ICandle> candles = [];

  Supertrend({
    this.period = 10,
    this.multiplier = 3.0,
    this.uptrendColor = Colors.green,
    this.downtrendColor = Colors.red,
    this.strokeWidth = 2.0,
  }) : super(
            id: generateV4(),
            type: IndicatorType.supertrend,
            displayMode: DisplayMode.main);

  Supertrend._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 10,
    this.multiplier = 3.0,
    this.uptrendColor = Colors.green,
    this.downtrendColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || supertrendValues.isEmpty) return;

    // Draw filled areas first (so lines appear on top)
    _drawFilledAreas(canvas);

    // Then draw the supertrend lines
    _drawSupertrendLines(canvas);
  }

  void _drawFilledAreas(Canvas canvas) {
    for (int i = period; i < supertrendValues.length - 1; i++) {
      if (supertrendValues[i] == 0 || supertrendValues[i + 1] == 0) continue;

      final x1 = toX(i.toDouble());
      final x2 = toX((i + 1).toDouble());

      Color fillColor = trendDirection[i] ? uptrendColor : downtrendColor;

      // Create path for the filled area
      final path = Path();

      if (trendDirection[i]) {
        // Uptrend: fill between supertrend line and candle lows
        path.moveTo(x1, toY(supertrendValues[i]));
        path.lineTo(x2, toY(supertrendValues[i + 1]));
        path.lineTo(x2, toY(candles[i + 1].low));
        path.lineTo(x1, toY(candles[i].low));
        path.close();
      } else {
        // Downtrend: fill between supertrend line and candle highs
        path.moveTo(x1, toY(supertrendValues[i]));
        path.lineTo(x2, toY(supertrendValues[i + 1]));
        path.lineTo(x2, toY(candles[i + 1].high));
        path.lineTo(x1, toY(candles[i].high));
        path.close();
      }

      // Draw filled area with transparency
      final fillPaint = Paint()
        ..color = fillColor.withAlpha(30) // Adjust transparency as needed
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);
    }
  }

  void _drawSupertrendLines(Canvas canvas) {
    final path = Path();
    bool pathStarted = false;
    Color currentColor = uptrendColor;

    for (int i = period; i < supertrendValues.length; i++) {
      if (supertrendValues[i] == 0) continue;

      final x = toX(i.toDouble());
      final y = toY(supertrendValues[i]);

      // Check if trend direction changed
      if (i > period && trendDirection[i] != trendDirection[i - 1]) {
        // Draw the current path with current color
        if (pathStarted) {
          final paint = Paint()
            ..color = currentColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;
          canvas.drawPath(path, paint);
        }

        // Start new path with new color
        currentColor = trendDirection[i] ? uptrendColor : downtrendColor;
        path.reset();
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        if (!pathStarted) {
          currentColor = trendDirection[i] ? uptrendColor : downtrendColor;
          path.moveTo(x, y);
          pathStarted = true;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    // Draw the final path
    if (pathStarted) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    if (candles.isEmpty) {
      candles.addAll(data);
    } else {
      int existingCount = candles.length;
      if (data.length > existingCount) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    _calculateSupertrend();
  }

  void _calculateSupertrend() {
    supertrendValues.clear();
    trendDirection.clear();

    if (candles.length < period + 1) return;

    List<double> atrValues = _calculateATR();
    List<double> hl2 = candles.map((c) => (c.high + c.low) / 2).toList();

    List<double> upperBand = [];
    List<double> lowerBand = [];
    List<double> finalUpperBand = [];
    List<double> finalLowerBand = [];

    // Initialize with zeros
    for (int i = 0; i < candles.length; i++) {
      upperBand.add(0);
      lowerBand.add(0);
      finalUpperBand.add(0);
      finalLowerBand.add(0);
      supertrendValues.add(0);
      trendDirection.add(true);
    }

    // Calculate bands starting from period index
    for (int i = period; i < candles.length; i++) {
      upperBand[i] = hl2[i] + (multiplier * atrValues[i]);
      lowerBand[i] = hl2[i] - (multiplier * atrValues[i]);

      // Calculate final upper band
      finalUpperBand[i] = (upperBand[i] < finalUpperBand[i - 1] ||
              candles[i - 1].close > finalUpperBand[i - 1])
          ? upperBand[i]
          : finalUpperBand[i - 1];

      // Calculate final lower band
      finalLowerBand[i] = (lowerBand[i] > finalLowerBand[i - 1] ||
              candles[i - 1].close < finalLowerBand[i - 1])
          ? lowerBand[i]
          : finalLowerBand[i - 1];

      // Determine supertrend direction and value
      if (i == period) {
        // Initialize first value
        supertrendValues[i] = finalUpperBand[i];
        trendDirection[i] = false; // Start with downtrend
      } else {
        if (supertrendValues[i - 1] == finalUpperBand[i - 1] &&
            candles[i].close <= finalUpperBand[i]) {
          supertrendValues[i] = finalUpperBand[i];
          trendDirection[i] = false; // Downtrend
        } else if (supertrendValues[i - 1] == finalUpperBand[i - 1] &&
            candles[i].close > finalUpperBand[i]) {
          supertrendValues[i] = finalLowerBand[i];
          trendDirection[i] = true; // Uptrend
        } else if (supertrendValues[i - 1] == finalLowerBand[i - 1] &&
            candles[i].close >= finalLowerBand[i]) {
          supertrendValues[i] = finalLowerBand[i];
          trendDirection[i] = true; // Uptrend
        } else if (supertrendValues[i - 1] == finalLowerBand[i - 1] &&
            candles[i].close < finalLowerBand[i]) {
          supertrendValues[i] = finalUpperBand[i];
          trendDirection[i] = false; // Downtrend
        }
      }
    }
  }

  List<double> _calculateATR() {
    List<double> atrValues = List.filled(candles.length, 0);
    List<double> trueRanges = [];

    // Calculate true ranges
    trueRanges.add(candles[0].high - candles[0].low);

    for (int i = 1; i < candles.length; i++) {
      double highLow = candles[i].high - candles[i].low;
      double highPrevClose = (candles[i].high - candles[i - 1].close).abs();
      double lowPrevClose = (candles[i].low - candles[i - 1].close).abs();

      double tr = math.max(highLow, math.max(highPrevClose, lowPrevClose));
      trueRanges.add(tr);
    }

    // Calculate ATR
    if (candles.length >= period) {
      // First ATR (simple average)
      double sum = 0;
      for (int i = 0; i < period; i++) {
        sum += trueRanges[i];
      }
      atrValues[period - 1] = sum / period;

      // Subsequent ATRs (smoothed)
      for (int i = period; i < candles.length; i++) {
        atrValues[i] =
            (atrValues[i - 1] * (period - 1) + trueRanges[i]) / period;
      }
    }

    return atrValues;
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    // You'll need to create this dialog
    showDialog(
      context: context,
      builder: (context) => SupertrendSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['period'] = period;
    json['multiplier'] = multiplier;
    json['uptrendColor'] = colorToJson(uptrendColor);
    json['downtrendColor'] = colorToJson(downtrendColor);
    json['strokeWidth'] = strokeWidth;
    return json;
  }

  factory Supertrend.fromJson(Map<String, dynamic> json) {
    return Supertrend._(
      id: json['id'] ?? generateV4(),
      type: IndicatorType.supertrend,
      displayMode: DisplayMode.main,
      period: json['period'] ?? 10,
      multiplier: json['multiplier']?.toDouble() ?? 3.0,
      uptrendColor: json['uptrendColor'] != null
          ? colorFromJson(json['uptrendColor'])
          : Colors.green,
      downtrendColor: json['downtrendColor'] != null
          ? colorFromJson(json['downtrendColor'])
          : Colors.red,
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
    );
  }
}
