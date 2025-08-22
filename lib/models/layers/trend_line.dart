import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/trend_line_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class TrendLine extends Layer {
  late Offset from;
  late Offset to;
  Color color = Colors.black;
  double strokeWidth = 2;
  double endPointRadius = 5;

  late Offset startPoint;
  Offset? tempFrom;
  Offset? tempTo;

  TrendLine._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.from,
      required this.to,
      required this.color,
      required this.strokeWidth,
      required this.endPointRadius});

  TrendLine.fromTool(
      {required this.from, required this.to, required this.startPoint})
      : super.fromTool(id: generateV4(), type: LayerType.trendLine) {
    isSelected = true;
    tempTo = to;
  }

  factory TrendLine.fromJson({required Map<String, dynamic> json}) {
    return TrendLine._(
        id: json['id'],
        type: (json['type'] as String).toLayerType() ?? LayerType.trendLine,
        from: offsetFromJson(json['from']),
        to: offsetFromJson(json['to']),
        color: colorFromJson(json['color']),
        strokeWidth: json['strokeWidth'].toDouble() ?? 2.0,
        endPointRadius: json['endPointRadius'].toDouble() ?? 5.0,
        isLocked: json['isLocked'] ?? false);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'from': {'dx': from.dx, 'dy': from.dy},
      'to': {'dx': to.dx, 'dy': to.dy},
      'strokeWidth': strokeWidth,
      'endPointRadius': endPointRadius,
      'color': colorToJson(color)
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.drawLine(Offset(toX(from.dx), toY(from.dy)),
        Offset(toX(to.dx), toY(to.dy)), paint);

    if (isSelected) {
      canvas.drawCircle(
          toCanvas(from),
          endPointRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..strokeWidth = endPointRadius);
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
            ..style = PaintingStyle.fill
            ..strokeWidth = endPointRadius);
      canvas.drawCircle(
          toCanvas(to),
          endPointRadius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);
    }
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(from), endPointRadius * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempFrom = from;
      tempTo = null;
      return this;
    } else if (isPointInCircularRegion(
        details.localPosition, toCanvas(to), endPointRadius * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempTo = to;
      tempFrom = null;
      return this;
    } else if (isPointOnLine(details.localPosition,
        Offset(toX(from.dx), toY(from.dy)), Offset(toX(to.dx), toY(to.dy)),
        tolerance: endPointRadius * 2)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempFrom = from;
      tempTo = to;
      return this;
    }
    isSelected = false;
    tempFrom = null;
    tempFrom = null;
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

  @override
  void showSettingsDialog(BuildContext context, Function(Layer p1) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => TrendLineSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}
