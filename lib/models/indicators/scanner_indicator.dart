import 'dart:math';
import 'package:fin_chart/models/enums/trend_detection.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/enums/scanner_display_type.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/indicators/pivot_point.dart';
import 'package:fin_chart/models/scanners/scanner_engine.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:fin_chart/models/scanners/trend_data.dart';
import 'package:fin_chart/ui/indicator_settings/scanner_config_dialog.dart';
import 'package:fin_chart/ui/indicator_settings/scanner_selection_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/scanners/scanner_properties.dart';

class ScannerIndicator extends Indicator {
  ScannerType? selectedScannerType;
  Color highlightColor;
  TrendDetection trendDetection;
  PivotTimeframe timeframe;
  Set<int> removedResultIndices;
  ScannerResult? selectedResult;

  List<ScannerResult> activeScanResults = [];
  final List<ICandle> candles = [];

  ScannerIndicator({
    this.selectedScannerType,
    this.highlightColor = const Color(0xFFFFA000),
    this.trendDetection = TrendDetection.none,
    this.timeframe = PivotTimeframe.daily,
    this.removedResultIndices = const {},
  }) : super(
            id: generateV4(),
            type: IndicatorType.scanner,
            displayMode: DisplayMode.main);

  ScannerIndicator._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.selectedScannerType,
    required this.highlightColor,
    required this.trendDetection,
    required this.timeframe,
    required this.removedResultIndices,
  });

  Rect? _getResultBoundingBox(ScannerResult result) {
    if (result.targetIndex >= candles.length) return null;

    if (result.scannerType.displayType == ScannerDisplayType.areaShade) {
      final index = result.targetIndex;
      final left = toX(index.toDouble()) - (xStepWidth / 2);
      final right = toX(index.toDouble()) + (xStepWidth / 2);
      return Rect.fromLTRB(left, topPos, right, bottomPos);
    } else {
      // labelBox
      final group = result.highlightedIndices;
      if (group.isEmpty) return null;

      final targetCandle = candles[result.targetIndex];
      final targetPoint =
          toCanvas(Offset(result.targetIndex.toDouble(), targetCandle.high));
      final labelBoxPosition = Offset(targetPoint.dx, targetPoint.dy - 30);

      final textPainter = TextPainter(
        text: TextSpan(
            text: result.label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      return Rect.fromCenter(
          center: labelBoxPosition,
          width: textPainter.width + 16, // Add padding for easier tapping
          height: textPainter.height + 12);
    }
  }

  @override
  void onTapDown({required TapDownDetails details}) {
    // if (isLocked) return;

    ScannerResult? tappedResult;
    // Iterate in reverse to select the top-most result if they overlap
    for (final result in activeScanResults.reversed) {
      final rect = _getResultBoundingBox(result);
      if (rect != null && rect.contains(details.localPosition)) {
        tappedResult = result;
        break;
      }
    }

    if (tappedResult != selectedResult) {
      selectedResult?.isSelected = false;
      selectedResult = tappedResult;
      selectedResult?.isSelected = true;
    }
  }

  void removeSelectedResult() {
    if (selectedResult != null) {
      final newSet = Set<int>.from(removedResultIndices);
      newSet.add(selectedResult!.targetIndex);
      removedResultIndices = newSet;

      selectedResult!.isSelected = false;
      selectedResult = null;
    }
  }

  @override
  void drawIndicator({required Canvas canvas}) {
    if (selectedScannerType == null || activeScanResults.isEmpty) return;

    // Use the new extension directly on the enum type
    if (selectedScannerType!.displayType == ScannerDisplayType.areaShade) {
      _drawAreaShade(canvas);
    } else {
      _drawLabelBox(canvas);
    }
  }

  void _drawAreaShade(Canvas canvas) {
    for (final result in activeScanResults) {
      if (result.targetIndex >= candles.length) continue;

      final paint = Paint()
        // Change color and opacity when selected
        ..color = (result.isSelected ? Colors.yellow : highlightColor)
            .withAlpha(result.isSelected ? 100 : 50)
        ..style = PaintingStyle.fill;

      final index = result.targetIndex;
      final left = toX(index.toDouble()) - (xStepWidth / 2);
      final right = toX(index.toDouble()) + (xStepWidth / 2);

      final rect = Rect.fromLTRB(left, topPos, right, bottomPos);
      canvas.drawRect(rect, paint);
    }
  }

  void _drawLabelBox(Canvas canvas) {
    for (final result in activeScanResults) {
      final group = result.highlightedIndices;
      if (group.isEmpty) continue;

      // Use a different color and thicker stroke for selected items
      final paintColor =
          result.isSelected ? Colors.yellowAccent : highlightColor;
      final highlightPaint = Paint()
        ..color = paintColor
        ..strokeWidth = result.isSelected ? 3.0 : 2.0
        ..style = PaintingStyle.stroke;

      // ... (rest of the geometry calculation is the same)
      final minIndex = group.reduce(min);
      final maxIndex = group.reduce(max);

      if (maxIndex >= candles.length) continue;

      double highestHigh = candles[minIndex].high;
      double lowestLow = candles[minIndex].low;
      for (final index in group) {
        if (index < candles.length) {
          highestHigh = max(highestHigh, candles[index].high);
          lowestLow = min(lowestLow, candles[index].low);
        }
      }

      final left = toX(minIndex.toDouble()) - (xStepWidth * 0.45);
      final right = toX(maxIndex.toDouble()) + (xStepWidth * 0.45);
      final top = toY(highestHigh);
      final bottom = toY(lowestLow);
      final highlightRect = Rect.fromLTRB(left, top, right, bottom);

      canvas.drawRRect(
          RRect.fromRectAndRadius(
              highlightRect.inflate(3.0), const Radius.circular(4)),
          highlightPaint);

      final targetCandle = candles[result.targetIndex];
      final targetPoint =
          toCanvas(Offset(result.targetIndex.toDouble(), targetCandle.high));
      final labelBoxPosition = Offset(targetPoint.dx, targetPoint.dy - 30);

      const double gap = 5.0;
      final vector = targetPoint - labelBoxPosition;
      final length = vector.distance;
      if (length == 0) continue;

      final newEndPoint =
          labelBoxPosition + (vector * ((length - gap) / length));
      final linePaint = Paint()
        ..color = paintColor
        ..strokeWidth = 1.5;
      canvas.drawLine(labelBoxPosition, newEndPoint, linePaint);

      final textPainter = TextPainter(
        text: TextSpan(
            text: result.label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromCenter(
          center: labelBoxPosition,
          width: textPainter.width + 12,
          height: textPainter.height + 8);
      final rrect =
          RRect.fromRectAndRadius(labelRect, const Radius.circular(4));

      canvas.drawRRect(rrect.shift(const Offset(1, 1)),
          Paint()..color = Colors.black.withAlpha((0.5 * 255).toInt()));
      canvas.drawRRect(rrect, Paint()..color = paintColor);

      textPainter.paint(canvas, labelRect.topLeft + const Offset(6, 4));
    }
  }

  @override
  void updateData(List<ICandle> data) {
    candles.clear();
    candles.addAll(data);

    if (selectedScannerType == null) {
      activeScanResults = [];
      return;
    }

    TrendData trendData = TrendData();
    if (trendDetection == TrendDetection.sma50 ||
        trendDetection == TrendDetection.sma50sma200) {
      trendData = TrendData(sma50: _calculateSMA(50));
    }
    if (trendDetection == TrendDetection.sma50sma200) {
      trendData = TrendData(sma50: trendData.sma50, sma200: _calculateSMA(200));
    }

    final allResults = runScanner(selectedScannerType!, candles,
        trendData: trendData,
        pivotTimeframe: timeframe,
        trendDetection: trendDetection);

    activeScanResults = allResults
        .where((result) => !removedResultIndices.contains(result.targetIndex))
        .toList();
  }

  @override
  void showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    if (selectedScannerType == null) {
      showDialog(
        context: context,
        builder: (context) => ScannerSelectionDialog(
          onScannerSelected: (scannerType) {
            selectedScannerType = scannerType;
            highlightColor = scannerType.properties['defaultColor'] as Color;
            onUpdate(this);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => ScannerConfigDialog(
          indicator: this,
          onUpdate: (indicator) {
            updateData(candles);
            onUpdate(indicator);
          },
        ),
      );
    }
  }

  @override
  Widget indicatorToolTip({
    required Indicator? selectedIndicator,
    required Function(Indicator)? onClick,
    required Function()? onSettings,
    required Function()? onDelete,
    Widget? child,
  }) {
    String labelText;
    if (selectedScannerType != null) {
      // Use the new extension to get the scanner name
      final scannerName = selectedScannerType!.displayName;
      final foundCount = activeScanResults.length;
      labelText = 'Scanner: $scannerName ($foundCount)';
    } else {
      labelText = 'Scanner: (Unconfigured)';
    }

    // The rest of the method remains the same...
    return InkWell(
      onTap: () => onClick?.call(this),
      child: selectedIndicator == this
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(labelText.toUpperCase()),
                  const SizedBox(width: 10),
                  IconButton(
                      onPressed: onSettings, icon: const Icon(Icons.settings)),
                  IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_rounded)),
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                labelText.toUpperCase(),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['selectedScannerType'] = selectedScannerType?.name;
    json['highlightColor'] = colorToJson(highlightColor);
    json['trendDetection'] = trendDetection.name;
    json['timeframe'] = timeframe.name;
    json['removedResultIndices'] = removedResultIndices.toList();
    return json;
  }

  factory ScannerIndicator.fromJson(Map<String, dynamic> json) {
    return ScannerIndicator._(
      id: json['id'],
      type: IndicatorType.scanner,
      displayMode: DisplayMode.main,
      highlightColor: colorFromJson(json['highlightColor']),
      trendDetection: TrendDetection.values.firstWhere(
        (e) => e.name == json['trendDetection'],
        orElse: () => TrendDetection.none,
      ),
      timeframe: PivotTimeframe.values.firstWhere(
        (e) => e.name == json['timeframe'],
        orElse: () => PivotTimeframe.daily,
      ),
      selectedScannerType: json['selectedScannerType'] != null
          ? ScannerType.values.firstWhere(
              (e) => e.name == json['selectedScannerType'],
            )
          : null,
      removedResultIndices: Set<int>.from(json['removedResultIndices'] ?? []),
    );
  }

  // Helper method to calculate SMA for trend detection
  List<double> _calculateSMA(int period) {
    List<double> smaValues = [];
    if (candles.length < period) return [];

    for (int i = 0; i < candles.length; i++) {
      if (i < period - 1) {
        smaValues.add(0);
      } else {
        double sum = 0;
        for (int j = i - (period - 1); j <= i; j++) {
          sum += candles[j].close;
        }
        smaValues.add(sum / period);
      }
    }
    return smaValues;
  }
}
