import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/rsi_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Rsi extends Indicator {
  int rsiMaPeriod = 14;
  int rsiPeriod = 14;
  Color rsiColor = Colors.blue;
  Color rsiMaColor = Colors.orange;

  final List<double> rsiMaValues = [];
  final List<double> rsiValues = [];
  final List<ICandle> candles = [];

  Rsi()
      : super(
            id: generateV4(),
            type: IndicatorType.rsi,
            displayMode: DisplayMode.panel);

  Rsi._({
    required super.id,
    this.rsiPeriod = 14,
    this.rsiMaPeriod = 9,
    this.rsiColor = Colors.blue,
    this.rsiMaColor = Colors.orange,
  }) : super(type: IndicatorType.rsi, displayMode: DisplayMode.panel);

  @override
  drawIndicator({required Canvas canvas}) {
    if (rsiValues.isEmpty) return;

    final path = Path();

    // Start drawing from the first calculated RSI value (after period)
    int startIndex = candles.length - rsiValues.length;

    // Set starting point
    path.moveTo(
      toX(startIndex.toDouble()),
      toY(rsiValues[0]),
    );

    // Draw the line
    for (int i = 1; i < rsiValues.length; i++) {
      path.lineTo(
        toX((startIndex + i).toDouble()),
        toY(rsiValues[i]),
      );
    }

    // Draw the path
    canvas.drawPath(
      path,
      Paint()
        ..color = rsiColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Draw overbought highlight (above 70)
    final overboughtPath = Path();
    bool inOverbought = false;

    // Iterate through RSI values to create path for overbought regions
    for (int i = 0; i < rsiValues.length; i++) {
      final x = toX((startIndex + i).toDouble());
      final y = toY(rsiValues[i]);
      final overboughtY = toY(70);

      if (rsiValues[i] > 70) {
        if (!inOverbought) {
          // Find the exact crossing point with the overbought line
          if (i > 0) {
            final prevX = toX((startIndex + i - 1).toDouble());
            // ignore: unused_local_variable
            final prevY = toY(rsiValues[i - 1]);
            final t =
                (70 - rsiValues[i - 1]) / (rsiValues[i] - rsiValues[i - 1]);
            final crossX = prevX + t * (x - prevX);

            overboughtPath.moveTo(crossX, overboughtY);
          } else {
            overboughtPath.moveTo(x, overboughtY);
          }
          inOverbought = true;
        }
        overboughtPath.lineTo(x, y);
      } else if (inOverbought) {
        // Find the exact crossing point with the overbought line
        final prevX = toX((startIndex + i - 1).toDouble());
        // ignore: unused_local_variable
        final prevY = toY(rsiValues[i - 1]);
        final t = (70 - rsiValues[i]) / (rsiValues[i - 1] - rsiValues[i]);
        final crossX = x - t * (x - prevX);

        overboughtPath.lineTo(crossX, overboughtY);
        overboughtPath.lineTo(crossX, overboughtY);
        overboughtPath.close();
        inOverbought = false;
      }
    }

    // Close the path if it ends while still in overbought territory
    if (inOverbought) {
      final lastX = toX((startIndex + rsiValues.length - 1).toDouble());
      overboughtPath.lineTo(lastX, toY(70));
      overboughtPath.close();
    }

    // Draw oversold highlight (below 30)
    final oversoldPath = Path();
    bool inOversold = false;

    // Iterate through RSI values to create path for oversold regions
    for (int i = 0; i < rsiValues.length; i++) {
      final x = toX((startIndex + i).toDouble());
      final y = toY(rsiValues[i]);
      final oversoldY = toY(30);

      if (rsiValues[i] < 30) {
        if (!inOversold) {
          // Find the exact crossing point with the oversold line
          if (i > 0) {
            final prevX = toX((startIndex + i - 1).toDouble());
            // ignore: unused_local_variable
            final prevY = toY(rsiValues[i - 1]);
            final t =
                (30 - rsiValues[i - 1]) / (rsiValues[i] - rsiValues[i - 1]);
            final crossX = prevX + t * (x - prevX);

            oversoldPath.moveTo(crossX, oversoldY);
          } else {
            oversoldPath.moveTo(x, oversoldY);
          }
          inOversold = true;
        }
        oversoldPath.lineTo(x, y);
      } else if (inOversold) {
        // Find the exact crossing point with the oversold line
        final prevX = toX((startIndex + i - 1).toDouble());
        // ignore: unused_local_variable
        final prevY = toY(rsiValues[i - 1]);
        final t = (30 - rsiValues[i]) / (rsiValues[i - 1] - rsiValues[i]);
        final crossX = x - t * (x - prevX);

        oversoldPath.lineTo(crossX, oversoldY);
        oversoldPath.lineTo(crossX, oversoldY);
        oversoldPath.close();
        inOversold = false;
      }
    }

    // Close the path if it ends while still in oversold territory
    if (inOversold) {
      final lastX = toX((startIndex + rsiValues.length - 1).toDouble());
      oversoldPath.lineTo(lastX, toY(30));
      oversoldPath.close();
    }

    // Fill the paths
    canvas.drawPath(
      overboughtPath,
      Paint()
        ..color = Colors.red.withAlpha(50)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      oversoldPath,
      Paint()
        ..color = Colors.green.withAlpha(50)
        ..style = PaintingStyle.fill,
    );

    if (rsiMaValues.isNotEmpty) {
      final maPath = Path();

      // Start drawing from the first calculated MA value
      int maStartIndex = candles.length - rsiValues.length + (rsiMaPeriod - 1);

      // Set starting point
      maPath.moveTo(
        toX(maStartIndex.toDouble()),
        toY(rsiMaValues[rsiMaPeriod - 1]),
      );

      // Draw the line
      for (int i = rsiMaPeriod; i < rsiMaValues.length; i++) {
        maPath.lineTo(
          toX((maStartIndex + i - (rsiMaPeriod - 1)).toDouble()),
          toY(rsiMaValues[i]),
        );
      }

      // Draw the path
      canvas.drawPath(
        maPath,
        Paint()
          ..color = rsiMaColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Draw the overbought line (70)
    canvas.drawLine(
      Offset(leftPos, toY(70)),
      Offset(rightPos, toY(70)),
      Paint()
        ..color = Colors.red.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw the oversold line (30)
    canvas.drawLine(
      Offset(leftPos, toY(30)),
      Offset(rightPos, toY(30)),
      Paint()
        ..color = Colors.green.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  updateData(List<ICandle> data) {
    candles.addAll(data.sublist(candles.isEmpty ? 0 : candles.length));

    rsiValues.clear();

    if (data.length <= rsiPeriod) {
      yMaxValue = 100;
      yMinValue = 0;

      yValues = generateNiceAxisValues(yMinValue, yMaxValue);

      yMinValue = yValues.first;
      yMaxValue = yValues.last;
      return;
    }

    List<double> gains = [];
    List<double> losses = [];

    // Calculate initial gains and losses
    for (int i = 1; i <= rsiPeriod; i++) {
      double change = data[i].close - data[i - 1].close;
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    // Calculate first RSI value
    double avgGain = gains.reduce((a, b) => a + b) / rsiPeriod;
    double avgLoss = losses.reduce((a, b) => a + b) / rsiPeriod;

    // Add first RSI value
    if (avgLoss == 0) {
      rsiValues.add(100);
    } else {
      double rs = avgGain / avgLoss;
      rsiValues.add(100 - (100 / (1 + rs)));
    }

    // Calculate remaining RSI values
    for (int i = rsiPeriod + 1; i < data.length; i++) {
      double change = data[i].close - data[i - 1].close;
      double currentGain = change > 0 ? change : 0;
      double currentLoss = change < 0 ? -change : 0;

      // Smooth averages
      avgGain = ((avgGain * (rsiPeriod - 1)) + currentGain) / rsiPeriod;
      avgLoss = ((avgLoss * (rsiPeriod - 1)) + currentLoss) / rsiPeriod;

      if (avgLoss == 0) {
        rsiValues.add(100);
      } else {
        double rs = avgGain / avgLoss;
        rsiValues.add(100 - (100 / (1 + rs)));
      }
    }

    rsiMaValues.clear();

    if (rsiValues.length >= rsiMaPeriod) {
      // Fill with zeros for the first (rsiMaPeriod-1) positions
      for (int i = 0; i < rsiMaPeriod - 1; i++) {
        rsiMaValues.add(0);
      }

      // Calculate MA values for the rest
      for (int i = rsiMaPeriod - 1; i < rsiValues.length; i++) {
        double sum = 0;
        for (int j = i - (rsiMaPeriod - 1); j <= i; j++) {
          sum += rsiValues[j];
        }
        rsiMaValues.add(sum / rsiMaPeriod);
      }
    }

    calculateYValueRange(data);

    // yLabelSize = getLargetRnderBoxSizeForList(
    //     yValues.map((v) => v.toString()).toList(), yAxisSettings.axisTextStyle);
  }

  @override
  calculateYValueRange(List<ICandle> data) {
    yMaxValue = 100;
    yMinValue = 0;

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);

    yMinValue = yValues.first;
    yMaxValue = yValues.last;
  }

  @override
  showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => RsiSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['rsiPeriod'] = rsiPeriod;
    json['rsiMaPeriod'] = rsiMaPeriod;
    json['rsiColor'] = colorToJson(rsiColor);
    json['rsiMaColor'] = colorToJson(rsiMaColor);
    return json;
  }

  factory Rsi.fromJson(Map<String, dynamic> json) {
    return Rsi._(
      id: json['id'],
      rsiPeriod: json['rsiPeriod'] ?? 14,
      rsiMaPeriod: json['rsiMaPeriod'] ?? 9,
      rsiColor: json['rsiColor'] != null
          ? colorFromJson(json['rsiColor'])
          : Colors.blue,
      rsiMaColor: json['rsiMaColor'] != null
          ? colorFromJson(json['rsiMaColor'])
          : Colors.orange,
    );
  }
}
