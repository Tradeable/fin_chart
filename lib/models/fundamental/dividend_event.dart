import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:flutter/material.dart';

class DividendEvent extends FundamentalEvent {
  final double amount;
  final DateTime? exDividendDate;
  final DateTime? paymentDate;

  DividendEvent({
    required super.id,
    required super.date,
    required super.title,
    required this.exDividendDate,
    required this.paymentDate,
    required this.amount,
    super.description,
  }) : super(type: EventType.dividend);

  @override
  Color get color => Colors.blue;

  @override
  String get iconText => 'D';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'title': title,
      'exDividendDate': exDividendDate?.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'description': description,
      'amount': amount,
    };
  }

  factory DividendEvent.fromJson(Map<String, dynamic> json) {
    return DividendEvent(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      exDividendDate: json['exDividendDate'] != null
          ? DateTime.parse(json['exDividendDate'])
          : null,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      description: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
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
      text: 'Dividend Announcement\n',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
    ));

    textSpans.add(TextSpan(
      text: 'Date: ${_formatDate(date)}\n\n',
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ));

    textSpans.add(TextSpan(
      text: 'Amount: ${amount.toStringAsFixed(2)}\n',
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ));

    if (exDividendDate != null) {
      textSpans.add(TextSpan(
        text: 'Ex-date: ${_formatDate(exDividendDate!)}\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }

    if (paymentDate != null) {
      textSpans.add(TextSpan(
        text: 'Payment Date: ${_formatDate(paymentDate!)}\n',
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
