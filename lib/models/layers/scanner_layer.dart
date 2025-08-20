import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/layers/static_layer.dart';
import 'package:fin_chart/models/region/main_plot_region.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class ScannerLayer extends StaticLayer {
  final ScannerType scannerType;
  final String label;
  final int targetIndex;
  final List<int> highlightedIndices;
  Color color;
  TextStyle textStyle;

  ScannerLayer({
    required this.scannerType, // RENAMED here
    required this.label,
    required this.targetIndex,
    this.highlightedIndices = const [],
    this.color = Colors.purple,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 10),
  }) : super(id: generateV4(), type: LayerType.scanner);

  @override
  void drawLayer({required Canvas canvas, required PlotRegion region}) {
    // Only draw if the region is the main plot and has candles
    if (region is! MainPlotRegion) return;
    if (targetIndex >= region.candles.length) return; // Index out of bounds

    final ICandle targetCandle = region.candles[targetIndex];

    // 1. Get the target point on the chart (pointing to the high of the candle)
    final targetPoint =
        toCanvas(Offset(targetIndex.toDouble(), targetCandle.high));

    // 2. Define the position for the label box (30 pixels above the target point)
    final labelBoxPosition = Offset(targetPoint.dx, targetPoint.dy - 30);

    // 3. Draw a line from the label to the target
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(labelBoxPosition, targetPoint, linePaint);

    // 4. Draw the label
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelRect = Rect.fromCenter(
      center: labelBoxPosition,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );

    final rrect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));

    // Draw a shadow for better visibility
    canvas.drawRRect(rrect.shift(const Offset(1, 1)),
        Paint()..color = Colors.black.withAlpha(128)); // 128/255 ≈ 0.5 opacity
    // Draw the label box
    canvas.drawRRect(rrect, Paint()..color = color);

    // Draw the text
    textPainter.paint(canvas, labelRect.topLeft + const Offset(4, 2));
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'scannerType': scannerType.name, // RENAMED here
      'label': label,
      'targetIndex': targetIndex,
      'highlightedIndices': highlightedIndices,
      'color': colorToJson(color),
    });
    return json;
  }

  factory ScannerLayer.fromJson({required Map<String, dynamic> json}) {
    return ScannerLayer(
      // RENAMED here
      scannerType:
          ScannerType.values.firstWhere((e) => e.name == json['scannerType']),
      label: json['label'],
      targetIndex: json['targetIndex'],
      highlightedIndices: List<int>.from(json['highlightedIndices']),
      color: colorFromJson(json['color']),
    );
  }
}
