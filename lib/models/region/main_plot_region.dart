import 'dart:math';

import 'package:fin_chart/models/enums/candle_state.dart';
import 'package:fin_chart/models/enums/chart_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/models/settings/y_axis_settings.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:fin_chart/utils/constants.dart';
import 'package:flutter/material.dart';

class MainPlotRegion extends PlotRegion {
  final List<ICandle> candles;
  final List<Indicator> indicators = [];
  final List<FundamentalEvent> fundamentalEvents = [];
  FundamentalEvent? get selectedEvent => _selectedEvent;
  FundamentalEvent? _selectedEvent;
  ChartType chartType;

  MainPlotRegion({
    String? id,
    required this.candles,
    required super.yAxisSettings,
    super.yMinValue,
    super.yMaxValue,
    this.chartType = ChartType.candlestick,
  }) : super(id: id ?? generateV4()) {
    if (candles.isNotEmpty) {
      (double, double) range = findMinMaxWithPercentage(candles);

      if (yMinValue == 0 && yMaxValue == 1) {
        yMinValue = range.$1;
        yMaxValue = range.$2;
      } else {
        yMinValue = min(range.$1, yMinValue);
        yMaxValue = max(range.$2, yMaxValue);
      }

      yValues = generateNiceAxisValues(yMinValue, yMaxValue);

      yMinValue = yValues.first;
      yMaxValue = yValues.last;

      yLabelSize = getLargetRnderBoxSizeForList(
          yValues.map((v) => v.toString()).toList(),
          yAxisSettings.axisTextStyle);
    }
  }

  @override
  void updateRegionProp(
      {required double leftPos,
      required double topPos,
      required double rightPos,
      required double bottomPos,
      required double xStepWidth,
      required double xOffset,
      required double yMinValue,
      required double yMaxValue}) {
    for (Indicator indicator in indicators) {
      indicator.updateRegionProp(
          leftPos: leftPos,
          topPos: topPos,
          rightPos: rightPos,
          bottomPos: bottomPos,
          xStepWidth: xStepWidth,
          xOffset: xOffset,
          yMinValue: yMinValue,
          yMaxValue: yMaxValue);
    }
    super.updateRegionProp(
        leftPos: leftPos,
        topPos: topPos,
        rightPos: rightPos,
        bottomPos: bottomPos,
        xStepWidth: xStepWidth,
        xOffset: xOffset,
        yMinValue: yMinValue,
        yMaxValue: yMaxValue);
  }

  @override
  void updateData(List<ICandle> data) {
    candles.addAll(data.sublist(candles.isEmpty ? 0 : candles.length));
    (double, double) range = findMinMaxWithPercentage(candles);

    if (yMinValue == 0 && yMaxValue == 1) {
      yMinValue = range.$1;
      yMaxValue = range.$2;
    } else {
      yMinValue = min(range.$1, yMinValue);
      yMaxValue = max(range.$2, yMaxValue);
    }

    yValues = generateNiceAxisValues(yMinValue, yMaxValue);

    yMinValue = yValues.first;
    yMaxValue = yValues.last;

    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(), yAxisSettings.axisTextStyle);

