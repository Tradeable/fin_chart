import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/layers/static_layer.dart';
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
  void drawLayer({required Canvas canvas}) {
    // This is a basic implementation. You can customize this extensively.

    final candleHigh = yMaxValue;
    final targetPoint = toCanvas(Offset(targetIndex.toDouble(), candleHigh));

    final labelBoxPosition = Offset(targetPoint.dx, topPos - 20);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(labelBoxPosition, targetPoint, linePaint);

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()..color = color,
    );

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
