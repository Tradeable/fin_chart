import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/fundamental/earnings_event.dart';
import 'package:fin_chart/ui/indicator_settings/pb_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Pb extends Indicator {
  double defaultBookValue;
  Color lineColor;
  final Map<DateTime, double> bookValueOverrides =
      {}; // Store book value changes from events
  final List<double> pbValues = [];
  final List<ICandle> candles = [];

  // Add this field for getting fundamental events
  Function()? getFundamentalEvents;

  Pb({
    this.defaultBookValue = 100.0,
    this.lineColor = Colors.teal,
    this.getFundamentalEvents,
  }) : super(
            id: generateV4(),
            type: IndicatorType.pb,
            displayMode: DisplayMode.panel);

  Pb._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.defaultBookValue = 100.0,
    this.lineColor = Colors.teal,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || pbValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    for (int i = 0; i < pbValues.length; i++) {
      if (pbValues[i] <= 0) continue; // Skip invalid P/B values

      final x = toX(i.toDouble());
      final y = toY(pbValues[i]);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw book value change markers
    _drawBookValueChangeMarkers(canvas);
  }

  void _drawBookValueChangeMarkers(Canvas canvas) {
    for (final overrideDate in bookValueOverrides.keys) {
      // Find candle index for this date
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (candle.date.year == overrideDate.year &&
            candle.date.month == overrideDate.month &&
            candle.date.day == overrideDate.day) {
          final x = toX(i.toDouble());
          final y = toY(pbValues[i]);

          // Determine marker color based on P/B change
          Color markerColor = Colors.grey; // Default

          if (i > 0) {
            final previousPB = pbValues[i - 1];
            final currentPB = pbValues[i];

            if (currentPB < previousPB) {
              markerColor = Colors.green; // P/B decreased (good)
            } else if (currentPB > previousPB) {
              markerColor = Colors.red; // P/B increased (could be bad)
            }
          }

          final markerPaint = Paint()
            ..color = markerColor
            ..style = PaintingStyle.fill;

          // Draw small triangle marker
          final path = Path()
            ..moveTo(x, y - 8)
            ..lineTo(x - 4, y - 2)
            ..lineTo(x + 4, y - 2)
            ..close();

          canvas.drawPath(path, markerPaint);
          break;
        }
      }
    }
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;

    // Update candles list
    if (candles.isEmpty) {
      candles.addAll(data);
    } else {
      int existingCount = candles.length;
      if (data.length > existingCount) {
        candles.addAll(data.sublist(existingCount));
      }
    }

    // Auto-update book value overrides from fundamental events if callback is available
    if (getFundamentalEvents != null) {
      _autoUpdateBookValueFromEvents();
    }

    calculatePB();
    updateYAxisValues();
  }

  void _autoUpdateBookValueFromEvents() {
    try {
      final events = getFundamentalEvents!() as List<FundamentalEvent>;

      // Clear and rebuild book value overrides
      bookValueOverrides.clear();

      for (final event in events.whereType<EarningsEvent>()) {
        if (event.bookValue != null && event.bookValue! > 0) {
          bookValueOverrides[event.date] = event.bookValue!;
        }
      }
    } catch (e) {
      // Silently continue with existing book value overrides if fundamental events unavailable
    }
  }

  void calculatePB() {
    pbValues.clear();

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final bookValue = _getBookValueForDate(candle.date);

      if (bookValue > 0) {
        pbValues.add(candle.close / bookValue);
      } else {
        pbValues.add(0);
      }
    }

    _debugPrintData();
  }

  double _getBookValueForDate(DateTime date) {
    // Find the most recent book value override before or on this date
    DateTime? mostRecentOverrideDate;

    for (final overrideDate in bookValueOverrides.keys) {
      if (overrideDate.isBefore(date.add(const Duration(days: 1)))) {
        if (mostRecentOverrideDate == null ||
            overrideDate.isAfter(mostRecentOverrideDate)) {
          mostRecentOverrideDate = overrideDate;
        }
      }
    }

    // Return override book value if found, otherwise default
    return mostRecentOverrideDate != null
        ? bookValueOverrides[mostRecentOverrideDate]!
        : defaultBookValue;
  }

  void updateYAxisValues() {
    final validPBs = pbValues.where((v) => v > 0).toList();

    if (validPBs.isEmpty) {
      yMinValue = 0;
      yMaxValue = 5;
      yValues = [0, 1, 2, 3, 4, 5];
      return;
    }

    final minPB = validPBs.reduce((a, b) => a < b ? a : b);
    final maxPB = validPBs.reduce((a, b) => a > b ? a : b);

    // Add some padding
    final padding = (maxPB - minPB) * 0.1;
    final adjustedMin =
        (minPB - padding).clamp(0.0, double.infinity).toDouble();
    final adjustedMax = (maxPB + padding).toDouble();

    // Try manual Y values first to test
    yMinValue = adjustedMin;
    yMaxValue = adjustedMax;

    // Create simple Y values manually
    final step = (adjustedMax - adjustedMin) / 5;
    yValues = [
      adjustedMin,
      adjustedMin + step,
      adjustedMin + step * 2,
      adjustedMin + step * 3,
      adjustedMin + step * 4,
      adjustedMax,
    ];

    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toStringAsFixed(1)).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  // Call this when earnings events with book value are added/updated
  void addBookValueOverride(DateTime date, double bookValue) {
    bookValueOverrides[date] = bookValue;

    // Trigger recalculation if we have candle data
    if (candles.isNotEmpty) {
      calculatePB();
      updateYAxisValues();
    }
  }

  void removeBookValueOverride(DateTime date) {
    bookValueOverrides.remove(date);

    // Trigger recalculation if we have candle data
    if (candles.isNotEmpty) {
      calculatePB();
      updateYAxisValues();
    }
  }

  void _debugPrintData() {
    bookValueOverrides.forEach((date, bookValue) {});

    if (pbValues.isNotEmpty) {}
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => PbSettingsDialog(
        indicator: this,
        onUpdate: (updatedIndicator) => onUpdate(updatedIndicator),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['defaultBookValue'] = defaultBookValue;
    json['lineColor'] = colorToJson(lineColor);

    // Save book value overrides
    json['bookValueOverrides'] = bookValueOverrides
        .map((date, bookValue) => MapEntry(date.toIso8601String(), bookValue));

    return json;
  }

  factory Pb.fromJson(Map<String, dynamic> json) {
    final pb = Pb._(
      id: json['id'] ?? generateV4(),
      type: IndicatorType.pb,
      displayMode: DisplayMode.panel,
      defaultBookValue: json['defaultBookValue']?.toDouble() ?? 100.0,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.teal,
    );

    // Restore book value overrides
    if (json['bookValueOverrides'] != null) {
      final overrides = json['bookValueOverrides'] as Map<String, dynamic>;
      overrides.forEach((dateStr, bookValue) {
        pb.bookValueOverrides[DateTime.parse(dateStr)] =
            (bookValue as num).toDouble();
      });
    }

    return pb;
  }
}
