import 'package:fin_chart/models/indicators/bollinger_bands.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class BollingerBandSettingsDialog extends StatefulWidget {
  final BollingerBands indicator;
  final Function(BollingerBands) onUpdate;

  const BollingerBandSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<BollingerBandSettingsDialog> createState() =>
      _BollingerBandSettingsDialogState();
}

class _BollingerBandSettingsDialogState
    extends State<BollingerBandSettingsDialog> {
  late int period;
  late double multiplier;
  late Color upperBandColor;
  late Color middleBandColor;
  late Color lowerBandColor;
  late int alpha;

  @override
  void initState() {
    super.initState();
    period = widget.indicator.period;
    multiplier = widget.indicator.multiplier;
    upperBandColor = widget.indicator.upperBandColor;
    middleBandColor = widget.indicator.middleBandColor;
    lowerBandColor = widget.indicator.lowerBandColor;
    alpha = widget.indicator.alpha;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bollinger Bands Settings'),
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
            const Text('Standard Deviation Multiplier'),
            Slider(
              value: multiplier,
              min: 1.0,
              max: 4.0,
              divisions: 30,
              label: multiplier.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  multiplier = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Upper Band Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: upperBandColor,
              onColorSelected: (color) {
                setState(() {
                  upperBandColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Middle Band Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: middleBandColor,
              onColorSelected: (color) {
                setState(() {
                  middleBandColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Lower Band Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: lowerBandColor,
              onColorSelected: (color) {
                setState(() {
                  lowerBandColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Fill Transparency'),
            Slider(
              value: alpha.toDouble(),
              min: 0.0,
              max: 255.0,
              divisions: 51,
              label: alpha.toString(),
              onChanged: (value) {
                setState(() {
                  alpha = value.round();
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
            widget.indicator.upperBandColor = upperBandColor;
            widget.indicator.middleBandColor = middleBandColor;
            widget.indicator.lowerBandColor = lowerBandColor;
            widget.indicator.alpha = alpha;
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
