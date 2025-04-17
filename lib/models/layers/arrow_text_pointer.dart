import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/arrow_text_pointer_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

enum TextAlignPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

class ArrowTextPointer extends Layer {
  Offset pos;
  String label;
  Color color;
  bool isPointingDown;
  TextAlignPosition textAlignment;

  late Offset startPoint;
  Offset? tempPos;

  ArrowTextPointer._({
    required super.id,
    required super.type,
    required super.isLocked,
    required this.pos,
    required this.label,
    required this.color,
    required this.isPointingDown,
    required this.textAlignment,
  });

  ArrowTextPointer.fromTool({
    required this.pos,
    required this.label,
  })  : color = const Color(0xFF2196F3),
        isPointingDown = false,
        textAlignment = TextAlignPosition.bottomCenter,
        super.fromTool(id: generateV4(), type: LayerType.arrowTextPointer) {
    isSelected = true;
    tempPos = pos;
  }

  factory ArrowTextPointer.fromJson({required Map<String, dynamic> json}) {
    return ArrowTextPointer._(
      id: json['id'],
      type:
          (json['type'] as String).toLayerType() ?? LayerType.arrowTextPointer,
      isLocked: json['isLocked'] ?? false,
      pos: offsetFromJson(json['pos']),
      label: json['label'],
      color: Color(json['color'] ?? 0xFF2196F3),
      isPointingDown: json['isPointingDown'] ?? false,
      textAlignment: TextAlignPosition.values.firstWhere(
        (e) => e.name == json['textAlignment'],
        orElse: () => TextAlignPosition.bottomCenter,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'pos': {'dx': pos.dx, 'dy': pos.dy},
      'label': label,
      'color': color,
      'isPointingDown': isPointingDown,
      'textAlignment': textAlignment.name,
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    const arrowLength = 30.0;
    const arrowHeadSize = 6.0;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset tip = toCanvas(pos);
    final Offset base = Offset(
        tip.dx, isPointingDown ? tip.dy + arrowLength : tip.dy - arrowLength);
    final Offset left = tip.translate(
        -arrowHeadSize, isPointingDown ? arrowHeadSize : -arrowHeadSize);
    final Offset right = tip.translate(
        arrowHeadSize, isPointingDown ? arrowHeadSize : -arrowHeadSize);

    canvas.drawLine(base, tip, paint);

    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 200);
    double yOffset = isPointingDown
        ? base.dy + 5
        : tip.dy - textPainter.height - arrowLength - 5;

    double xOffset;
    switch (textAlignment) {
      case TextAlignPosition.topLeft:
      case TextAlignPosition.bottomLeft:
        xOffset = tip.dx;
        break;
      case TextAlignPosition.topRight:
      case TextAlignPosition.bottomRight:
        xOffset = tip.dx - textPainter.width;
        break;
      case TextAlignPosition.topCenter:
      case TextAlignPosition.bottomCenter:
        xOffset = tip.dx - textPainter.width / 2;
        break;
    }
    textPainter.paint(canvas, Offset(xOffset, yOffset));
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    const arrowHeadSize = 6;
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(pos), arrowHeadSize * 4)) {
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
      builder: (ctx) => ArrowTextPointerSettingsDialog(
        layer: this,
        onUpdate: (updated) => onUpdate(updated),
      ),
    );
  }
}
