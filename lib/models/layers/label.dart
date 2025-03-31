import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/label_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/utils/calculations.dart';

class Label extends Layer {
  late Offset pos;
  late String label;
  late TextStyle textStyle;
  late double width;
  late double height;

  Label._(
      {required super.id,
      required super.type,
      required super.isLocked,
      required this.pos,
      required this.label,
      required this.textStyle});

  Label.fromTool(
      {required this.pos, required this.label, required this.textStyle})
      : super.fromTool(id: generateV4(), type: LayerType.label);

  factory Label.fromJson({required Map<String, dynamic> json}) {
    return Label._(
      id: json['id'],
      type: (json['type'] as String).toLayerType() ?? LayerType.label,
      pos: offsetFromJson(json['pos']),
      label: json['label'] ?? '',
      textStyle: TextStyle(
          color: colorFromJson(json['textColor']),
          fontSize: json['fontSize'].toDouble() ?? 16.0,
          fontWeight: fontWeightFromJson(json[
              'fontWeight']) //json['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
          ),
      isLocked: json['isLocked'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'pos': {'dx': pos.dx, 'dy': pos.dy},
      'label': label,
      'textColor': colorToJson(textStyle.color ?? Colors.black),
      'fontSize': textStyle.fontSize,
      'fontWeight': fontWeightToJson(textStyle
          .fontWeight) //textStyle.fontWeight == FontWeight.bold ? 'bold' : 'normal'
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    final TextPainter text = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    width = text.width;
    height = text.height;

    text.paint(canvas, toCanvas(pos));
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    if (isPointNearRectFromDiagonalVertices(details.localPosition,
        toCanvas(pos), Offset(toX(pos.dx) + width, toY(pos.dy) + height))) {
      return this;
    }
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    pos = Offset(toXInverse(details.localFocalPoint.dx),
        toYInverse(details.localFocalPoint.dy).clamp(yMinValue, yMaxValue));
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => LabelSettingsDialog(
        layer: this,
        onUpdate: onUpdate,
      ),
    );
  }
}
