import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:flutter/material.dart';

class BonusEvent extends FundamentalEvent {
  final String ratio;
  final DateTime? recordDate;
  final DateTime? issueDate;

  BonusEvent({
    required super.id,
    required super.index,
    required super.date,
    required super.title,
    required this.ratio,
    this.recordDate,
    this.issueDate,
    super.description,
  }) : super(type: EventType.bonus);

  @override
  Color get color => Colors.amber;

  @override
  String get iconText => 'B';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'type': type.name,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'ratio': ratio,
      'recordDate': recordDate?.toIso8601String(),
      'issueDate': issueDate?.toIso8601String(),
    };
  }

  factory BonusEvent.fromJson(Map<String, dynamic> json) {
    return BonusEvent(
      id: json['id'],
      index: json['index'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'] ?? '',
      ratio: json['ratio'] ?? '1:1',
      recordDate: json['recordDate'] != null
          ? DateTime.parse(json['recordDate'])
          : null,
      issueDate: json['issueDate'] != null
          ? DateTime.parse(json['issueDate'])
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
  
  @override
  void drawTooltip(Canvas canvas) {
    if (!isSelected || position == null) return;
    drawSelectionLine(canvas, topPos, bottomPos);

    List<TextSpan> textSpans = [];

    textSpans.add(const TextSpan(
      text: 'Bonus Shares\n',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
    ));

    textSpans.add(TextSpan(
      text: 'Date: ${_formatDate(date)}\n\n',
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ));

    textSpans.add(TextSpan(
      text: 'Ratio: $ratio\n',
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ));

    if (recordDate != null) {
      textSpans.add(TextSpan(
        text: 'Record Date: ${_formatDate(recordDate!)}\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }

    if (issueDate != null) {
      textSpans.add(TextSpan(
        text: 'Issue Date: ${_formatDate(issueDate!)}\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }

    if (description.isNotEmpty) {
      textSpans.add(TextSpan(
        text: '\nDetails: $description',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }
    // After creating the textSpans list, render it:
    final textSpan = TextSpan(children: textSpans);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 20,
    )..layout(maxWidth: 200);

// Draw tooltip background
    final rect = Rect.fromCenter(
      center: Offset(
        position!.dx,
        position!.dy - textPainter.height,
      ),
      width: textPainter.width + 16,
      height: textPainter.height,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

// Draw shadow
    canvas.drawRRect(
      rrect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withAlpha((0.2 * 255).toInt()),
    );

// Draw background
    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white,
    );

// Draw border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

// Draw text
    textPainter.paint(
      canvas,
      Offset(
        rect.left + 8,
        rect.top + 5,
      ),
    );

// Draw pointer
    final path = Path()
      ..moveTo(position!.dx, position!.dy - 12)
      ..lineTo(position!.dx - 5, rect.bottom)
      ..lineTo(position!.dx + 5, rect.bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
