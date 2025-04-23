import 'dart:math';

import 'package:flutter/material.dart';

mixin RegionProp {
  late double leftPos;
  late double topPos;
  late double rightPos;
  late double bottomPos;
  late double xStepWidth;
  late double xOffset;
  late double yMinValue;
  late double yMaxValue;

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
    this.leftPos = leftPos;
    this.topPos = topPos;
    this.rightPos = rightPos;
    this.bottomPos = bottomPos;
    this.xStepWidth = xStepWidth;
    this.xOffset = xOffset;
    this.yMinValue = yMinValue;
    this.yMaxValue = yMaxValue;
  }

  Offset toCanvas(Offset offset) {
    return Offset(toX(offset.dx), toY(offset.dy));
  }

  Offset toReal(Offset offset) {
    return Offset(toXInverse(offset.dx), toYInverse(offset.dy));
  }

  Offset displacementOffset(Offset startPoint, Offset currentPoint) {
    return Offset(toReal(currentPoint).dx - toReal(startPoint).dx,
        toReal(currentPoint).dy - toReal(startPoint).dy);
  }

  double toY(double value) {
    return bottomPos -
        (value - yMinValue) * (bottomPos - topPos) / (yMaxValue - yMinValue);
  }

  double toYInverse(double value) {
    return (bottomPos - value) *
            (yMaxValue - yMinValue) /
            (bottomPos - topPos) +
        yMinValue;
  }

  double toX(double value) {
    return leftPos + xOffset + xStepWidth / 2 + value * xStepWidth;
  }

  double toXInverse(double value) {
    return ((value - leftPos - xOffset - xStepWidth / 2) / xStepWidth)
        .round()
        .toDouble();
  }

  bool isPointInCircularRegion(
      Offset point, Offset circleCenter, double radius) {
    final dx = point.dx - circleCenter.dx;
    final dy = point.dy - circleCenter.dy;
    final distance = sqrt(dx * dx + dy * dy);

    return distance <= radius;
  }

  bool isPointOnLine(Offset point, Offset lineStart, Offset lineEnd,
      {double tolerance = 20.0}) {
    // Step 1: Check if the point is within the bounding box of the line (extended by tolerance)
    // This is an optimization to quickly reject points far from the line segment
    final minX = min(lineStart.dx, lineEnd.dx) - tolerance;
    final maxX = max(lineStart.dx, lineEnd.dx) + tolerance;
    final minY = min(lineStart.dy, lineEnd.dy) - tolerance;
    final maxY = max(lineStart.dy, lineEnd.dy) + tolerance;

    if (point.dx < minX ||
        point.dx > maxX ||
        point.dy < minY ||
        point.dy > maxY) {
      return false;
    }

    // Step 2: Calculate the distance from point to the line
    // Formula: distance = |cross product| / |line vector length|
    final lineVector = lineEnd - lineStart;
    final lineLength = lineVector.distance;

    // Special case: if line is actually a point
    if (lineLength < 1e-10) {
      final distanceToLineStart = (point - lineStart).distance;
      return distanceToLineStart <= tolerance;
    }

    // Calculate the perpendicular distance from point to line
    final crossProduct =
        (point.dx - lineStart.dx) * (lineEnd.dy - lineStart.dy) -
            (point.dy - lineStart.dy) * (lineEnd.dx - lineStart.dx);
    final distance = crossProduct.abs() / lineLength;

    // Step 3: Check if the closest point on the line is actually on the line segment
    // Calculate how far along the line the closest point is
    final dot = (point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
        (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy);
    final projectionRatio = dot / (lineLength * lineLength);

    // If projection ratio is between 0 and 1, the closest point is on the line segment
    // Otherwise, we need to check distance to endpoints
    if (projectionRatio < 0) {
      // Closest point is beyond lineStart
      return (point - lineStart).distance <= tolerance;
    } else if (projectionRatio > 1) {
      // Closest point is beyond lineEnd
      return (point - lineEnd).distance <= tolerance;
    }

    // The closest point is on the line segment, use the perpendicular distance
    return distance <= tolerance;
  }

  bool isPointNearRectFromDiagonalVertices(
      Offset point, Offset vertex1, Offset vertex2,
      {double tolerance = 20.0}) {
    final rect = Rect.fromPoints(vertex1, vertex2);

    final expandedRect = Rect.fromLTRB(
      rect.left - tolerance,
      rect.top - tolerance,
      rect.right + tolerance,
      rect.bottom + tolerance,
    );

    return expandedRect.contains(point);
  }

  bool isPointInsideArea(Offset topLeft, Offset topRight, Offset bottomRight,
      Offset bottomLeft, Offset point) {
    final channelPath = Path();
    channelPath.moveTo(toX(topLeft.dx), toY(topLeft.dy));
    channelPath.lineTo(toX(topRight.dx), toY(topRight.dy));
    channelPath.lineTo(toX(bottomRight.dx), toY(bottomRight.dy));
    channelPath.lineTo(toX(bottomLeft.dx), toY(bottomLeft.dy));
    channelPath.close();

    return channelPath.contains(point);
  }
}
