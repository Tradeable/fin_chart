import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/enums/trend_detection.dart';
import 'package:fin_chart/models/indicators/scanner_indicator.dart';
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

  @override
  void initState() {
    super.initState();
    highlightColor = widget.indicator.highlightColor;
    trendDetection = widget.indicator.trendDetection;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Configure "${widget.indicator.selectedScannerType?.instance.name}"'),
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
            widget.onUpdate(widget.indicator);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
