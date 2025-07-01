import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/ev_sales_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class EvSalesPoint {
  final DateTime date;
  final double value;

  EvSalesPoint({required this.date, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'value': value,
    };
  }

  factory EvSalesPoint.fromJson(Map<String, dynamic> json) {
    return EvSalesPoint(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      value: json['value'].toDouble(),
    );
  }
}

class EvSales extends Indicator {
  Color lineColor = Colors.teal;
  List<EvSalesPoint> points = [];
  double defaultValue = 2.0; // Add this default

  final List<double> values = [];
  final List<ICandle> candles = [];

  EvSales({
    this.lineColor = Colors.teal,
    this.points = const [],
    this.defaultValue = 2.0, // Add to constructor
  }) : super(
            id: generateV4(),
            type: IndicatorType.evSales,
            displayMode: DisplayMode.panel);

  EvSales._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.lineColor = Colors.teal,
    this.points = const [],
    this.defaultValue = 2.0, // Add to private constructor
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    // Store label positions to draw them after the line
    List<Map<String, dynamic>> labelsToDraw = [];

    for (int i = 0; i < values.length; i++) {
      final x = toX(i.toDouble());
      final y = toY(values[i]);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
        // Only store label data for the first point if it's not the default value
        if (values[i] != defaultValue) {
          labelsToDraw.add({
            'x': x,
            'y': y,
            'value': values[i],
            'changePercent': null,
            'date': candles[i].date,
          });
        }
      } else {
        // Check if value changed from previous point
        if (i > 0 && values[i] != values[i - 1]) {
          // Draw horizontal line to current X position with previous Y value
          path.lineTo(x, toY(values[i - 1]));
          // Then draw vertical line to new Y value
          path.lineTo(x, y);

          // Only store label data if the new value is not the default value
          if (values[i] != defaultValue) {
            double changePercent =
                ((values[i] - values[i - 1]) / values[i - 1]) * 100;
            labelsToDraw.add({
              'x': x,
              'y': y,
              'value': values[i],
              'changePercent': changePercent,
              'date': candles[i].date,
            });
          }
        } else {
          // Same value, just continue horizontal line
          path.lineTo(x, y);
        }
      }
    }

    // Draw the line first
    if (pathStarted) {
      canvas.drawPath(path, paint);
    }

    // Then draw all labels on top
    for (var labelData in labelsToDraw) {
      _drawValueLabel(
        canvas,
        labelData['x'],
        labelData['y'],
        labelData['value'],
        labelData['changePercent'],
        labelData['date'],
      );
    }
  }

  void _drawValueLabel(Canvas canvas, double x, double y, double value,
      double? changePercent, DateTime date) {
    // Format the month (e.g., "Jan 2025")
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    String month = '${months[date.month - 1]} ${date.year}';

    // Create the label text
    String valueText = value.toStringAsFixed(1);
    String changeText = changePercent != null
        ? '(${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%)'
        : '';

    // Text styles
    const fillTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    const strokeTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    // Calculate total label height
    double totalLabelHeight =
        changePercent != null ? 36.0 : 24.0; // 3 lines vs 2 lines

    // Determine preferred position based on value change
    bool preferAbove = changePercent != null
        ? changePercent > 0
        : false; // Going up = above, going down = below

    // Check bounds and adjust if necessary
    bool drawAbove;
    if (preferAbove) {
      // Want to draw above, but check if it goes out of bounds at top
      drawAbove = (y - totalLabelHeight - 15) >= topPos; // 15px buffer from top
    } else {
      // Want to draw below, but check if it goes out of bounds at bottom
      drawAbove =
          (y + totalLabelHeight + 15) > bottomPos; // 15px buffer from bottom
    }

    // Calculate label position
    double labelY =
        drawAbove ? y - totalLabelHeight - 16 : y + 10; // 8px offset from point

    // Helper function to draw outlined text
    void drawOutlinedText(String text, double textY) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: fillTextStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final textX = x - textPainter.width / 2;

      // Draw stroke (outline) first
      final strokePainter = TextPainter(
        text: TextSpan(
          text: text,
          style: strokeTextStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      strokePainter.paint(canvas, Offset(textX, textY));

      // Draw fill on top
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // Draw the text lines with outline
    double textY = labelY;

    // Value line
    drawOutlinedText(valueText, textY);

    // Change percentage line (if applicable)
    if (changePercent != null) {
      textY += 15;
      drawOutlinedText(changeText, textY);
    }

    // Month line
    textY += 15;
    drawOutlinedText(month, textY);

    // Draw a small dot at the actual point
    canvas.drawCircle(
      Offset(x, y),
      5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    // Update candles
    if (candles.isEmpty) {
      candles.addAll(data);
    } else {
      int existingCount = candles.length;
      if (data.length > existingCount) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    // Calculate values FIRST
    _calculateValues();

    // THEN calculate Y-range based on the actual values
    calculateYValueRange(data);

    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculateValues() {
    values.clear();
    if (candles.isEmpty) {
      return;
    }

    // If no points, use default value for all candles
    if (points.isEmpty) {
      values.addAll(List.filled(candles.length, defaultValue));
      return;
    }

    // Sort points by date
    List<EvSalesPoint> sortedPoints = List.from(points);
    sortedPoints.sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < candles.length; i++) {
      DateTime candleDate = candles[i].date;
      double value = defaultValue; // Start with default instead of 0

      // Find the appropriate value for this date (step-wise behavior)
      for (int j = 0; j < sortedPoints.length; j++) {
        if (candleDate.isAfter(sortedPoints[j].date) ||
            candleDate.isAtSameMomentAs(sortedPoints[j].date)) {
          value = sortedPoints[j].value;
        } else {
          break;
        }
      }

      values.add(value);

      // Debug first few and any changes
      if (i < 5 || (i > 0 && values[i] != values[i - 1])) {}
    }
  }

  @override
  calculateYValueRange(List<ICandle> data) {
    if (values.isEmpty) {
      yMinValue = defaultValue * 0.8;
      yMaxValue = defaultValue * 1.2;
    } else {
      // Find min and max from actual calculated values
      double minValue = values.reduce((a, b) => a < b ? a : b);
      double maxValue = values.reduce((a, b) => a > b ? a : b);

      // Add padding
      double range = maxValue - minValue;
      if (range > 0) {
        minValue -= range * 0.1;
        maxValue += range * 0.1;
      } else {
        // Handle case where all values are the same
        double padding = minValue * 0.1;
        if (padding == 0) padding = 1.0;
        minValue = (minValue - padding).clamp(0, double.infinity);
        maxValue = maxValue + padding;
      }

      yMinValue = minValue;
      yMaxValue = maxValue;
    }

    // Generate nice axis values
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
      builder: (context) => EvSalesSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['lineColor'] = colorToJson(lineColor);
    json['points'] = points.map((p) => p.toJson()).toList();
    json['defaultValue'] = defaultValue; // Add this
    return json;
  }

  factory EvSales.fromJson(Map<String, dynamic> json) {
    return EvSales._(
      id: json['id'] ?? generateV4(),
      type: IndicatorType.evSales,
      displayMode: DisplayMode.panel,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.teal,
      points: (json['points'] as List?)
              ?.map((p) => EvSalesPoint.fromJson(p))
              .toList() ??
          [],
      defaultValue: json['defaultValue']?.toDouble() ?? 2.0, // Add this
    );
  }

  @override
  void updateRegionProp({
    required double leftPos,
    required double topPos,
    required double rightPos,
    required double bottomPos,
    required double xStepWidth,
    required double xOffset,
    required double yMinValue,
    required double yMaxValue,
  }) {
    // DON'T let external calls override our Y-range
    super.updateRegionProp(
      leftPos: leftPos,
      topPos: topPos,
      rightPos: rightPos,
      bottomPos: bottomPos,
      xStepWidth: xStepWidth,
      xOffset: xOffset,
      yMinValue: this.yMinValue, // Use our own calculated range
      yMaxValue: this.yMaxValue, // Use our own calculated range
    );
  }
}
