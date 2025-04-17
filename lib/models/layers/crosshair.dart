import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/settings/x_axis_settings.dart';
import 'package:fin_chart/models/settings/y_axis_settings.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:fin_chart/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class Crosshair extends Layer {
  // Basic properties
  late Offset position;
  Color color = Colors.grey;
  double strokeWidth = 1.5;
  double dashLength = 7.0;
  double gapLength = 3.0;

  // For candle snapping
  int? snappedCandleIndex;
  List<ICandle> candles = [];

  // Drag handling
  Offset? dragStartPosition;
  Offset? initialPosition;
  double _accumulatedXDelta = 0.0;

  // Axis position properties
  YAxisPos yAxisPos = YAxisPos.right;
  XAxisPos xAxisPos = XAxisPos.bottom;

  Crosshair._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.position,
      required this.color,
      required this.strokeWidth,
      required this.dashLength,
      required this.gapLength});

  Crosshair.fromTool({required this.position})
      : super.fromTool(id: generateV4(), type: LayerType.crosshair);

  factory Crosshair.fromJson({required Map<String, dynamic> json}) {
    return Crosshair._(
        id: json['id'],
        type: (json['type'] as String).toLayerType() ?? LayerType.crosshair,
        isLocked: json['isLocked'] ?? false,
        position: offsetFromJson(json['position']),
        color: colorFromJson(json['color']),
        strokeWidth: json['strokeWidth'] ?? 1.0,
        dashLength: json['dashLength'] ?? 5.0,
        gapLength: json['gapLength'] ?? 3.0);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': colorToJson(color),
      'strokeWidth': strokeWidth,
      'dashLength': dashLength,
      'gapLength': gapLength,
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    // Get position in canvas coordinates
    final canvasPosition = toCanvas(position);

    // Draw dotted vertical line
    _drawDottedLine(
      canvas,
      Offset(canvasPosition.dx, topPos),
      Offset(canvasPosition.dx, bottomPos),
      color,
      strokeWidth,
      dashLength,
      gapLength,
    );

    // Draw dotted horizontal line
    _drawDottedLine(
      canvas,
      Offset(leftPos, canvasPosition.dy),
      Offset(rightPos, canvasPosition.dy),
      color,
      strokeWidth,
      dashLength,
      gapLength,
    );
  }

  void _drawDottedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double strokeWidth,
    double dashLength,
    double gapLength,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashGapSum = dashLength + gapLength;
    final steps = (distance / dashGapSum).floor();

    double x = start.dx;
    double y = start.dy;
    final stepX = dx == 0 ? 0 : dx / distance * dashGapSum;
    final stepY = dy == 0 ? 0 : dy / distance * dashGapSum;

    for (int i = 0; i < steps; i++) {
      final dashStartX = x;
      final dashStartY = y;

      x += stepX * dashLength / dashGapSum;
      y += stepY * dashLength / dashGapSum;

      canvas.drawLine(
        Offset(dashStartX, dashStartY),
        Offset(x, y),
        paint,
      );

      x += stepX * gapLength / dashGapSum;
      y += stepY * gapLength / dashGapSum;
    }

    // Draw remaining dash if any
    final remainingDistance = distance - steps * dashGapSum;
    if (remainingDistance > 0) {
      final dashStartX = x;
      final dashStartY = y;
      final dashEndX =
          dashStartX + dx / distance * remainingDistance.clamp(0, dashLength);
      final dashEndY =
          dashStartY + dy / distance * remainingDistance.clamp(0, dashLength);

      canvas.drawLine(
        Offset(dashStartX, dashStartY),
        Offset(dashEndX, dashEndY),
        paint,
      );
    }
  }

  // Y-axis label rendering - modeled after HorizontalLine implementation
  @override
  void drawRightAxisValues({required Canvas canvas}) {
    final yValue = toYInverse(toCanvas(position).dy);
    final yValueText = yValue.toStringAsFixed(2);

    final TextPainter text = TextPainter(
      text: TextSpan(
        text: yValueText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    canvas.drawRect(
        Rect.fromLTWH(
            rightPos,
            toY(yValue) - text.height / 2 - yLabelPadding / 2,
            text.width + 2 * xLabelPadding,
            text.height + yLabelPadding),
        Paint()..color = color);

    text.paint(canvas,
        Offset(rightPos + yLabelPadding / 2, toY(yValue) - text.height / 2));
  }

  @override
  void drawLeftAxisValues({required Canvas canvas}) {
    final yValue = toYInverse(toCanvas(position).dy);
    final yValueText = yValue.toStringAsFixed(2);

    final TextPainter text = TextPainter(
      text: TextSpan(
        text: yValueText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    canvas.drawRect(
        Rect.fromLTWH(
            leftPos - text.width - 2 * xLabelPadding,
            toY(yValue) - text.height / 2 - yLabelPadding / 2,
            text.width + 2 * xLabelPadding,
            text.height + yLabelPadding),
        Paint()..color = color);

    text.paint(
        canvas,
        Offset(leftPos - text.width - xLabelPadding,
            toY(yValue) - text.height / 2));
  }

  @override
  void drawBottomAxisValues({required Canvas canvas}) {
    if (candles.isEmpty) return;

    String xValueText = "";

    // Get date from candle if snapped
    if (snappedCandleIndex != null && snappedCandleIndex! < candles.length) {
      final candle = candles[snappedCandleIndex!];
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      xValueText = dateFormat.format(candle.date);
    } else {
      // If not snapped, show date closest to current position
      double xPos = position.dx;
      int index = xPos.round();
      if (index >= 0 && index < candles.length) {
        final candle = candles[index];
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
        xValueText = dateFormat.format(candle.date);
      } else {
        xValueText = 'N/A';
      }
    }

    final TextPainter text = TextPainter(
      text: TextSpan(
        text: xValueText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final canvasPosition = toCanvas(position);

    canvas.drawRect(
      Rect.fromLTWH(canvasPosition.dx - text.width / 2 - xLabelPadding / 2,
          bottomPos, text.width + xLabelPadding, text.height + yLabelPadding),
      Paint()..color = color,
    );

    text.paint(
      canvas,
      Offset(canvasPosition.dx - text.width / 2, bottomPos + yLabelPadding / 2),
    );
  }

  @override
  void drawTopAxisValues({required Canvas canvas}) {
    if (candles.isEmpty) return;

    String xValueText = "";

    // Get date from candle if snapped
    if (snappedCandleIndex != null && snappedCandleIndex! < candles.length) {
      final candle = candles[snappedCandleIndex!];
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      xValueText = dateFormat.format(candle.date);
    } else {
      // If not snapped, show date closest to current position
      double xPos = position.dx;
      int index = xPos.round();
      if (index >= 0 && index < candles.length) {
        final candle = candles[index];
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
        xValueText = dateFormat.format(candle.date);
      } else {
        xValueText = 'N/A';
      }
    }

    final TextPainter text = TextPainter(
      text: TextSpan(
        text: xValueText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final canvasPosition = toCanvas(position);

    canvas.drawRect(
      Rect.fromLTWH(
          canvasPosition.dx - text.width / 2 - xLabelPadding / 2,
          topPos - text.height - yLabelPadding,
          text.width + xLabelPadding,
          text.height + yLabelPadding),
      Paint()..color = color,
    );

    text.paint(
      canvas,
      Offset(canvasPosition.dx - text.width / 2,
          topPos - text.height - yLabelPadding / 2),
    );
  }

  void updateData(List<ICandle> data) {
    candles = data;
    _updateSnappedCandle();
  }

  void _updateSnappedCandle() {
    if (candles.isEmpty) return;

    // Calculate the actual x position in chart space
    double xPos = toX(position.dx);

    // Find the closest candle index
    int closestIndex = -1;
    double minDistance = double.infinity;

    for (int i = 0; i < candles.length; i++) {
      double candleX = leftPos + xOffset + xStepWidth / 2 + i * xStepWidth;
      double distance = (candleX - xPos).abs();

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex >= 0 && closestIndex < candles.length) {
      snappedCandleIndex = closestIndex;
    } else {
      snappedCandleIndex = null;
    }
  }

  // @override
  // Layer? onTapDown({required TapDownDetails details}) {
  //   // Check if tapping near the crosshair
  //   final tapPoint = details.localPosition;
  //   final crosshairPoint = toCanvas(position);

  //   // Define a hit area around the crosshair intersection
  //   if ((tapPoint.dx - crosshairPoint.dx).abs() < 20 &&
  //       (tapPoint.dy - crosshairPoint.dy).abs() < 20) {
  //     dragStartPosition = tapPoint;
  //     initialPosition = position;
  //     return this;
  //   }

  //   return null;
  // }

  void dragFromAnywhere(Offset dragDelta) {
    _accumulatedXDelta += dragDelta.dx / xStepWidth;
    double xChange = 0.0;
    {
      xChange = _accumulatedXDelta.sign * _accumulatedXDelta.abs().floor();
      _accumulatedXDelta -= xChange;
    }

    // Apply the changes to position
    double newX = position.dx + xChange;
    double newY =
        position.dy + (toYInverse(topPos + dragDelta.dy) - toYInverse(topPos));

    // Clamp values to chart ranges
    newX = newX.clamp(0.0, candles.length - 1.0);
    newY = newY.clamp(yMinValue, yMaxValue);

    // Update position
    position = Offset(newX, newY);

    // Update snapped candle for label display
    _updateSnappedCandle();
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;

    if (dragStartPosition != null && initialPosition != null) {
      // Calculate the delta from drag start
      final deltaX = details.localFocalPoint.dx - dragStartPosition!.dx;
      final deltaY = details.localFocalPoint.dy - dragStartPosition!.dy;

      // Convert screen deltas to chart space
      double newX = toXInverse(toX(initialPosition!.dx) + deltaX);
      double newY = toYInverse(toY(initialPosition!.dy) + deltaY);

      // Clamp Y value to chart range
      newY = newY.clamp(yMinValue, yMaxValue);

      // Update position without forcing snap to a specific candle
      position = Offset(newX, newY);

      // Update snapped candle for label display
      _updateSnappedCandle();
    }
  }

  @override
  void onScaleStart({required ScaleStartDetails details}) {
    dragStartPosition = details.localFocalPoint;
    initialPosition = position;
  }
}
