import 'package:fin_chart/models/indicators/stochastic.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class StochasticSettingsDialog extends StatefulWidget {
  final Stochastic indicator;
  final Function(Stochastic) onUpdate;

  const StochasticSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<StochasticSettingsDialog> createState() =>
      _StochasticSettingsDialogState();
}

class _StochasticSettingsDialogState extends State<StochasticSettingsDialog> {
  late int kPeriod;
  late int dPeriod;
  late Color kLineColor;
  late Color dLineColor;

  @override
  void initState() {
    super.initState();
    kPeriod = widget.indicator.kPeriod;
    dPeriod = widget.indicator.dPeriod;
    kLineColor = widget.indicator.kLineColor;
    dLineColor = widget.indicator.dLineColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stochastic Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('%K Period'),
            Slider(
              value: kPeriod.toDouble(),
              min: 3.0,
              max: 50.0,
              divisions: 47,
              label: kPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  kPeriod = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('%D Period'),
            Slider(
              value: dPeriod.toDouble(),
              min: 1.0,
              max: 20.0,
              divisions: 19,
              label: dPeriod.toString(),
              onChanged: (value) {
                setState(() {
                  dPeriod = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('%K Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: kLineColor,
              onColorSelected: (color) {
                setState(() {
                  kLineColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('%D Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: dLineColor,
              onColorSelected: (color) {
                setState(() {
                  dLineColor = color;
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
            widget.indicator.kPeriod = kPeriod;
            widget.indicator.dPeriod = dPeriod;
            widget.indicator.kLineColor = kLineColor;
            widget.indicator.dLineColor = dLineColor;
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
