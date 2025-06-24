import 'package:fin_chart/models/fundamental/earnings_event.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class Pe extends Indicator {
  double defaultEPS;
  Color lineColor;
  final Map<DateTime, double> epsOverrides =
      {}; // Store EPS changes from events
  final List<double> peValues = [];
  final List<ICandle> candles = [];

  // Add this field
  Function()? getFundamentalEvents;

  Pe({
    this.defaultEPS = 10.0,
    this.lineColor = Colors.orange,
    this.getFundamentalEvents, // Add this parameter
  }) : super(
            id: generateV4(),
            type: IndicatorType.pe,
            displayMode: DisplayMode.panel);

  Pe._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.defaultEPS = 10.0,
    this.lineColor = Colors.orange,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.isEmpty || peValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool pathStarted = false;

    for (int i = 0; i < peValues.length; i++) {
      if (peValues[i] <= 0) continue; // Skip invalid P/E values

      final x = toX(i.toDouble());
      final y = toY(peValues[i]);

      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw EPS change markers
    _drawEPSChangeMarkers(canvas);
  }

  void _drawEPSChangeMarkers(Canvas canvas) {
    final markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final overrideDate in epsOverrides.keys) {
      // Find candle index for this date
      for (int i = 0; i < candles.length; i++) {
        final candle = candles[i];
        if (candle.date.year == overrideDate.year &&
            candle.date.month == overrideDate.month &&
            candle.date.day == overrideDate.day) {
          final x = toX(i.toDouble());
          final y = toY(peValues[i]);

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

    // Auto-update EPS overrides from fundamental events if callback is available
    if (getFundamentalEvents != null) {
      _autoUpdateEPSFromEvents();
    }

    _calculatePE();
    _updateYAxisValues();
  }

  void _autoUpdateEPSFromEvents() {
    try {
      final events = getFundamentalEvents!() as List<FundamentalEvent>;

      // Clear and rebuild EPS overrides
      epsOverrides.clear();

      for (final event in events.whereType<EarningsEvent>()) {
        final eps = event.epsActual ?? event.epsEstimate;
        if (eps != null && eps > 0) {
          epsOverrides[event.date] = eps;
        }
      }
    } catch (e) {}
  }

  void _calculatePE() {
    peValues.clear();

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final eps = _getEPSForDate(candle.date);

      if (eps > 0) {
        peValues.add(candle.close / eps);
      } else {
        peValues.add(0);
      }
    }

    _debugPrintData();
  }

  double _getEPSForDate(DateTime date) {
    // Find the most recent EPS override before or on this date
    DateTime? mostRecentOverrideDate;

    for (final overrideDate in epsOverrides.keys) {
      if (overrideDate.isBefore(date.add(const Duration(days: 1)))) {
        if (mostRecentOverrideDate == null ||
            overrideDate.isAfter(mostRecentOverrideDate)) {
          mostRecentOverrideDate = overrideDate;
        }
      }
    }

    // Return override EPS if found, otherwise default
    return mostRecentOverrideDate != null
        ? epsOverrides[mostRecentOverrideDate]!
        : defaultEPS;
  }

  void _updateYAxisValues() {
    final validPEs = peValues.where((v) => v > 0).toList();

    if (validPEs.isEmpty) {
      yMinValue = 0;
      yMaxValue = 50;
      yValues = [0, 10, 20, 30, 40, 50];
      return;
    }

    final minPE = validPEs.reduce((a, b) => a < b ? a : b);
    final maxPE = validPEs.reduce((a, b) => a > b ? a : b);

    // Add some padding
    final padding = (maxPE - minPE) * 0.1;
    final adjustedMin =
        (minPE - padding).clamp(0.0, double.infinity).toDouble();
    final adjustedMax = (maxPE + padding).toDouble();

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

    yMinValue = yValues.first;
    yMaxValue = yValues.last;

    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toStringAsFixed(1)).toList(),
        const TextStyle(color: Colors.black, fontSize: 12));
  }

  // Call this when earnings events are added/updated
  void addEPSOverride(DateTime date, double eps) {
    epsOverrides[date] = eps;

    // Trigger recalculation if we have candle data
    if (candles.isNotEmpty) {
      _calculatePE();
      _updateYAxisValues();
    }
  }

  void removeEPSOverride(DateTime date) {
    epsOverrides.remove(date);

    // Trigger recalculation if we have candle data
    if (candles.isNotEmpty) {
      _calculatePE();
      _updateYAxisValues();
    }
  }

  void _debugPrintData() {
    epsOverrides.forEach((date, eps) {});

    if (peValues.isNotEmpty) {}
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    // TODO: Create PeSettingsDialog to edit defaultEPS
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['defaultEPS'] = defaultEPS;
    json['lineColor'] = colorToJson(lineColor);

    // Save EPS overrides
    json['epsOverrides'] =
        epsOverrides.map((date, eps) => MapEntry(date.toIso8601String(), eps));

    return json;
  }

  factory Pe.fromJson(Map<String, dynamic> json) {
    final pe = Pe._(
      id: json['id'] ?? generateV4(),
      type: IndicatorType.pe,
      displayMode: DisplayMode.panel,
      defaultEPS: json['defaultEPS']?.toDouble() ?? 10.0,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.orange,
    );

    // Restore EPS overrides
    if (json['epsOverrides'] != null) {
      final overrides = json['epsOverrides'] as Map<String, dynamic>;
      overrides.forEach((dateStr, eps) {
        pe.epsOverrides[DateTime.parse(dateStr)] = eps.toDouble();
      });
    }

    return pe;
  }
}
