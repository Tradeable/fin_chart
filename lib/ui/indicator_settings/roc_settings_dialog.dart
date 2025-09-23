import 'package:fin_chart/models/indicators/roc.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class RocSettingsDialog extends StatefulWidget {
  final Roc indicator;
  final Function(Roc) onUpdate;

  const RocSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<RocSettingsDialog> createState() => _RocSettingsDialogState();
}

class _RocSettingsDialogState extends State<RocSettingsDialog> {
  late int period;
  late Color lineColor;

  @override
  void initState() {
    super.initState();
    period = widget.indicator.period;
    lineColor = widget.indicator.lineColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate of Change (ROC) Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Period'),
            Slider(
              value: period.toDouble(),
              min: 2.0,
              max: 50.0,
              divisions: 48,
              label: period.toString(),
              onChanged: (value) {
                setState(() {
                  period = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: lineColor,
              onColorSelected: (color) {
                setState(() {
                  lineColor = color;
                });
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
            widget.indicator.period = period;
            widget.indicator.lineColor = lineColor;
            widget.onUpdate(widget.indicator);
            widget.indicator.updateData(widget.indicator.candles);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
