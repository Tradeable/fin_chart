import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/pivot_point_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

enum PivotTimeframe { daily, weekly, monthly }

class PivotLevel {
  final int startIndex;
  final int endIndex;
  final double pivot;
  final double r1, r2, r3;
  final double s1, s2, s3;

  PivotLevel({
    required this.startIndex,
    required this.endIndex,
    required this.pivot,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.s1,
    required this.s2,
    required this.s3,
  });
}

class PeriodData {
  final int startIndex;
  final int endIndex;
  final List<ICandle> candles;

  PeriodData({
    required this.startIndex,
    required this.endIndex,
    required this.candles,
  });
}

class PivotPoint extends Indicator {
  PivotTimeframe timeframe = PivotTimeframe.daily;
  Color pivotColor = Colors.blue;
  Color resistanceColor = Colors.red;
  Color supportColor = Colors.green;
  bool showLabels = true;

  final List<ICandle> candles = [];
  final List<PivotLevel> pivotLevels = [];

  PivotPoint({
    this.timeframe = PivotTimeframe.daily,
    this.pivotColor = Colors.blue,
    this.resistanceColor = Colors.red,
    this.supportColor = Colors.green,
    this.showLabels = true,
  }) : super(
            id: generateV4(),
            type: IndicatorType.pivotPoint,
            displayMode: DisplayMode.main);

  PivotPoint._({
    required String id,
    this.timeframe = PivotTimeframe.daily,
    this.pivotColor = Colors.blue,
    this.resistanceColor = Colors.red,
    this.supportColor = Colors.green,
    this.showLabels = true,
  }) : super(
            id: id,
            type: IndicatorType.pivotPoint,
            displayMode: DisplayMode.main);

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || pivotLevels.isEmpty) return;

    for (final level in pivotLevels) {
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.pivot, pivotColor, 'PP');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.r1, resistanceColor, 'R1');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.r2, resistanceColor, 'R2');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.r3, resistanceColor, 'R3');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.s1, supportColor, 'S1');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.s2, supportColor, 'S2');
      _drawHorizontalLineForPeriod(canvas, level.startIndex, level.endIndex,
          level.s3, supportColor, 'S3');
    }
  }

  void _drawHorizontalLineForPeriod(Canvas canvas, int startIndex, int endIndex,
      double price, Color color, String label) {
    if (price == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final y = toY(price);
    final startX = toX(startIndex.toDouble());
    final endX = toX(endIndex.toDouble());

    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

    if (showLabels) {
      final textPainter = TextPainter(
        text:
            TextSpan(text: label, style: TextStyle(color: color, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + 5, y - 10));
    }
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    if (candles.isEmpty) {
      candles.addAll(data);
    } else {
      int existingCount = candles.length;
      if (data.length > existingCount) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    _calculatePivotPoints();

    // Set yLabelSize for consistency
    yLabelSize = getLargetRnderBoxSizeForList(
        ['0.00'], // Just a placeholder
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  void _calculatePivotPoints() {
    if (candles.isEmpty) return;

    // Clear previous calculations
    pivotLevels.clear();

    // Group candles by timeframe periods
    final periods = _groupCandlesByPeriod();

    // Calculate pivot points for each period using PREVIOUS period's data
    for (int i = 1; i < periods.length; i++) {
      final previousPeriod = periods[i - 1]; // Use previous period's data
      final currentPeriod = periods[i]; // Apply pivots to current period

      if (previousPeriod.candles.isEmpty) continue;

      // Calculate using PREVIOUS period's H/L/C
      final high = previousPeriod.candles
          .map((c) => c.high)
          .reduce((a, b) => a > b ? a : b);
      final low = previousPeriod.candles
          .map((c) => c.low)
          .reduce((a, b) => a < b ? a : b);
      final close = previousPeriod.candles.last.close;

      // Standard pivot point calculation
      final pivot = (high + low + close) / 3;
      final r1 = (2 * pivot) - low;
      final r2 = pivot + (high - low);
      final r3 = high + 2 * (pivot - low);
      final s1 = (2 * pivot) - high;
      final s2 = pivot - (high - low);
      final s3 = low - 2 * (high - pivot);

      // Apply these pivots to CURRENT period
      pivotLevels.add(PivotLevel(
        startIndex: currentPeriod.startIndex,
        endIndex: currentPeriod.endIndex,
        pivot: pivot,
        r1: r1,
        r2: r2,
        r3: r3,
        s1: s1,
        s2: s2,
        s3: s3,
      ));
    }
  }

  List<PeriodData> _groupCandlesByPeriod() {
    final periods = <PeriodData>[];

    DateTime? currentPeriodStart;
    int startIndex = 0;

    for (int i = 0; i < candles.length; i++) {
      final candleDate = candles[i].date;
      final periodStart = _getPeriodStart(candleDate);

      if (currentPeriodStart == null ||
          !_isSamePeriod(currentPeriodStart, periodStart)) {
        // Start new period
        if (currentPeriodStart != null && i > startIndex) {
          periods.add(PeriodData(
            startIndex: startIndex,
            endIndex: i - 1,
            candles: candles.sublist(startIndex, i),
          ));
        }
        currentPeriodStart = periodStart;
        startIndex = i;
      }
    }

    // Add final period
    if (startIndex < candles.length) {
      periods.add(PeriodData(
        startIndex: startIndex,
        endIndex: candles.length - 1,
        candles: candles.sublist(startIndex),
      ));
    }

    return periods;
  }

  DateTime _getPeriodStart(DateTime date) {
    switch (timeframe) {
      case PivotTimeframe.daily:
        return DateTime(date.year, date.month, date.day);
      case PivotTimeframe.weekly:
        final daysSinceMonday = date.weekday - 1;
        return DateTime(date.year, date.month, date.day - daysSinceMonday);
      case PivotTimeframe.monthly:
        return DateTime(date.year, date.month, 1);
    }
  }

  bool _isSamePeriod(DateTime period1, DateTime period2) {
    switch (timeframe) {
      case PivotTimeframe.daily:
        return period1.year == period2.year &&
            period1.month == period2.month &&
            period1.day == period2.day;
      case PivotTimeframe.weekly:
        return period1.isAtSameMomentAs(period2);
      case PivotTimeframe.monthly:
        return period1.year == period2.year && period1.month == period2.month;
    }
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => PivotPointSettingsDialog(
        indicator: this,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['timeframe'] = timeframe.name;
    json['pivotColor'] = colorToJson(pivotColor);
    json['resistanceColor'] = colorToJson(resistanceColor);
    json['supportColor'] = colorToJson(supportColor);
    json['showLabels'] = showLabels;
    return json;
  }

  factory PivotPoint.fromJson(Map<String, dynamic> json) {
    return PivotPoint._(
      id: json['id'] ?? generateV4(),
      timeframe: _parseTimeframe(json['timeframe']),
      pivotColor: json['pivotColor'] != null
          ? colorFromJson(json['pivotColor'])
          : Colors.blue,
      resistanceColor: json['resistanceColor'] != null
          ? colorFromJson(json['resistanceColor'])
          : Colors.red,
      supportColor: json['supportColor'] != null
          ? colorFromJson(json['supportColor'])
          : Colors.green,
      showLabels: json['showLabels'] ?? true,
    );
  }

  static PivotTimeframe _parseTimeframe(String? timeframeString) {
    switch (timeframeString?.toLowerCase()) {
      case 'weekly':
        return PivotTimeframe.weekly;
      case 'monthly':
        return PivotTimeframe.monthly;
      default:
        return PivotTimeframe.daily;
    }
  }
}
