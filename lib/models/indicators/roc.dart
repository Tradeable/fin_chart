import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/roc_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Roc extends Indicator {
  int period;
  Color lineColor;

  final List<double> rocValues = [];
  final List<ICandle> candles = [];

  Roc({
    this.period = 12,
    this.lineColor = Colors.cyan,
  }) : super(
            id: generateV4(),
            type: IndicatorType.roc,
            displayMode: DisplayMode.panel);

  Roc._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 12,
    this.lineColor = Colors.cyan,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || rocValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    // Draw from the first valid ROC value (after period)
    for (int i = period; i < rocValues.length; i++) {
      final x = toX(i.toDouble());
      final y = toY(rocValues[i]);

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

    // Draw zero line
    canvas.drawLine(
      Offset(leftPos, toY(0)),
      Offset(rightPos, toY(0)),
      Paint()
        ..color = Colors.grey.withAlpha(180)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
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

    _calculateROC();
    calculateYValueRange(candles);
  }

  @override
  calculateYValueRange(List<ICandle> data) {
    if (rocValues.isEmpty) {
      yMinValue = -10;
      yMaxValue = 10;
    } else {
      double minValue = double.infinity;
      double maxValue = double.negativeInfinity;

      for (int i = period; i < rocValues.length; i++) {
        minValue = minValue < rocValues[i] ? minValue : rocValues[i];
        maxValue = maxValue > rocValues[i] ? maxValue : rocValues[i];
      }

      double range = maxValue - minValue;
      if (range > 0) {
        minValue -= range * 0.1;
        maxValue += range * 0.1;
      } else {
        minValue = -1;
        maxValue = 1;
      }

      yMinValue = minValue;
      yMaxValue = maxValue;
    }

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    yMinValue = yValues.first;
    yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculateROC() {
    rocValues.clear();
    if (candles.length < period) {
      return;
    }

    // Add placeholders for values before the first valid ROC
    for (int i = 0; i < period; i++) {
      rocValues.add(0);
    }

    for (int i = period; i < candles.length; i++) {
      final currentClose = candles[i].close;
      final pastClose = candles[i - period].close;
      if (pastClose != 0) {
        final roc = ((currentClose - pastClose) / pastClose) * 100;
        rocValues.add(roc);
      } else {
        rocValues.add(0);
      }
    }
  }

  @override
  void showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog<Roc>(
      context: context,
      builder: (context) => RocSettingsDialog(
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

  factory Roc.fromJson(Map<String, dynamic> json) {
    return Roc._(
      id: json['id'],
      type: IndicatorType.roc,
      displayMode: DisplayMode.panel,
      period: json['period'] ?? 12,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.cyan,
    );
  }
}
