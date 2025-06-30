import 'package:fin_chart/models/indicators/macd.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class MacdSettingsDialog extends StatefulWidget {
  final Macd indicator;
  final Function(Macd) onUpdate;

  const MacdSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<MacdSettingsDialog> createState() => _MacdSettingsDialogState();
}

class _MacdSettingsDialogState extends State<MacdSettingsDialog> {
  late int fastPeriod;
  late int slowPeriod;
  late int signalPeriod;
  late Color macdLineColor;
  late Color signalLineColor;
  late Color posHistogramColor;
  late Color negHistogramColor;

  @override
  void initState() {
    super.initState();
    fastPeriod = widget.indicator.fastPeriod;
    slowPeriod = widget.indicator.slowPeriod;
    signalPeriod = widget.indicator.signalPeriod;
    macdLineColor = widget.indicator.macdLineColor;
    signalLineColor = widget.indicator.signalLineColor;
    posHistogramColor = widget.indicator.posHistogramColor;
    negHistogramColor = widget.indicator.negHistogramColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('MACD Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fast Period'),
            Slider(
              value: fastPeriod.toDouble(),
              min: 3.0,
              max: 30.0,
              divisions: 27,
              label: fastPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  fastPeriod = value.round();
                  // Ensure fast is less than slow
                  if (fastPeriod >= slowPeriod) {
                    slowPeriod = fastPeriod + 1;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Slow Period'),
            Slider(
              value: slowPeriod.toDouble(),
              min: 4.0,
              max: 50.0,
              divisions: 46,
              label: slowPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  slowPeriod = value.round();
                  // Ensure slow is greater than fast
                  if (slowPeriod <= fastPeriod) {
                    fastPeriod = slowPeriod - 1;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Signal Period'),
            Slider(
              value: signalPeriod.toDouble(),
              min: 3.0,
              max: 25.0,
              divisions: 22,
              label: signalPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  signalPeriod = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('MACD Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: macdLineColor,
              onColorSelected: (color) {
                setState(() {
                  macdLineColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Signal Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: signalLineColor,
              onColorSelected: (color) {
                setState(() {
                  signalLineColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Positive Histogram Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: posHistogramColor,
              onColorSelected: (color) {
                setState(() {
                  posHistogramColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Negative Histogram Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: negHistogramColor,
              onColorSelected: (color) {
                setState(() {
                  negHistogramColor = color;
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
            widget.indicator.fastPeriod = fastPeriod;
            widget.indicator.slowPeriod = slowPeriod;
            widget.indicator.signalPeriod = signalPeriod;
            widget.indicator.macdLineColor = macdLineColor;
            widget.indicator.signalLineColor = signalLineColor;
            widget.indicator.posHistogramColor = posHistogramColor;
            widget.indicator.negHistogramColor = negHistogramColor;
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
