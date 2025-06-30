import 'package:fin_chart/models/indicators/supertrend.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class SupertrendSettingsDialog extends StatefulWidget {
  final Supertrend indicator;
  final Function(Supertrend) onUpdate;

  const SupertrendSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<SupertrendSettingsDialog> createState() =>
      _SupertrendSettingsDialogState();
}

class _SupertrendSettingsDialogState extends State<SupertrendSettingsDialog> {
  late int period;
  late double multiplier;
  late Color uptrendColor;
  late Color downtrendColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState();
    period = widget.indicator.period;
    multiplier = widget.indicator.multiplier;
    uptrendColor = widget.indicator.uptrendColor;
    downtrendColor = widget.indicator.downtrendColor;
    strokeWidth = widget.indicator.strokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supertrend Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Period'),
            Slider(
              value: period.toDouble(),
              min: 5.0,
              max: 50.0,
              divisions: 45,
              label: period.toString(),
              onChanged: (value) {
                setState(() {
                  period = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Multiplier'),
            Slider(
              value: multiplier,
              min: 1.0,
              max: 5.0,
              divisions: 40,
              label: multiplier.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  multiplier = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Line Width'),
            Slider(
              value: strokeWidth,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: strokeWidth.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Uptrend Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: uptrendColor,
              onColorSelected: (color) {
                setState(() {
                  uptrendColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Downtrend Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: downtrendColor,
              onColorSelected: (color) {
                setState(() {
                  downtrendColor = color;
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
            widget.indicator.multiplier = multiplier;
            widget.indicator.uptrendColor = uptrendColor;
            widget.indicator.downtrendColor = downtrendColor;
            widget.indicator.strokeWidth = strokeWidth;
            widget.onUpdate(widget.indicator);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
