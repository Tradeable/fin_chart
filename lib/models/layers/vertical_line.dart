import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class VerticalLine extends Layer {
  late double pos;

  late Offset startPoint;

  VerticalLine._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.pos});

  VerticalLine.fromTool({required this.pos})
      : super.fromTool(id: generateV4(), type: LayerType.verticalLine);

  factory VerticalLine.fromJson({required Map<String, dynamic> json}) {
    return VerticalLine._(
        id: json['id'],
        type: (json['type'] as String).toLayerType() ?? LayerType.verticalLine,
        isLocked: json['isLocked'] ?? false,
        pos: json['pos'].toDouble() ?? 0.0);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({'pos': pos});
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    canvas.drawLine(
        Offset(toX(pos) + xStepWidth / 2, topPos),
        Offset(toX(pos) + xStepWidth / 2, bottomPos),
        Paint()
          ..color = Colors.purple
          ..strokeWidth = 2);
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    if (isPointOnLine(details.localPosition, Offset(toX(pos), topPos),
        Offset(toX(pos), bottomPos))) {
      return this;
    }
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;
    pos = toXInverse(details.localFocalPoint.dx);
  }

  @override
  Widget layerToolTip(
      {Widget? child,
      required Function()? onSettings,
      required Function()? onLockUpdate,
      required Function()? onDelete}) {
    return Container();
  }
}
