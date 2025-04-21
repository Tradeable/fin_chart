import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/ui/layer_settings/arrow_text_pointer_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

enum TextAlignPosition { left, right, center }

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
        textAlignment = TextAlignPosition.center,
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
      color: colorFromJson(json['color']),
      isPointingDown: json['isPointingDown'] ?? false,
      textAlignment: TextAlignPosition.values.firstWhere(
        (e) => e.name == json['textAlignment'],
        orElse: () => TextAlignPosition.center,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'pos': {'dx': pos.dx, 'dy': pos.dy},
      'label': label,
      'color': colorToJson(color),
      'isPointingDown': isPointingDown,
      'textAlignment': textAlignment.name,
    });
    return json;
  }

  @override
  void drawLayer({required Canvas canvas}) {
    final Offset tip = toCanvas(pos);

    // Calculate points for 2D arrow
    final double arrowDirection = isPointingDown ? 1 : -1;

    // The arrow tip is at the position clicked by the user
    final Offset arrowTip = tip;

    // Calculate base of arrow (opposite end from the tip)
    final Offset arrowBase =
        Offset(tip.dx, tip.dy + (arrowDirection * (xStepWidth * 4)));

    // Arrow shaft left and right edges at the base
    final Offset shaftLeftBase =
        Offset(arrowBase.dx - (xStepWidth / 2), arrowBase.dy);
    final Offset shaftRightBase =
        Offset(arrowBase.dx + (xStepWidth / 2), arrowBase.dy);

    // Calculate where the arrowhead begins (where shaft meets the head)
    final double headLength = xStepWidth * 1.5; // Length of the arrowhead
    final Offset headBase =
        Offset(tip.dx, tip.dy + (arrowDirection * headLength));

    // Where the shaft meets the arrowhead
    final Offset shaftLeftEnd =
        Offset(headBase.dx - (xStepWidth / 2), headBase.dy);
    final Offset shaftRightEnd =
        Offset(headBase.dx + (xStepWidth / 2), headBase.dy);

    // Arrow head left and right points (the widest part of the head)
    final Offset headLeft = Offset(headBase.dx - (xStepWidth), headBase.dy);
    final Offset headRight = Offset(headBase.dx + (xStepWidth), headBase.dy);

    // Create 2D filled arrow path
    final Path arrowPath = Path()
      ..moveTo(
          shaftLeftBase.dx, shaftLeftBase.dy) // Start at bottom left of shaft
      ..lineTo(shaftRightBase.dx, shaftRightBase.dy) // Bottom right of shaft
      ..lineTo(shaftRightEnd.dx, shaftRightEnd.dy) // Top right of shaft
      ..lineTo(headRight.dx, headRight.dy) // Right point of arrowhead
      ..lineTo(arrowTip.dx, arrowTip.dy) // Tip of arrow
      ..lineTo(headLeft.dx, headLeft.dy) // Left point of arrowhead
      ..lineTo(shaftLeftEnd.dx, shaftLeftEnd.dy) // Top left of shaft
      ..close();

    // Fill paint for 2D arrow
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outline paint for 2D arrow
    final Paint strokePaint = Paint()
      ..color = color.withAlpha(62)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw filled arrow with outline
    canvas.drawPath(arrowPath, fillPaint);
    canvas.drawPath(arrowPath, strokePaint);

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 200);

    double yOffset = isPointingDown
        ? arrowBase.dy + 5
        : arrowBase.dy - textPainter.height - 5;

    double xOffset;
    switch (textAlignment) {
      case TextAlignPosition.left:
        xOffset = tip.dx;
        break;
      case TextAlignPosition.right:
        xOffset = tip.dx - textPainter.width;
        break;
      case TextAlignPosition.center:
        xOffset = tip.dx - textPainter.width / 2;
        break;
    }
    textPainter.paint(canvas, Offset(xOffset, yOffset));
  }

  @override
  Layer? onTapDown({required TapDownDetails details}) {
    final double detectionRadius = xStepWidth * 1.5;
    if (isPointInCircularRegion(
        details.localPosition, toCanvas(pos), detectionRadius * 2)) {
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
