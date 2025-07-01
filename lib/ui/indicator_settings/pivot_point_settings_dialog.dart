import 'package:fin_chart/models/indicators/pivot_point.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class PivotPointSettingsDialog extends StatefulWidget {
  final PivotPoint indicator;
  final Function(PivotPoint) onUpdate;

  const PivotPointSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<PivotPointSettingsDialog> createState() =>
      _PivotPointSettingsDialogState();
}

class _PivotPointSettingsDialogState extends State<PivotPointSettingsDialog> {
  late PivotTimeframe timeframe;
  late Color pivotColor;
  late Color resistanceColor;
  late Color supportColor;
  late bool showLabels;

  @override
  void initState() {
    super.initState();
    timeframe = widget.indicator.timeframe;
    pivotColor = widget.indicator.pivotColor;
    resistanceColor = widget.indicator.resistanceColor;
    supportColor = widget.indicator.supportColor;
    showLabels = widget.indicator.showLabels;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pivot Point Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeframe'),
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
                  child: Text(frame.name.toUpperCase()),
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
            const SizedBox(height: 16),
            const Text('Pivot Point Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: pivotColor,
              onColorSelected: (color) {
                setState(() {
                  pivotColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Resistance Levels Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: resistanceColor,
              onColorSelected: (color) {
                setState(() {
                  resistanceColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Support Levels Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: supportColor,
              onColorSelected: (color) {
                setState(() {
                  supportColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: showLabels,
                  onChanged: (value) {
                    setState(() {
                      showLabels = value ?? true;
                    });
                  },
                ),
                const Text('Show Labels'),
              ],
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
            widget.indicator.timeframe = timeframe;
            widget.indicator.pivotColor = pivotColor;
            widget.indicator.resistanceColor = resistanceColor;
            widget.indicator.supportColor = supportColor;
            widget.indicator.showLabels = showLabels;
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
