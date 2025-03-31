import 'package:fin_chart/models/indicators/atr.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class AtrSettingsDialog extends StatefulWidget {
  final Atr indicator;
  final Function(Atr) onUpdate;

  const AtrSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<AtrSettingsDialog> createState() => _AtrSettingsDialogState();
}

class _AtrSettingsDialogState extends State<AtrSettingsDialog> {
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
      title: const Text('ATR Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Period'),
            Slider(
              value: period.toDouble(),
              min: 3.0,
              max: 50.0,
              divisions: 47,
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
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}