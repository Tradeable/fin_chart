import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:flutter/material.dart';

class EarningsEvent extends FundamentalEvent {
  final double? epsActual;
  final double? epsEstimate;
  final double? epsSurprise;
  final double? revenueActual;
  final double? revenueEstimate;
  final double? revenueSurprise;

  EarningsEvent({
    required super.id,
    required super.date,
    required super.title,
    super.description,
    this.epsActual,
    this.epsEstimate,
    this.epsSurprise,
    this.revenueActual,
    this.revenueEstimate,
    this.revenueSurprise,
  }) : super(type: EventType.earnings);

  @override
  Color get color =>
      epsSurprise != null && epsSurprise! > 0 ? Colors.green : Colors.red;

  @override
  String get iconText => 'E';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      if (epsActual != null) 'actual': epsActual,
      if (epsEstimate != null) 'estimate': epsEstimate,
      if (epsSurprise != null) 'surprise': epsSurprise,
      if (revenueActual != null) 'revenueActual': revenueActual,
      if (revenueEstimate != null) 'revenueEstimate': revenueEstimate,
      if (revenueSurprise != null) 'revenueSurprise': revenueSurprise,
    };
  }

  factory EarningsEvent.fromJson(Map<String, dynamic> json) {
    return EarningsEvent(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'] ?? '',
      epsActual: json['actual'],
      epsEstimate: json['estimate'],
      epsSurprise: json['surprise'],
      revenueActual: json['revenueActual'],
      revenueEstimate: json['revenueEstimate'],
      revenueSurprise: json['revenueSurprise'],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return '₹${value.toStringAsFixed(2)}';
    }
  }

  @override
  void drawTooltip(Canvas canvas) {
    if (!isSelected || position == null) return;
    drawSelectionLine(canvas, topPos, bottomPos);

    List<TextSpan> textSpans = [];

    textSpans.add(const TextSpan(
      text: 'Earnings and Revenue\n',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
    ));

    textSpans.add(TextSpan(
      text: 'Date: ${_formatDate(date)}\n\n',
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ));

    textSpans.add(const TextSpan(
      text: 'EPS\n',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 11),
    ));

    if (epsActual != null) {
      textSpans.add(TextSpan(
        text: 'Reported: ${epsActual!.toStringAsFixed(2)}\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }

    if (epsEstimate != null) {
      textSpans.add(TextSpan(
        text: 'Estimated: ${epsEstimate!.toStringAsFixed(2)}\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    }

    // Calculate EPS surprise if both actual and estimate are available
    if (epsActual != null && epsEstimate != null) {
      final epsSurprise = (epsActual! - epsEstimate!);
      final epsSurprisePer = (epsSurprise / epsEstimate! * 100);
      textSpans.add(TextSpan(
        text: 'Surprise: $epsSurprise (${epsSurprisePer.toStringAsFixed(2)}%)\n\n',
        style: const TextStyle(color: Colors.black, fontSize: 11),
      ));
    } else {
      textSpans.add(const TextSpan(text: '\n'));
    }

    // Only show Revenue section if we have any revenue data
    if (revenueActual != null || revenueEstimate != null) {
      textSpans.add(const TextSpan(
        text: 'Revenue\n',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 11),
      ));

      if (revenueActual != null) {
        textSpans.add(TextSpan(
          text: 'Reported: ${_formatCurrency(revenueActual!)}\n',
          style: const TextStyle(color: Colors.black, fontSize: 11),
        ));
      }

      if (revenueEstimate != null) {
        textSpans.add(TextSpan(
          text: 'Estimated: ${_formatCurrency(revenueEstimate!)}\n',
          style: const TextStyle(color: Colors.black, fontSize: 11),
        ));
      }

      // Calculate revenue surprise if both actual and estimate are available
      if (revenueActual != null && revenueEstimate != null) {
        final revenueSurprise = (revenueActual! - revenueEstimate!);
        final revenueSurprisePer = (revenueSurprise / revenueEstimate! * 100);
        textSpans.add(TextSpan(
          text: 'Surprise: ${_formatCurrency(revenueSurprise)} (${revenueSurprisePer.toStringAsFixed(2)}%)\n',
          style: const TextStyle(color: Colors.black, fontSize: 11),
        ));
      }
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