    for (Indicator indicator in indicators) {
      indicator.updateData(data);
    }
  }

  @override
  void drawBaseLayer(Canvas canvas) {
    if (chartType == ChartType.line) {
      _drawLineGraph(canvas);
    } else {
      _drawCandlestickGraph(canvas);
    }

    // Draw indicators on top of the base layer
    for (Indicator indicator in indicators) {
      indicator.drawIndicator(canvas: canvas);
    }
  }

  void _drawLineGraph(Canvas canvas) {
    if (candles.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(toX(0), toY(candles[0].close));

    for (int i = 1; i < candles.length; i++) {
      path.lineTo(toX(i.toDouble()), toY(candles[i].close));
    }

    canvas.drawPath(path, paint);

    // Also draw fundamental events in line mode
    for (int i = 0; i < candles.length; i++) {
      drawFundamentalEvents(canvas, i);
    }
  }

  void _drawCandlestickGraph(Canvas canvas) {
    for (int i = 0; i < candles.length; i++) {
      ICandle candle = candles[i];
      Color candleColor;
      if (candle.state == CandleState.selected) {
        candleColor = Colors.orange;
      } else if (candle.state == CandleState.highlighted) {
        candleColor = Colors.purple;
      } else if (candle.open < candle.close) {
        candleColor = Colors.green;
      } else {
        candleColor = Colors.red;
      }

      double maxVolume = candles
          .reduce((currentMax, candle) =>
              candle.volume > currentMax.volume ? candle : currentMax)
          .volume;

      maxVolume = maxVolume == 0 ? 1 : maxVolume;

      Paint volumePaint = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.fill
        ..color = candleColor.withAlpha(100);
      canvas.drawRect(
          Rect.fromLTWH(
              toX(i.toDouble()) - (xStepWidth) * 0.45,
              bottomPos,
              xStepWidth * 0.9,
              -((candle.volume / maxVolume) * (bottomPos - topPos) * 0.2)),
          volumePaint);

      Paint paint = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.fill
        ..color = candleColor;

      canvas.drawLine(Offset(toX(i.toDouble()), toY(candle.high)),
          Offset(toX(i.toDouble()), toY(candle.low)), paint);

      canvas.drawRect(
          Rect.fromLTRB(
              toX(i.toDouble()) - (xStepWidth) * 0.35,
              toY(candle.open),
              toX(i.toDouble()) + (xStepWidth) * 0.35,
              toY(candle.close)),
          paint);

      drawFundamentalEvents(canvas, i);
    }
  }

  @override
  void drawYAxis(Canvas canvas) {
    double valuseDiff = yValues.last - yValues.first;
    double posDiff = bottomPos - topPos;

    for (double value in yValues) {
      double pos = bottomPos - (value - yValues.first) * posDiff / valuseDiff;

      if (!(value == yValues.first || value == yValues.last)) {
        canvas.drawLine(Offset(leftPos, pos), (Offset(rightPos, pos)), Paint());
        final TextPainter text = TextPainter(
          text: TextSpan(
            text: value.toStringAsFixed(2),
            style: yAxisSettings.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        if (yAxisSettings.yAxisPos == YAxisPos.left) {
          text.paint(
              canvas,
              Offset(leftPos - (text.width + yLabelPadding / 2),
                  pos - text.height / 2));
        }
        if (yAxisSettings.yAxisPos == YAxisPos.right) {
          text.paint(canvas,
              Offset(rightPos + yLabelPadding / 2, pos - text.height / 2));
        }
      }
    }

    if (yAxisSettings.yAxisPos == YAxisPos.left) {
      canvas.drawLine(
          Offset(leftPos, topPos),
          Offset(leftPos, bottomPos),
          Paint()
            ..color = yAxisSettings.axisColor
            ..strokeWidth = yAxisSettings.strokeWidth);
    }
    if (yAxisSettings.yAxisPos == YAxisPos.right) {
      canvas.drawLine(
          Offset(rightPos, topPos),
          Offset(rightPos, bottomPos),
          Paint()
            ..color = yAxisSettings.axisColor
            ..strokeWidth = yAxisSettings.strokeWidth);
    }
  }

  @override
  Widget renderIndicatorToolTip(
      {required Indicator? selectedIndicator,
      required Function(Indicator)? onClick,
      required Function()? onSettings,
      required Function()? onDelete}) {
    return Positioned(
        left: leftPos,
        top: topPos,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...indicators.map((indicator) => indicator.indicatorToolTip(
                selectedIndicator: selectedIndicator,
                onClick: onClick,
                onSettings: onSettings,
                onDelete: onDelete))
          ],
        ));
  }

  void drawFundamentalEvents(Canvas canvas, int index) {
    if (fundamentalEvents.isEmpty) return;
    FundamentalEvent? event;

    for (final e in fundamentalEvents) {
      if (e.index == index) {
        event = e;
        break;
      }
    }

    if (event != null) {
      final xPos = leftPos + xOffset + xStepWidth / 2 + index * xStepWidth;

      // Skip if outside visible area
      final yPos = bottomPos - 20; // Position below x-axis

      // Set position for later tooltip reference
      event.position = Offset(xPos, yPos);
      if (event.index == index) {
        // Draw event icon with larger size for visibility
        final paint = Paint()
          ..color = event.color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(event.position!, 12, paint); // Increased size

        // Draw event text with white background for contrast
        final textSpan = TextSpan(
          text: event.iconText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15, // Increased size
            fontWeight: FontWeight.bold,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            event.position!.dx - textPainter.width / 2,
            event.position!.dy - textPainter.height / 2,
          ),
        );

        // If selected, draw tooltip and vertical line
        if (event.isSelected) {
          event.topPos = topPos; // Add this line
          event.bottomPos = bottomPos; // Add this line
        }
      }
      // Loop through events
      // for (final event in fundamentalEvents) {
      // Find the index of the candle closest to event date
      // int index = event.index;

      // Skip events that don't have a corresponding candle or fall outside visible range
      // if (index < 0) continue;

      // Calculate x position
    }
  }

  // void _drawEventTooltip(Canvas canvas, FundamentalEvent event) {
  //   event.drawTooltip(canvas);
  // }

  void drawEventTooltips(Canvas canvas) {
    for (final event in fundamentalEvents) {
      if (event.isSelected && event.position != null) {
        event.drawTooltip(canvas);
      }
    }
  }

  void handleEventTap(Offset tapPosition) {
    _selectedEvent = null;
    for (var event in fundamentalEvents) {
      if (event.position != null &&
          (event.position! - tapPosition).distance < 20) {
        event.isSelected = true;
        _selectedEvent = event;
      } else {
        event.isSelected = false;
      }
    }
  }

  void updateFundamentalEvents(List<FundamentalEvent> newEvents) {
    fundamentalEvents.addAll(newEvents);
  }

  @override
  void handleIndicatorTap(Offset localPosition, TapDownDetails details) {
    for (final indicator in indicators) {
      indicator.onTapDown(details: details);
    }
  }
}
