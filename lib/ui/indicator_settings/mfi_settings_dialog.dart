// FILE: lib\ui\indicator_settings\mfi_settings_dialog.dart
import 'package:fin_chart/models/indicators/mfi.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class MfiSettingsDialog extends StatefulWidget {
  final Mfi indicator;
  final Function(Mfi) onUpdate;

  const MfiSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<MfiSettingsDialog> createState() => _MfiSettingsDialogState();
}

class _MfiSettingsDialogState extends State<MfiSettingsDialog> {
  late int period;
  late Color lineColor;
  late Color overboughtColor;
  late Color oversoldColor;
  late double overboughtThreshold;
  late double oversoldThreshold;

  @override
  void initState() {
    super.initState();
    period = widget.indicator.period;
    lineColor = widget.indicator.lineColor;
    overboughtColor = widget.indicator.overboughtColor;
    oversoldColor = widget.indicator.oversoldColor;
    overboughtThreshold = widget.indicator.overboughtThreshold;
    oversoldThreshold = widget.indicator.oversoldThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Money Flow Index Settings'),
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
            const Text('Overbought Threshold'),
            Slider(
              value: overboughtThreshold,
              min: 60.0,
              max: 95.0,
              divisions: 35,
              label: overboughtThreshold.round().toString(),
              onChanged: (value) {
                setState(() {
                  overboughtThreshold = value.roundToDouble();
                  if (overboughtThreshold <= oversoldThreshold + 10) {
                    overboughtThreshold = oversoldThreshold + 10;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Oversold Threshold'),
            Slider(
              value: oversoldThreshold,
              min: 5.0,
              max: 40.0,
              divisions: 35,
              label: oversoldThreshold.round().toString(),
              onChanged: (value) {
                setState(() {
                  oversoldThreshold = value.roundToDouble();
                  if (oversoldThreshold >= overboughtThreshold - 10) {
                    oversoldThreshold = overboughtThreshold - 10;
                  }
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
            const SizedBox(height: 16),
            const Text('Overbought Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: overboughtColor,
              onColorSelected: (color) {
                setState(() {
                  overboughtColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Oversold Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: oversoldColor,
              onColorSelected: (color) {
                setState(() {
                  oversoldColor = color;
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
            widget.indicator.overboughtColor = overboughtColor;
            widget.indicator.oversoldColor = oversoldColor;
            widget.indicator.overboughtThreshold = overboughtThreshold;
            widget.indicator.oversoldThreshold = oversoldThreshold;
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
