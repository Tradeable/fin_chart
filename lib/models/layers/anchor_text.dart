import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/anchor_text_settings.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class AnchorText extends Layer {
  Offset pos;
  String label;
  Color textColor;
  Color borderColor;
  Color backgroundColor;
  double borderWidth;

  late Offset startPoint;
  Offset? tempPos;

  AnchorText._({
    required super.id,
    required super.type,
    required super.isLocked,
    required this.pos,
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.borderWidth,
  });

  AnchorText.fromTool({
    required this.pos,
    required this.label,
  })  : textColor = Colors.black,
        borderColor = Colors.black,
        backgroundColor = Colors.transparent,
        borderWidth = 1.0,
        super.fromTool(id: generateV4(), type: LayerType.anchorText) {
    isSelected = true;
    tempPos = pos;
  }

  factory AnchorText.fromJson({required Map<String, dynamic> json}) {
    return AnchorText._(
      id: json['id'],
      type: (json['type'] as String).toLayerType() ?? LayerType.anchorText,
      isLocked: json['isLocked'] ?? false,
      pos: offsetFromJson(json['pos']),
      label: json['label'],
      textColor: Color(json['textColor'] ?? 0xFF000000),
      borderColor: Color(json['borderColor'] ?? 0xFF000000),
      backgroundColor: Color(json['backgroundColor'] ?? 0x00000000),
      borderWidth: json['borderWidth']?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'pos': {'dx': pos.dx, 'dy': pos.dy},
      'label': label,
      'textColor': textColor,
      'borderColor': borderColor,
      'backgroundColor': backgroundColor,
      'borderWidth': borderWidth,
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 200);
    // final Offset canvasPos = toCanvas(pos);
    final Offset canvasPos = Offset(toXInverse(pos.dx), toY(pos.dy));
    final Rect rect = Rect.fromLTWH(canvasPos.dx, canvasPos.dy,
        textPainter.width + 10, textPainter.height + 10);
    canvas.drawRect(rect, paint);

    paint.color = borderColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = borderWidth;
    canvas.drawRect(rect, paint);

    textPainter.paint(canvas, Offset(canvasPos.dx + 5, canvasPos.dy + 5));
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final Offset canvasPos = toCanvas(pos);

    final Rect textRect = Rect.fromLTWH(canvasPos.dx, canvasPos.dy,
        textPainter.width + 10, textPainter.height + 10);

    if (textRect.contains(details.localPosition)) {
      isSelected = true;
      startPoint = details.localPosition;
      tempPos = pos;
      return this;
    }

    isSelected = false;
    tempPos = null;
    return super.onTapDown(details: details);
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    if (isLocked) return;
    Offset displacement =
        displacementOffset(startPoint, details.localFocalPoint);
    if (tempPos != null) {
      pos =
          Offset(tempPos!.dx + displacement.dx, tempPos!.dy + displacement.dy);
    }
  }

  @override
  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {
    showDialog(
      context: context,
      builder: (ctx) => AnchorTextSettingsDialog(
        layer: this,
        onUpdate: (updated) => onUpdate(updated),
      ),
    );
  }
}
