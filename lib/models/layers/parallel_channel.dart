import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/parallel_channel_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class ParallelChannel extends Layer {
  late Offset topLeft;
  late Offset topRight;
  late Offset bottomLeft;
  late Offset bottomRight;

  Color color = Colors.blue;
  double strokeWidth = 2;
  int channelAlpha = 51;
  double endPointRadius = 5;

  Offset? dragStartPos;
  DragHandleType? selectedHandle;

  ParallelChannel.fromTool({
    required this.topLeft,
    required this.bottomRight,
    required Offset dragPoint,
  }) : super.fromTool(id: generateV4(), type: LayerType.parallelChannel) {
    double width = bottomRight.dx - topLeft.dx;
    double height = bottomRight.dy - topLeft.dy;

    topRight = Offset(topLeft.dx + width, topLeft.dy);
    bottomLeft = Offset(topLeft.dx, topLeft.dy + height);

    dragStartPos = dragPoint;
    selectedHandle = DragHandleType.bottomRight;

    isSelected = true;
  }

  ParallelChannel._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.topLeft,
      required this.topRight,
      required this.bottomLeft,
      required this.bottomRight,
      required this.color,
      required this.strokeWidth,
      required this.channelAlpha,
      required this.endPointRadius});

  factory ParallelChannel.fromJson({required Map<String, dynamic> json}) {
    return ParallelChannel._(
        id: json['id'],
        type:
            (json['type'] as String).toLayerType() ?? LayerType.parallelChannel,
        topLeft: offsetFromJson(json['topLeft']),
        topRight: offsetFromJson(json['topRight']),
        bottomLeft: offsetFromJson(json['bottomLeft']),
        bottomRight: offsetFromJson(json['bottomRight']),
        color: colorFromJson(json['color']),
        strokeWidth: json['strokeWidth'].toDouble() ?? 2.0,
        channelAlpha: json['channelAlpha'] ?? 51,
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
      'strokeWidth': strokeWidth,
      'channelAlpha': channelAlpha,
      'endPointRadius': endPointRadius,
      'color': colorToJson(color)
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    final path = Path();
    path.moveTo(toX(topLeft.dx), toY(topLeft.dy));
    path.lineTo(toX(topRight.dx), toY(topRight.dy));
    path.lineTo(toX(bottomRight.dx), toY(bottomRight.dy));
    path.lineTo(toX(bottomLeft.dx), toY(bottomLeft.dy));
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..color = color.withAlpha(channelAlpha)
          ..style = PaintingStyle.fill);

    Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(toCanvas(topLeft), toCanvas(topRight), linePaint);
    canvas.drawLine(toCanvas(bottomRight), toCanvas(bottomLeft), linePaint);

    Offset leftMidPoint = Offset(
        (topLeft.dx + bottomLeft.dx) / 2, (topLeft.dy + bottomLeft.dy) / 2);
    Offset rightMidPoint = Offset(
        (topRight.dx + bottomRight.dx) / 2, (topRight.dy + bottomRight.dy) / 2);

    Paint dottedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double distance =
        (toCanvas(rightMidPoint) - toCanvas(leftMidPoint)).distance;
    double startX = toX(leftMidPoint.dx);
    double startY = toY(leftMidPoint.dy);
    double endX = toX(rightMidPoint.dx);
    double endY = toY(rightMidPoint.dy);

    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      double x1 = startX + (i / distance) * (endX - startX);
      double y1 = startY + (i / distance) * (endY - startY);
      double x2 = startX + ((i + dashWidth) / distance) * (endX - startX);
      double y2 = startY + ((i + dashWidth) / distance) * (endY - startY);

      if (i + dashWidth < distance) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dottedPaint);
      }
    }

    Offset topMiddle =
        Offset((topLeft.dx + topRight.dx) / 2, (topLeft.dy + topRight.dy) / 2);
    Offset bottomMiddle = Offset((bottomLeft.dx + bottomRight.dx) / 2,
        (bottomLeft.dy + bottomRight.dy) / 2);

    if (isSelected) {
      // Corner handles
      _drawHandle(canvas, topLeft);
      _drawHandle(canvas, topRight);
      _drawHandle(canvas, bottomLeft);
      _drawHandle(canvas, bottomRight);

      // Mid-side handles
      _drawMidHandle(canvas, topMiddle);
      _drawMidHandle(canvas, bottomMiddle);
    }
  }

  void _drawHandle(Canvas canvas, Offset point) {
    canvas.drawCircle(
        toCanvas(point), endPointRadius, Paint()..color = Colors.white);

    canvas.drawCircle(
        toCanvas(point),
        endPointRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _drawMidHandle(Canvas canvas, Offset point) {
    final rect = Rect.fromCenter(
        center: toCanvas(point),
        width: endPointRadius * 1.8,
        height: endPointRadius * 1.8);

    canvas.drawRect(rect, Paint()..color = Colors.white);

    canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    final hitTestRadius = endPointRadius * 2;

    // Calculate middle points
    Offset topMiddle =
        Offset((topLeft.dx + topRight.dx) / 2, (topLeft.dy + topRight.dy) / 2);
    Offset bottomMiddle = Offset((bottomLeft.dx + bottomRight.dx) / 2,
        (bottomLeft.dy + bottomRight.dy) / 2);

    // Check corner handles
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

    // Check mid-side handles
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(topMiddle), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.topMiddle;
      return this;
    }
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(bottomMiddle), hitTestRadius)) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.bottomMiddle;
      return this;
    }

    if ((isPointInsideArea(
        topLeft, topRight, bottomRight, bottomLeft, details.localPosition))) {
      isSelected = true;
      dragStartPos = details.localPosition;
      selectedHandle = DragHandleType.move;
      return this;
    }

    isSelected = false;
    return null;
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;
    if (selectedHandle == null || dragStartPos == null) return;

    final dx = details.localFocalPoint.dx - dragStartPos!.dx;
    final dy = details.localFocalPoint.dy - dragStartPos!.dy;

    dragStartPos = details.localFocalPoint;

    // Convert chart scale movements
    double dxReal = dx / xStepWidth;
    double dyReal = toYInverse(toY(0) + dy) - toYInverse(toY(0));

    switch (selectedHandle) {
      case DragHandleType.topLeft:
        // Move top-left corner
        topLeft = Offset(topLeft.dx + dxReal, topLeft.dy + dyReal);

        // Calculate the vector from top-right to top-left
        double vecX = topLeft.dx - topRight.dx;
        double vecY = topLeft.dy - topRight.dy;

        // Calculate the vector from bottom-right to bottom-left
        // and maintain the same vector for parallelism
        bottomLeft = Offset(bottomRight.dx + vecX, bottomRight.dy + vecY);
        break;

      case DragHandleType.topRight:
        // Move top-right corner
        topRight = Offset(topRight.dx + dxReal, topRight.dy + dyReal);

        // Calculate the vector from top-left to top-right
        double vecX = topRight.dx - topLeft.dx;
        double vecY = topRight.dy - topLeft.dy;

        // Calculate the vector from bottom-left to bottom-right
        // and maintain the same vector for parallelism
        bottomRight = Offset(bottomLeft.dx + vecX, bottomLeft.dy + vecY);
        break;

      case DragHandleType.bottomLeft:
        // Move bottom-left corner while keeping parallelism
        Offset oldBottomLeft = bottomLeft;
        bottomLeft = Offset(bottomLeft.dx + dxReal, bottomLeft.dy + dyReal);

        // Calculate displacement vector
        double displaceX = bottomLeft.dx - oldBottomLeft.dx;
        double displaceY = bottomLeft.dy - oldBottomLeft.dy;

        // Move top-left to maintain left edge parallelism
        topLeft = Offset(topLeft.dx + displaceX, topLeft.dy);

        // Move bottom-right to maintain bottom edge parallelism
        bottomRight = Offset(bottomRight.dx, bottomRight.dy + displaceY);
        break;

      case DragHandleType.bottomRight:
        // Move bottom-right corner
        bottomRight = Offset(bottomRight.dx + dxReal, bottomRight.dy + dyReal);

        // Calculate the vector from bottom-left to bottom-right
        double vecX = bottomRight.dx - bottomLeft.dx;
        double vecY = bottomRight.dy - bottomLeft.dy;

        // Calculate the vector from top-left to top-right
        // and maintain the same vector for parallelism
        topRight = Offset(topLeft.dx + vecX, topLeft.dy + vecY);
        break;

      case DragHandleType.topMiddle:
        // Move top edge while keeping sides parallel
        topLeft = Offset(topLeft.dx, topLeft.dy + dyReal);
        topRight = Offset(topRight.dx, topRight.dy + dyReal);
        break;

      case DragHandleType.bottomMiddle:
        // Move bottom edge while keeping sides parallel
        bottomLeft = Offset(bottomLeft.dx, bottomLeft.dy + dyReal);
        bottomRight = Offset(bottomRight.dx, bottomRight.dy + dyReal);
        break;

      case DragHandleType.move:
        // Move the entire channel
        topLeft = Offset(topLeft.dx + dxReal, topLeft.dy + dyReal);
        topRight = Offset(topRight.dx + dxReal, topRight.dy + dyReal);
        bottomLeft = Offset(bottomLeft.dx + dxReal, bottomLeft.dy + dyReal);
        bottomRight = Offset(bottomRight.dx + dxReal, bottomRight.dy + dyReal);
        break;
      case null:
        break;
    }
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => ParallelChannelSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}

enum DragHandleType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topMiddle,
  bottomMiddle,
  move
}
