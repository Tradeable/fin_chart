import 'package:fin_chart/models/indicators/rsi.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class RsiSettingsDialog extends StatefulWidget {
  final Rsi indicator;
  final Function(Rsi) onUpdate;

  const RsiSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<RsiSettingsDialog> createState() => _RsiSettingsDialogState();
}

class _RsiSettingsDialogState extends State<RsiSettingsDialog> {
  late int rsiPeriod;
  late int rsiMaPeriod;
  late Color rsiColor;
  late Color rsiMaColor;

  @override
  void initState() {
    super.initState();
    rsiPeriod = widget.indicator.rsiPeriod;
    rsiMaPeriod = widget.indicator.rsiMaPeriod;
    rsiColor = widget.indicator.rsiColor;
    rsiMaColor = widget.indicator.rsiMaColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('RSI Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RSI Period'),
            Slider(
              value: rsiPeriod.toDouble(),
              min: 2.0,
              max: 50.0,
              divisions: 48,
              label: rsiPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  rsiPeriod = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('RSI MA Period'),
            Slider(
              value: rsiMaPeriod.toDouble(),
              min: 2.0,
              max: 30.0,
              divisions: 28,
              label: rsiMaPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  rsiMaPeriod = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('RSI Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: rsiColor,
              onColorSelected: (color) {
                setState(() {
                  rsiColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('RSI MA Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: rsiMaColor,
              onColorSelected: (color) {
                setState(() {
                  rsiMaColor = color;
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
            widget.indicator.rsiPeriod = rsiPeriod;
            widget.indicator.rsiMaPeriod = rsiMaPeriod;
            widget.indicator.rsiColor = rsiColor;
            widget.indicator.rsiMaColor = rsiMaColor;
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
