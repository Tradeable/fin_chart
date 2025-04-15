import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/atr_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

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
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || atrValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    // Draw from the first valid ATR value (after period-1)
    for (int i = period - 1; i < atrValues.length; i++) {
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

    _calculateATR();

    // Find min and max values for y-axis
    double minValue = 0; // ATR is always positive
    double maxValue = 0;

    for (int i = period - 1; i < atrValues.length; i++) {
      maxValue = maxValue > atrValues[i] ? maxValue : atrValues[i];
    }

    // Add some padding
    maxValue *= 1.1;

    yMinValue = minValue;
    yMaxValue = maxValue;

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  @override
  calculateYValueRange(List<ICandle> data) {}

  void _calculateATR() {
    atrValues.clear();

    if (candles.length < period + 1) {
      return; // Need at least period+1 candles
    }

    List<double> trueRanges = [];

    // Calculate first true range
    double tr = candles[0].high - candles[0].low;
    trueRanges.add(tr);

    // Calculate subsequent true ranges
    for (int i = 1; i < candles.length; i++) {
      double highLow = candles[i].high - candles[i].low;
      double highPrevClose = (candles[i].high - candles[i - 1].close).abs();
      double lowPrevClose = (candles[i].low - candles[i - 1].close).abs();

      tr = [highLow, highPrevClose, lowPrevClose]
          .reduce((curr, next) => curr > next ? curr : next);
      trueRanges.add(tr);
    }

    // Calculate first ATR (simple average for first 'period' days)
    double firstATR = 0;
    for (int i = 0; i < period; i++) {
      firstATR += trueRanges[i];
    }
    firstATR /= period;

    // Add placeholders for values before the first valid ATR
    for (int i = 0; i < period - 1; i++) {
      atrValues.add(0);
    }

    // Add first valid ATR
    atrValues.add(firstATR);

    // Calculate subsequent ATRs using smoothing formula: ATR = (Prior ATR * (period-1) + Current TR) / period
    for (int i = period; i < trueRanges.length; i++) {
      double atr = (atrValues.last * (period - 1) + trueRanges[i]) / period;
      atrValues.add(atr);
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
