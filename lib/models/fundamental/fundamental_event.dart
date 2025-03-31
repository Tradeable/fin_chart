import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/dividend_event.dart';
import 'package:fin_chart/models/fundamental/stock_split_event.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/fundamental/earnings_event.dart';

abstract class FundamentalEvent {
  final String id;
  final EventType type;
  final DateTime date;
  final String title;
  final String description;
  Offset? position;
  bool isSelected = false;
  double topPos = 0;
  double bottomPos = 0; 

  FundamentalEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    this.description = '',
  });

  Color get color;
  String get iconText;

  void drawTooltip(Canvas canvas);

  Map<String, dynamic> toJson();

  factory FundamentalEvent.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String).toEventType();

    switch (type) {
      case EventType.earnings:
        return EarningsEvent.fromJson(json);
      case EventType.dividend:
        return DividendEvent.fromJson(json);
      case EventType.stockSplit:
        return StockSplitEvent.fromJson(json);
    }
  }

  void drawSelectionLine(Canvas canvas, double topPos, double bottomPos) {
    if (isSelected && position != null) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Starting position is at the event icon's y position
      final startY = position!.dy - 12;
      // Target position is the top of the chart
      final endY = topPos;

      // Create a path with dashes
      final Path path = Path();
      path.moveTo(position!.dx, startY);

      const dashWidth = 5.0;
      const dashSpace = 5.0;
      double distance = startY - endY; // Going upward, so startY - endY
      double drawn = 0;

      while (drawn < distance) {
        double toDraw = dashWidth;
        if (drawn + toDraw > distance) {
          toDraw = distance - drawn;
        }
        path.relativeLineTo(0, -toDraw); // Negative to move upward
        drawn += toDraw;

        if (drawn >= distance) break;

        path.moveTo(position!.dx, startY - drawn - dashSpace);
        drawn += dashSpace;
      }

      canvas.drawPath(path, paint);
    }
  }
}
