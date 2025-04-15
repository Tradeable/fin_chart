import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/ui/layer_settings/arrow_settings_dialog.dart';
import 'dart:math' as math;

class Arrow extends Layer {
  late Offset from;
  late Offset to;
  Color color = Colors.black;
  double strokeWidth = 2;
  double endPointRadius = 5;
  double arrowheadSize = 15;
  bool isArrowheadAtTo = true;

  late Offset startPoint;
  Offset? tempFrom;
  Offset? tempTo;

  Arrow._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.from,
      required this.to,
      required this.color,
      required this.strokeWidth,
      required this.endPointRadius,
      required this.arrowheadSize,
      required this.isArrowheadAtTo});

  Arrow.fromTool(
      {required this.from, required this.to, required this.startPoint})
      : super.fromTool(id: generateV4(), type: LayerType.arrow) {
    isSelected = true;
    tempTo = to;
  }

  factory Arrow.fromJson({required Map<String, dynamic> json}) {
    return Arrow._(
        id: json['id'],
        type: (json['type'] as String).toLayerType() ?? LayerType.arrow,
        isLocked: json['isLocked'] ?? false,
        from: offsetFromJson(json['from']),
        to: offsetFromJson(json['to']),
        color: colorFromJson(json['color']),
        strokeWidth: json['strokeWidth'].toDouble() ?? 2,
        endPointRadius: json['endPointRadius'].toDouble() ?? 5,
        arrowheadSize: json['arrowheadSize'].toDouble() ?? 15,
        isArrowheadAtTo: json['isArrowheadAtTo'] ?? true);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'from': {'dx': from.dx, 'dy': from.dy},
      'to': {'dx': to.dx, 'dy': to.dy},
      'strokeWidth': strokeWidth,
      'arrowheadSize': arrowheadSize,
      'endPointRadius': endPointRadius,
      'color': colorToJson(color),
      'isArrowheadAtTo': isArrowheadAtTo
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = color;

    // Determine which points to use based on direction
    Offset startPoint = isArrowheadAtTo ? toCanvas(from) : toCanvas(to);
    Offset endPoint = isArrowheadAtTo ? toCanvas(to) : toCanvas(from);

    // Calculate angle of the line
    double angle = math.atan2(
      endPoint.dy - startPoint.dy,
      endPoint.dx - startPoint.dx,
    );

    // Calculate base of arrowhead (where the line should end)
    Offset arrowBase;
    if (isArrowheadAtTo) {
      // The base of the arrowhead is at a distance of arrowheadSize from the tip
      arrowBase = Offset(
        endPoint.dx - (arrowheadSize * 0.75) * math.cos(angle),
        endPoint.dy - (arrowheadSize * 0.75) * math.sin(angle),
      );
      // Draw line from start to arrowhead base
      canvas.drawLine(startPoint, arrowBase, paint);
    } else {
      // If arrow is at 'from' end, draw complete line and let arrowhead overlay it
      canvas.drawLine(startPoint, endPoint, paint);
    }

    // Draw arrowhead
    _drawArrowhead(canvas, paint, angle);

    if (isSelected) {
      // Draw circles at endpoints
      canvas.drawCircle(
          toCanvas(from),
          endPointRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          toCanvas(from),
          endPointRadius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);

      canvas.drawCircle(
          toCanvas(to),
          endPointRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          toCanvas(to),
          endPointRadius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);
    }
  }

  void _drawArrowhead(Canvas canvas, Paint linePaint, double angle) {
    // Determine which points to use based on direction
    Offset end = isArrowheadAtTo ? toCanvas(to) : toCanvas(from);

    // Create arrowhead path
    Path arrowPath = Path();

    // Move to tip of arrow
    arrowPath.moveTo(end.dx, end.dy);

    // Draw one side of arrowhead
    arrowPath.lineTo(
      end.dx - arrowheadSize * math.cos(angle - math.pi / 6),
      end.dy - arrowheadSize * math.sin(angle - math.pi / 6),
    );

    // Draw the other side of arrowhead
    arrowPath.lineTo(
      end.dx - arrowheadSize * math.cos(angle + math.pi / 6),
      end.dy - arrowheadSize * math.sin(angle + math.pi / 6),
    );

    // Close the path to create the filled triangle
    arrowPath.close();

    // Draw the arrowhead
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(from), arrowheadSize * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempFrom = from;
      tempTo = null;
      return this;
    } else if (isPointInCircularRegion(
        details.localPosition, toCanvas(to), arrowheadSize * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempTo = to;
      tempFrom = null;
      return this;
    } else if (isPointOnLine(details.localPosition,
        Offset(toX(from.dx), toY(from.dy)), Offset(toX(to.dx), toY(to.dy)),
        tolerance: arrowheadSize * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempFrom = from;
      tempTo = to;
      return this;
    }
    isSelected = false;
    tempFrom = null;
    tempTo = null;
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;
    Offset displacement =
        displacementOffset(startPoint, details.localFocalPoint);

    if (tempFrom != null) {
      from = Offset(
          tempFrom!.dx + displacement.dx, tempFrom!.dy + displacement.dy);
    }

    if (tempTo != null) {
      to = Offset(tempTo!.dx + displacement.dx, tempTo!.dy + displacement.dy);
    }
  }

  // Method to toggle the arrow direction
  void toggleDirection() {
    isArrowheadAtTo = !isArrowheadAtTo;
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => ArrowSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}
