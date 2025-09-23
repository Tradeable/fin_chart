import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/ema_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Ema extends Indicator {
  Color lineColor = Colors.orange;
  int period = 20;

  final List<double> emaValues = [];
  final List<ICandle> candles = [];

  Ema({
    this.period = 20,
    this.lineColor = Colors.orange,
  }) : super(
            id: generateV4(),
            type: IndicatorType.ema,
            displayMode: DisplayMode.main);

  Ema._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 20,
    this.lineColor = Colors.orange,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || emaValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Start from period-1 where actual EMA values begin
    final startIndex = period - 1;
    if (startIndex >= emaValues.length) return;

    final path = Path();
    bool pathStarted = false;

    // Draw only the valid EMA values
    for (int i = startIndex; i < emaValues.length; i++) {
      if (emaValues[i] == 0) continue; // Skip placeholder values

      final x = toX(i.toDouble());
      final y = toY(emaValues[i]);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    if (pathStarted) {
      canvas.drawPath(path, paint);
    }
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

    _calculateEMA();

    // For DisplayMode.main, we don't need to set yMinValue and yMaxValue
    // as the indicator will use the values from the main chart

    // However, still set yLabelSize for consistency
    yLabelSize = getLargetRnderBoxSizeForList(
        ['0.00'], // Just a placeholder
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculateEMA() {
    emaValues.clear();

    if (candles.length < period) {
      return;
    }

    // Calculate smoothing factor: 2 / (period + 1)
    double smoothing = 2.0 / (period + 1);

    // Get SMA for the first EMA value
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
    }
    double firstEma = sum / period;

    // Add placeholder zeros for candles before the period
    for (int i = 0; i < period - 1; i++) {
      emaValues.add(0);
    }

    // Add the first EMA value (which is just the SMA)
    emaValues.add(firstEma);

    // Calculate the rest of the EMA values
    for (int i = period; i < candles.length; i++) {
      double currentPrice = candles[i].close;
      double previousEma = emaValues.last;

      // EMA formula: EMA = (Close - Previous EMA) * smoothing + Previous EMA
      double currentEma =
          (currentPrice - previousEma) * smoothing + previousEma;
      emaValues.add(currentEma);
    }
  }

  @override
  showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => EmaSettingsDialog(
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

  factory Ema.fromJson(Map<String, dynamic> json) {
    return Ema._(
      id: json['id'] ?? generateV4(), // Fallback to new ID if not provided
      type: IndicatorType.ema,
      displayMode: DisplayMode.main,
      period: json['period'] ?? 20,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.orange,
    );
  }
}
