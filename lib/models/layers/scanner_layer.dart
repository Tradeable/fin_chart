import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/layers/static_layer.dart';
import 'package:fin_chart/models/region/main_plot_region.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/i_candle.dart';

class ScannerLayer extends StaticLayer {
  final ScannerType scannerType;
  final String label;
  final int targetIndex;
  final List<int> highlightedIndices;
  Color color;
  TextStyle textStyle;

  ScannerLayer({
    required this.scannerType,
    required this.label,
    required this.targetIndex,
    this.highlightedIndices = const [],
    this.color = Colors.purple,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 14),
  }) : super(id: generateV4(), type: LayerType.scanner);

  @override
  void drawLayer({required Canvas canvas, required PlotRegion region}) {
    if (region is! MainPlotRegion) return;
    if (targetIndex >= region.candles.length) return;

    final ICandle targetCandle = region.candles[targetIndex];

    final targetPoint =
        toCanvas(Offset(targetIndex.toDouble(), targetCandle.high));
    final labelBoxPosition = Offset(targetPoint.dx, targetPoint.dy - 30);

    const double gap = 5.0;

    final vector = targetPoint - labelBoxPosition;
    final length = vector.distance;

    final endPoint = labelBoxPosition + (vector * ((length - gap) / length));

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(labelBoxPosition, endPoint, linePaint);

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelRect = Rect.fromCenter(
      center: labelBoxPosition,
      width: textPainter.width + 14,
      height: textPainter.height + 8,
    );

    final rrect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));

    canvas.drawRRect(rrect.shift(const Offset(1, 1)),
        Paint()..color = Colors.black.withAlpha(128));
    canvas.drawRRect(rrect, Paint()..color = color);

    // CHANGED: Adjusted text offset to match new padding
    textPainter.paint(canvas, labelRect.topLeft + const Offset(8, 4));
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'scannerType': scannerType.name,
      'label': label,
      'targetIndex': targetIndex,
      'highlightedIndices': highlightedIndices,
      'color': colorToJson(color),
    });
    return json;
  }

  factory ScannerLayer.fromJson({required Map<String, dynamic> json}) {
    return ScannerLayer(
      scannerType:
          ScannerType.values.firstWhere((e) => e.name == json['scannerType']),
      label: json['label'],
      targetIndex: json['targetIndex'],
      highlightedIndices: List<int>.from(json['highlightedIndices']),
      color: colorFromJson(json['color']),
    );
  }
}
