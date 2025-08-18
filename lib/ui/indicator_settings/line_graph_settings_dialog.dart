import 'package:fin_chart/models/indicators/line_graph.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class LineGraphSettingsDialog extends StatefulWidget {
  final LineGraph indicator;
  final Function(LineGraph) onUpdate;

  const LineGraphSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<LineGraphSettingsDialog> createState() =>
      _LineGraphSettingsDialogState();
}

class _LineGraphSettingsDialogState extends State<LineGraphSettingsDialog> {
  late Color selectedColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.indicator.lineColor;
    strokeWidth = widget.indicator.strokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Line Graph Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: selectedColor,
              onColorSelected: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Line Thickness'),
            Slider(
              value: strokeWidth,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: strokeWidth.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
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
            widget.indicator.lineColor = selectedColor;
            widget.indicator.strokeWidth = strokeWidth;
            widget.onUpdate(widget.indicator);
            // No need to call updateData as this is just a visual change
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
