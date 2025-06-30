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
  double defaultValue = 2.0; // Typical EV/Sales ratio

  final List<double> values = [];
  final List<ICandle> candles = [];

  EvSales({
    this.lineColor = Colors.teal,
    this.points = const [],
    this.defaultValue = 2.0,
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
    this.defaultValue = 2.0,
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
        path.lineTo(x, y);

        // Check if this is a new point (value changed from previous)
        if (i > 0 && values[i] != values[i - 1] && values[i] != defaultValue) {
          double previousValue = values[i - 1];
          double changePercent =
              ((values[i] - previousValue) / previousValue) * 100;

          labelsToDraw.add({
            'x': x,
            'y': y,
            'value': values[i],
            'changePercent': changePercent,
            'date': candles[i].date,
          });
        }
      }
    }

    // Draw the main line
    canvas.drawPath(path, paint);

    // Draw labels
    for (var labelData in labelsToDraw) {
      _drawValueLabel(canvas, labelData);
    }
  }

  void _drawValueLabel(Canvas canvas, Map<String, dynamic> data) {
    final double x = data['x'];
    final double y = data['y'];
    final double value = data['value'];
    final double? changePercent = data['changePercent'];

    String mainText = value.toStringAsFixed(1);
    String? changeText = changePercent != null
        ? '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%'
        : null;

    final textStyle = TextStyle(
      color: lineColor,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    final changeTextStyle = TextStyle(
      color: changePercent != null
          ? (changePercent >= 0 ? Colors.green : Colors.red)
          : lineColor,
      fontSize: 10,
    );

    final mainTextPainter = TextPainter(
      text: TextSpan(text: mainText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    mainTextPainter.layout();

    TextPainter? changeTextPainter;
    if (changeText != null) {
      changeTextPainter = TextPainter(
        text: TextSpan(text: changeText, style: changeTextStyle),
        textDirection: TextDirection.ltr,
      );
      changeTextPainter.layout();
    }

    // Calculate total height needed
    double totalHeight = mainTextPainter.height;
    if (changeTextPainter != null) {
      totalHeight += changeTextPainter.height + 2;
    }

    // Position above the point
    double labelY = y - totalHeight - 10;
    double labelX = x - mainTextPainter.width / 2;

    // Keep within bounds
    labelX = labelX.clamp(0, rightPos - mainTextPainter.width);
    labelY = labelY.clamp(topPos, bottomPos - totalHeight);

    // Draw background
    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(int.parse((0.8 * 255).toString()))
      ..style = PaintingStyle.fill;

    double maxWidth = mainTextPainter.width;
    if (changeTextPainter != null && changeTextPainter.width > maxWidth) {
      maxWidth = changeTextPainter.width;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(labelX - 4, labelY - 2, maxWidth + 8, totalHeight + 4),
        const Radius.circular(4),
      ),
      bgPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(labelX - 4, labelY - 2, maxWidth + 8, totalHeight + 4),
        const Radius.circular(4),
      ),
      borderPaint,
    );

    // Draw main text
    mainTextPainter.paint(canvas, Offset(labelX, labelY));

    // Draw change text if present
    if (changeTextPainter != null) {
      double changeX = labelX + (maxWidth - changeTextPainter.width) / 2;
      changeTextPainter.paint(
          canvas, Offset(changeX, labelY + mainTextPainter.height + 2));
    }

    // Draw small circle at the data point
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 3, pointPaint);

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(x, y), 3, pointBorderPaint);
  }

  @override
  updateData(List<ICandle> data) {
    candles.clear();
    candles.addAll(data);
    values.clear();

    if (data.isEmpty) {
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
    json['defaultValue'] = defaultValue;
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
      defaultValue: json['defaultValue']?.toDouble() ?? 2.0,
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
