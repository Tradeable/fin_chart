import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/enums/trend_detection.dart';
import 'package:fin_chart/models/indicators/pivot_point.dart';
import 'package:fin_chart/models/indicators/scanner_indicator.dart';
import 'package:fin_chart/models/scanners/scanner_properties.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class ScannerConfigDialog extends StatefulWidget {
  final ScannerIndicator indicator;
  final Function(ScannerIndicator) onUpdate;

  const ScannerConfigDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<ScannerConfigDialog> createState() => _ScannerConfigDialogState();
}

class _ScannerConfigDialogState extends State<ScannerConfigDialog> {
  late Color highlightColor;
  late TrendDetection trendDetection;
  late PivotTimeframe timeframe;
  late Set<int> removedIndices;

  final Set<ScannerType> _candlestickScanners = {
    ScannerType.hammer,
    ScannerType.whiteMarubozu,
    ScannerType.blackMarubozu,
    ScannerType.bullishHarami,
    ScannerType.bearishHarami,
    ScannerType.bullishHaramiCross,
    ScannerType.bearishHaramiCross,
    ScannerType.bullishEngulfing,
    ScannerType.bearishEngulfing,
    ScannerType.upsideTasukiGap,
    ScannerType.downsideTasukiGap,
    ScannerType.invertedHammer,
    ScannerType.shootingStar,
    ScannerType.threeWhiteSoldiers,
    ScannerType.identicalThreeCrows,
    ScannerType.abandonedBabyBottom,
    ScannerType.abandonedBabyTop,
    ScannerType.piercingLine,
    ScannerType.darkCloudCover,
    ScannerType.hangingMan,
    ScannerType.bullishKicker,
    ScannerType.morningStar,
    ScannerType.dragonflyDoji,
  };

  @override
  void initState() {
    super.initState();
    highlightColor = widget.indicator.highlightColor;
    trendDetection = widget.indicator.trendDetection;
    timeframe = widget.indicator.timeframe;
    removedIndices = Set<int>.from(widget.indicator.removedResultIndices);
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = widget.indicator.selectedScannerType;
    final isPivotScanner =
        widget.indicator.selectedScannerType?.name.startsWith('pivotPoint') ??
            false;
    final isCandlestickScanner =
        selectedType != null && _candlestickScanners.contains(selectedType);
    final displayableResults = widget.indicator.activeScanResults
        .where((result) => !removedIndices.contains(result.targetIndex))
        .toList();
    return AlertDialog(
      title: Text(
          'Configure "${widget.indicator.selectedScannerType?.displayName}"'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Highlight Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: highlightColor,
              onColorSelected: (color) {
                setState(() {
                  highlightColor = color;
                });
              },
            ),
            if (isPivotScanner) ...[
              const SizedBox(height: 24),
              const Text('Pivot Timeframe'),
              const SizedBox(height: 8),
              DropdownButtonFormField<PivotTimeframe>(
                value: timeframe,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: PivotTimeframe.values.map((frame) {
                  return DropdownMenuItem<PivotTimeframe>(
                    value: frame,
                    child: Text(
                        frame.name[0].toUpperCase() + frame.name.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      timeframe = value;
                    });
                  }
                },
              ),
            ],
            if (isCandlestickScanner) ...[
              const SizedBox(height: 24),
              const Text('Trend Detection'),
              const SizedBox(height: 8),
              DropdownButtonFormField<TrendDetection>(
                value: trendDetection,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: TrendDetection.values.map((trend) {
                  return DropdownMenuItem<TrendDetection>(
                    value: trend,
                    child: Text(trend.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      trendDetection = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scanner Results',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // Add this TextButton to restore removed results
                TextButton(
                  onPressed: () {
                    setState(() {
                      removedIndices.clear();
                    });
                  },
                  child: const Text('Restore All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: displayableResults.isEmpty
                  ? const Center(child: Text('No results found.'))
                  : SingleChildScrollView(
                      child: Column(
                        children: displayableResults.map((result) {
                          final candle =
                              widget.indicator.candles[result.targetIndex];
                          return ListTile(
                            dense: true,
                            title: Text(result.label),
                            subtitle: Text(
                                'Date: ${candle.date.toLocal().toString().split(' ')[0]}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  removedIndices.add(result.targetIndex);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.indicator.highlightColor = highlightColor;
            widget.indicator.trendDetection = trendDetection;
            widget.indicator.timeframe = timeframe;
            widget.indicator.removedResultIndices = removedIndices;
            widget.indicator.updateData(widget.indicator.candles);
            widget.onUpdate(widget.indicator);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
