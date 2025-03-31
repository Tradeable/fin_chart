import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/models/settings/x_axis_settings.dart';
import 'package:fin_chart/utils/constants.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final double leftPos;
  final double topPos;
  final double rightPos;
  final double bottomPos;
  final double xStepWidth;
  final double xOffset;
  final XAxisSettings xAxisSettings;
  final List<PlotRegion> regions;
  final int dataLength;
  final List<ICandle> data;
  final Layer? selectedLayer;
  final double? animationValue;

  ChartPainter({
    super.repaint,
    required this.leftPos,
    required this.topPos,
    required this.rightPos,
    required this.bottomPos,
    required this.xStepWidth,
    required this.xOffset,
    required this.xAxisSettings,
    required this.regions,
    required this.dataLength,
    required this.data,
    this.selectedLayer,
    this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerBoundries = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
        outerBoundries,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.transparent);
    canvas.clipRect(outerBoundries);

    drawXAxis(canvas);

    for (PlotRegion region in regions) {
      region.drawYAxis(canvas);
    }

    for (PlotRegion region in regions) {
      region.drawAxisValue(canvas);
    }

    final innerBoundries = Rect.fromLTRB(leftPos, topPos, rightPos, bottomPos);

    canvas.drawRect(
        innerBoundries,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.transparent);

    canvas.clipRect(innerBoundries);

    for (PlotRegion region in regions) {
      // if (region.isSelected) {
      //   canvas.drawRect(
      //       Rect.fromLTRB(region.leftPos, region.topPos, region.rightPos,
      //           region.bottomPos),
      //       Paint()
      //         ..color = Colors.amber.withAlpha(100)
      //         ..style = PaintingStyle.fill);
      // }
      region.drawBaseLayer(canvas);
      region.drawLayers(canvas);
      canvas.drawLine(
          Offset(leftPos, region.bottomPos),
          Offset(rightPos, region.bottomPos),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3);
    }
    // selectedLayer?.onAimationUpdate(
    //     canvas: canvas, animationValue: animationValue ?? 1);
    // drawFundamentalEvents(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawXAxis(Canvas canvas) {
    final candles = data;
    if (candles.isEmpty) return;

    // Calculate the time between candles
    final timePerCandle = candles.length > 1
        ? candles[1].date.difference(candles[0].date).inMinutes
        : 1;

    // Assign a fixed format for each candle based on its time interval
    String Function(DateTime) formatTime;

    // Define format based on candle time interval
    if (timePerCandle < 1) {
      // Seconds
      formatTime = (date) =>
          '${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } else if (timePerCandle <= 5) {
      // 1-5 min
      formatTime =
          (date) => '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (timePerCandle <= 15) {
      // 5-15 min
      formatTime =
          (date) => '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (timePerCandle <= 60) {
      // 15-60 min
      formatTime =
          (date) => '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (timePerCandle <= 360) {
      // 1-6 hours
      formatTime = (date) => '${date.hour}:00';
    } else if (timePerCandle <= 1440) {
      // 6-24 hours
      formatTime = (date) => '${date.hour}:00';
    } else if (timePerCandle <= 10080) {
      // 1-7 days
      formatTime = (date) => '${date.day}/${date.month}';
    } else if (timePerCandle <= 43200) {
      // 7-30 days
      formatTime =
          (date) => '${date.month}/${date.year.toString().substring(2)}';
    } else if (timePerCandle <= 129600) {
      // 30-90 days
      formatTime = (date) =>
          'Q${(date.month - 1) ~/ 3 + 1}\'${date.year.toString().substring(2)}';
    } else {
      // > 90 days
      formatTime = (date) => '${date.year}';
    }

    // Calculate average label width to determine spacing
    final sampleText = TextPainter(
      text: TextSpan(
        text: formatTime(candles[0].date),
        style: xAxisSettings.axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelWidth =
        sampleText.width + 20; // Larger buffer for earlier overlap prevention
    final availableWidth = rightPos - leftPos;

    // Determine how many labels can fit without overlapping
    final visibleCandlesCount = (availableWidth / xStepWidth).floor();
    final labelsPerCandle = (visibleCandlesCount * labelWidth) > availableWidth
        ? (visibleCandlesCount * labelWidth / availableWidth).ceil()
        : 1;

    // Draw labels for all candles
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final xPos = leftPos + xOffset + xStepWidth / 2 + i * xStepWidth;

      // Skip if outside visible area
      if (xPos < leftPos || xPos > rightPos) continue;

      // Show label only for every nth candle when needed
      if (i % labelsPerCandle == 0) {
        final TextPainter text = TextPainter(
          text: TextSpan(
            text: formatTime(candle.date),
            style: xAxisSettings.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        if (xAxisSettings.xAxisPos == XAxisPos.bottom) {
          text.paint(
            canvas,
            Offset(xPos - text.width / 2, bottomPos + xLabelPadding / 2),
          );

          // Draw larger tick for labeled candles
          canvas.drawLine(
            Offset(xPos, bottomPos - 3),
            Offset(xPos, bottomPos + 3),
            Paint()..color = xAxisSettings.axisColor,
          );

          canvas.drawLine(
            Offset(xPos, topPos),
            Offset(xPos, bottomPos),
            Paint()
              ..color = Colors.grey
              ..strokeWidth = 0.5,
          );
        }

        if (xAxisSettings.xAxisPos == XAxisPos.top) {
          text.paint(
            canvas,
            Offset(xPos - text.width / 2,
                topPos - (text.height + xLabelPadding / 2)),
          );

          // Draw larger tick for labeled candles
          canvas.drawLine(
            Offset(xPos, topPos - 3),
            Offset(xPos, topPos + 3),
            Paint()..color = xAxisSettings.axisColor,
          );
        }
      } else {
        // Draw smaller tick for unlabeled candles
        if (xAxisSettings.xAxisPos == XAxisPos.bottom) {
          canvas.drawLine(
            Offset(xPos, bottomPos - 2),
            Offset(xPos, bottomPos + 2),
            Paint()..color = xAxisSettings.axisColor,
          );
        }

        if (xAxisSettings.xAxisPos == XAxisPos.top) {
          canvas.drawLine(
            Offset(xPos, topPos - 2),
            Offset(xPos, topPos + 2),
            Paint()..color = xAxisSettings.axisColor,
          );
        }
      }

      // Draw grid line for all candles
      // canvas.drawLine(
      //   Offset(xPos, topPos),
      //   Offset(xPos, bottomPos),
      //   Paint()
      //     ..color = Colors.grey
      //     ..strokeWidth = 0.5,
      // );
    }

    // Draw axis line
    if (xAxisSettings.xAxisPos == XAxisPos.bottom) {
      canvas.drawLine(
        Offset(leftPos, bottomPos),
        Offset(rightPos, bottomPos),
        Paint()
          ..color = xAxisSettings.axisColor
          ..strokeWidth = xAxisSettings.strokeWidth,
      );
    }

    if (xAxisSettings.xAxisPos == XAxisPos.top) {
      canvas.drawLine(
        Offset(leftPos, topPos),
        Offset(rightPos, topPos),
        Paint()
          ..color = xAxisSettings.axisColor
          ..strokeWidth = xAxisSettings.strokeWidth,
      );
    }
  }
}
