// FILE: lib\models\indicators\mfi.dart
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/mfi_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Mfi extends Indicator {
  int period = 14;
  Color lineColor = Colors.purple;
  Color overboughtColor = Colors.red;
  Color oversoldColor = Colors.green;

  final List<double> mfiValues = [];
  final List<ICandle> candles = [];

  // Standard MFI overbought/oversold thresholds
  double overboughtThreshold = 80;
  double oversoldThreshold = 20;

  Mfi({
    this.period = 14,
    this.lineColor = Colors.purple,
    this.overboughtColor = Colors.red,
    this.oversoldColor = Colors.green,
  }) : super(
            id: generateV4(),
            type: IndicatorType.mfi,
            displayMode: DisplayMode.panel);

  Mfi._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.period = 14,
    this.lineColor = Colors.purple,
    this.overboughtColor = Colors.red,
    this.oversoldColor = Colors.green,
  });

  @override
  void drawIndicator({required Canvas canvas}) {
    if (mfiValues.isEmpty) return;

    final path = Path();

    // Start drawing from the first calculated MFI value (after period)
    int startIndex = period;
    if (startIndex >= mfiValues.length) return;

    // Set starting point
    path.moveTo(
      toX(startIndex.toDouble()),
      toY(mfiValues[0]),
    );

    // Draw the line
    for (int i = 1; i < mfiValues.length; i++) {
      path.lineTo(
        toX((startIndex + i).toDouble()),
        toY(mfiValues[i]),
      );
    }

    // Draw the path
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Draw overbought highlight (above threshold)
    _drawThresholdHighlight(
        canvas, overboughtThreshold, overboughtColor, startIndex);

    // Draw oversold highlight (below threshold)
    _drawThresholdHighlight(
        canvas, oversoldThreshold, oversoldColor, startIndex);

    // Draw the overbought line
    canvas.drawLine(
      Offset(leftPos, toY(overboughtThreshold)),
      Offset(rightPos, toY(overboughtThreshold)),
      Paint()
        ..color = overboughtColor.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw the oversold line
    canvas.drawLine(
      Offset(leftPos, toY(oversoldThreshold)),
      Offset(rightPos, toY(oversoldThreshold)),
      Paint()
        ..color = oversoldColor.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw the midline (50)
    canvas.drawLine(
      Offset(leftPos, toY(50)),
      Offset(rightPos, toY(50)),
      Paint()
        ..color = Colors.grey.withAlpha((0.5 * 255).toInt())
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawThresholdHighlight(
      Canvas canvas, double threshold, Color color, int startIndex) {
    final path = Path();
    bool inThresholdArea = false;
    final thresholdY = toY(threshold);
    final compareFunc = threshold == overboughtThreshold
        ? (double value) => value > threshold
        : (double value) => value < threshold;

    // Iterate through MFI values to create path for threshold regions
    for (int i = 0; i < mfiValues.length; i++) {
      final x = toX((startIndex + i).toDouble());
      final y = toY(mfiValues[i]);

      if (compareFunc(mfiValues[i])) {
        if (!inThresholdArea) {
          // Find the exact crossing point with the threshold line
          if (i > 0) {
            final prevX = toX((startIndex + i - 1).toDouble());
            final t = (threshold - mfiValues[i - 1]) /
                (mfiValues[i] - mfiValues[i - 1]);
            final crossX = prevX + t * (x - prevX);

            path.moveTo(crossX, thresholdY);
          } else {
            path.moveTo(x, thresholdY);
          }
          inThresholdArea = true;
        }
        path.lineTo(x, y);
      } else if (inThresholdArea) {
        // Find the exact crossing point with the threshold line
        final prevX = toX((startIndex + i - 1).toDouble());
        final t =
            (threshold - mfiValues[i]) / (mfiValues[i - 1] - mfiValues[i]);
        final crossX = x - t * (x - prevX);

        path.lineTo(crossX, thresholdY);
        path.close();
        inThresholdArea = false;
      }
    }

    // Close the path if it ends while still in threshold territory
    if (inThresholdArea) {
      final lastX = toX((startIndex + mfiValues.length - 1).toDouble());
      path.lineTo(lastX, thresholdY);
      path.close();
    }

    // Fill the path
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(50)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    candles.addAll(data.sublist(candles.isEmpty ? 0 : candles.length));

    _calculateMFI();

    // Set fixed bounds for MFI (0-100)
    yMinValue = 0;
    yMaxValue = 100;

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    yMinValue = yValues.first;
    yMaxValue = yValues.last;

    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculateMFI() {
    mfiValues.clear();

    if (candles.length <= period) {
      return; // Not enough data
    }

    // Calculate typical price and money flow for each candle
    List<double> typicalPrices = [];
    List<double> moneyFlows = [];
    List<double> positiveFlows = [];
    List<double> negativeFlows = [];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Typical price: (High + Low + Close) / 3
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      typicalPrices.add(typicalPrice);

      // Raw money flow: Typical Price * Volume
      final rawMoneyFlow = typicalPrice * candle.volume;
      moneyFlows.add(rawMoneyFlow);

      // Skip first candle for positive/negative flows (need previous for comparison)
      if (i > 0) {
        if (typicalPrice > typicalPrices[i - 1]) {
          // Positive money flow
          positiveFlows.add(rawMoneyFlow);
          negativeFlows.add(0);
        } else if (typicalPrice < typicalPrices[i - 1]) {
          // Negative money flow
          positiveFlows.add(0);
          negativeFlows.add(rawMoneyFlow);
        } else {
          // No change, add zeros to both
          positiveFlows.add(0);
          negativeFlows.add(0);
        }
      } else {
        // For first candle, add zeros
        positiveFlows.add(0);
        negativeFlows.add(0);
      }
    }

    // Calculate MFI values using a rolling window of the period length
    for (int i = period; i < candles.length; i++) {
      double sumPositiveFlow = 0;
      double sumNegativeFlow = 0;

      // Sum the flows over the period
      for (int j = i - period + 1; j <= i; j++) {
        sumPositiveFlow += positiveFlows[j];
        sumNegativeFlow += negativeFlows[j];
      }

      // Calculate Money Ratio
      double moneyRatio = sumNegativeFlow == 0
          ? 100
          : // Avoid division by zero
          sumPositiveFlow / sumNegativeFlow;

      // Calculate MFI: 100 - (100 / (1 + Money Ratio))
      double mfiValue = 100 - (100 / (1 + moneyRatio));

      // Sometimes the value can be slightly out of range due to floating-point precision
      mfiValue = math.min(100, math.max(0, mfiValue));

      mfiValues.add(mfiValue);
    }
  }

  @override
  void showIndicatorSettings(
      {required BuildContext context,
      required Function(Indicator p1) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => MfiSettingsDialog(
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
    json['overboughtColor'] = colorToJson(overboughtColor);
    json['oversoldColor'] = colorToJson(oversoldColor);
    json['overboughtThreshold'] = overboughtThreshold;
    json['oversoldThreshold'] = oversoldThreshold;
    return json;
  }

  factory Mfi.fromJson(Map<String, dynamic> json) {
    return Mfi._(
      id: json['id'],
      type: IndicatorType.mfi,
      displayMode: DisplayMode.panel,
      period: json['period'] ?? 14,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.purple,
      overboughtColor: json['overboughtColor'] != null
          ? colorFromJson(json['overboughtColor'])
          : Colors.red,
      oversoldColor: json['oversoldColor'] != null
          ? colorFromJson(json['oversoldColor'])
          : Colors.green,
    );
  }
}
