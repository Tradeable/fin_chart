import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/rect_area_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/utils/calculations.dart';

enum DragHandleType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  top,
  right,
  bottom,
  move
}

class RectArea extends Layer {
  late Offset topLeft;
  late Offset bottomRight;
  Color color = Colors.amber;

  late Offset topRight;
  late Offset bottomLeft;

  double strokeWidth = 2;
  int alpha = 51;
  double endPointRadius = 5;

  Offset? dragStartPos;
  DragHandleType? selectedHandle;

  RectArea._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.topLeft,
      required this.topRight,
      required this.bottomLeft,
      required this.bottomRight,
      required this.strokeWidth,
      required this.alpha,
      required this.endPointRadius,
      required this.color});

  RectArea.fromTool(
      {required this.topLeft,
      required this.bottomRight,
      required this.dragStartPos})
      : super.fromTool(id: generateV4(), type: LayerType.rectArea) {
    isSelected = true;
    topRight = Offset(bottomRight.dx, topLeft.dy);
    bottomLeft = Offset(topLeft.dx, bottomRight.dy);
    selectedHandle = DragHandleType.bottomRight;
  }

  factory RectArea.fromJson({required Map<String, dynamic> json}) {
    return RectArea._(
        id: json['id'],
        type: (json['type'] as String).toLayerType() ?? LayerType.rectArea,
        topLeft: offsetFromJson(json['topLeft']),
        topRight: offsetFromJson(json['topRight']),
        bottomLeft: offsetFromJson(json['bottomLeft']),
        bottomRight: offsetFromJson(json['bottomRight']),
        color: colorFromJson(json['color']),
        strokeWidth: json['strokeWidth'].toDouble() ?? 2.0,
        alpha: json['alpha'] ?? 51,
        endPointRadius: json['endPointRadius'].toDouble() ?? 5.0,
        isLocked: json['isLocked'] ?? false);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'topLeft': {'dx': topLeft.dx, 'dy': topLeft.dy},
      'topRight': {'dx': topRight.dx, 'dy': topRight.dy},
      'bottomLeft': {'dx': bottomLeft.dx, 'dy': bottomLeft.dy},
      'bottomRight': {'dx': bottomRight.dx, 'dy': bottomRight.dy},
      'color': colorToJson(color),
      'strokeWidth': strokeWidth,
      'alpha': alpha,
      'endPointRadius': endPointRadius,
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    canvas.drawRect(
        Rect.fromPoints(toCanvas(topLeft), toCanvas(bottomRight)),
        Paint()
          ..color = color.withAlpha(alpha)
          ..style = PaintingStyle.fill);

    if (isSelected) {
      canvas.drawRect(
          Rect.fromLTRB(toX(topLeft.dx), toY(topLeft.dy), toX(bottomRight.dx),
              toY(bottomRight.dy)),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth);

      canvas.drawCircle(
          toCanvas(topLeft),
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..strokeWidth = 5);

      _drawHandle(canvas, topLeft);
      _drawHandle(canvas, topRight);
      _drawHandle(canvas, bottomRight);
      _drawHandle(canvas, bottomLeft);
    }
  }

  _drawHandle(Canvas canvas, Offset point) {
    canvas.drawCircle(
        toCanvas(point),
        endPointRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = endPointRadius);

    canvas.drawCircle(
        toCanvas(point),
        endPointRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    final hitTestRadius = endPointRadius * 2;

    if (isPointInCircularRegion(
        details.localPosition, toCanvas(topLeft), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.topLeft;
      return this;
    }
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(topRight), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.topRight;
      return this;
    }
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(bottomLeft), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.bottomLeft;
      return this;
    }
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(bottomRight), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.bottomRight;
      return this;
    }

    if (isPointOnLine(
        details.localPosition, toCanvas(topLeft), toCanvas(topRight))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.top;
      return this;
    }

    if (isPointOnLine(
        details.localPosition, toCanvas(topRight), toCanvas(bottomRight))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.right;
      return this;
    }

    if (isPointOnLine(
        details.localPosition, toCanvas(bottomRight), toCanvas(bottomLeft))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.bottom;
      return this;
    }

    if (isPointOnLine(
        details.localPosition, toCanvas(bottomLeft), toCanvas(topLeft))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.left;
      return this;
    }

    if (isPointNearRectFromDiagonalVertices(
        details.localPosition, toCanvas(topLeft), toCanvas(bottomRight))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.move;
      return this;
    }

    isSelected = false;
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;
    if (selectedHandle == null || dragStartPos == null) return;
    double xDeltaReal =
        toReal(details.localFocalPoint).dx - toReal(dragStartPos!).dx;

    dragStartPos = details.localFocalPoint;

    switch (selectedHandle) {
      case null:
        break;
      case DragHandleType.topLeft:
        topLeft = Offset(topLeft.dx + xDeltaReal,
            toYInverse(toY(topLeft.dy) + details.focalPointDelta.dy));
        bottomLeft = Offset(bottomLeft.dx + xDeltaReal, bottomLeft.dy);
        topRight = Offset(topRight.dx,
            toYInverse(toY(topRight.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.topRight:
        topRight = Offset(topRight.dx + xDeltaReal,
            toYInverse(toY(topRight.dy) + details.focalPointDelta.dy));
        bottomRight = Offset(bottomRight.dx + xDeltaReal, bottomRight.dy);
        topLeft = Offset(topLeft.dx,
            toYInverse(toY(topLeft.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.bottomLeft:
        bottomLeft = Offset(bottomLeft.dx + xDeltaReal,
            toYInverse(toY(bottomLeft.dy) + details.focalPointDelta.dy));
        topLeft = Offset(topLeft.dx + xDeltaReal, topLeft.dy);
        bottomRight = Offset(bottomRight.dx,
            toYInverse(toY(bottomRight.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.bottomRight:
        bottomRight = Offset(bottomRight.dx + xDeltaReal,
            toYInverse(toY(bottomRight.dy) + details.focalPointDelta.dy));
        topRight = Offset(topRight.dx + xDeltaReal, topRight.dy);
        bottomLeft = Offset(bottomLeft.dx,
            toYInverse(toY(bottomLeft.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.left:
        topLeft = Offset(topLeft.dx + xDeltaReal, topLeft.dy);
        bottomLeft = Offset(bottomLeft.dx + xDeltaReal, bottomLeft.dy);
        break;
      case DragHandleType.top:
        topLeft = Offset(topLeft.dx,
            toYInverse(toY(topLeft.dy) + details.focalPointDelta.dy));
        topRight = Offset(topRight.dx,
            toYInverse(toY(topRight.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.right:
        topRight = Offset(topRight.dx + xDeltaReal, topRight.dy);
        bottomRight = Offset(bottomRight.dx + xDeltaReal, bottomRight.dy);
        break;
      case DragHandleType.bottom:
        bottomLeft = Offset(bottomLeft.dx,
            toYInverse(toY(bottomLeft.dy) + details.focalPointDelta.dy));
        bottomRight = Offset(bottomRight.dx,
            toYInverse(toY(bottomRight.dy) + details.focalPointDelta.dy));
        break;
      case DragHandleType.move:
        // Move the entire rectangle
        topLeft = Offset(topLeft.dx + xDeltaReal,
            toYInverse(toY(topLeft.dy) + details.focalPointDelta.dy));
        topRight = Offset(topRight.dx + xDeltaReal,
            toYInverse(toY(topRight.dy) + details.focalPointDelta.dy));
        bottomLeft = Offset(bottomLeft.dx + xDeltaReal,
            toYInverse(toY(bottomLeft.dy) + details.focalPointDelta.dy));
        bottomRight = Offset(bottomRight.dx + xDeltaReal,
            toYInverse(toY(bottomRight.dy) + details.focalPointDelta.dy));
        break;
    }

    super.onScaleUpdate(details: details);
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => RectAreaSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}
