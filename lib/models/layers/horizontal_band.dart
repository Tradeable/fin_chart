import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/horizontal_band_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class HorizontalBand extends Layer {
  late double value;
  late double allowedError;
  Color color = Colors.amber;

  HorizontalBand._(
      {required super.id,
      required super.type,
      required this.value,
      required this.allowedError,
      required this.color,
      required super.isLocked});

  HorizontalBand.fromTool({required this.value, this.allowedError = 40})
      : super.fromTool(id: generateV4(), type: LayerType.horizontalBand);

  factory HorizontalBand.fromJson({required Map<String, dynamic> json}) {
    return HorizontalBand._(
        id: json['id'],
        type:
            (json['type'] as String).toLayerType() ?? LayerType.horizontalBand,
        value: json['value'].toDouble() ?? 0.0,
        allowedError: json['allowedError'].toDouble() ?? 40.0,
        color: colorFromJson(json['color']),
        isLocked: json['isLocked'] ?? false);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'value': value,
      'allowedError': allowedError,
      'color': colorToJson(color)
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    canvas.drawRect(
        Rect.fromLTWH(leftPos, toY(value) - allowedError / 2,
            rightPos - leftPos, allowedError),
        Paint()
          ..color = color.withAlpha(100)
          ..strokeWidth = 2);
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    if (isPointOnLine(details.localPosition, Offset(leftPos, toY(value)),
        Offset(rightPos, toY(value)))) {
      return this;
    }
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    value = toYInverse(toY(value) + details.focalPointDelta.dy);
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => HorizontalBandSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}
