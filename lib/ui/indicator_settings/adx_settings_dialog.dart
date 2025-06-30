import 'package:fin_chart/models/indicators/adx.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class AdxSettingsDialog extends StatefulWidget {
  final Adx indicator;
  final Function(Adx) onUpdate;

  const AdxSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<AdxSettingsDialog> createState() => _AdxSettingsDialogState();
}

class _AdxSettingsDialogState extends State<AdxSettingsDialog> {
  late int period;
  late Color adxLineColor;
  late Color diPlusColor;
  late Color diMinusColor;
  late bool showDiPlus;
  late bool showDiMinus;

  @override
  void initState() {
    super.initState();
    period = widget.indicator.period;
    adxLineColor = widget.indicator.adxLineColor;
    diPlusColor = widget.indicator.diPlusColor;
    diMinusColor = widget.indicator.diMinusColor;
    showDiPlus = widget.indicator.showDiPlus;
    showDiMinus = widget.indicator.showDiMinus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ADX Settings'),
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
            const Text('ADX Line Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: adxLineColor,
              onColorSelected: (color) {
                setState(() {
                  adxLineColor = color;
                });
              },
            ),
            const SizedBox(height: 16),

            // +DI Controls with visibility toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('+DMI Line'),
                Switch(
                  value: showDiPlus,
                  onChanged: (value) {
                    setState(() {
                      showDiPlus = value;
                    });
                  },
                ),
              ],
            ),
            // Only show color picker if +DI is visible
            if (showDiPlus) ...[
              const SizedBox(height: 8),
              ColorPickerWidget(
                selectedColor: diPlusColor,
                onColorSelected: (color) {
                  setState(() {
                    diPlusColor = color;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),

            // -DI Controls with visibility toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('-DMI Line'),
                Switch(
                  value: showDiMinus,
                  onChanged: (value) {
                    setState(() {
                      showDiMinus = value;
                    });
                  },
                ),
              ],
            ),
            // Only show color picker if -DI is visible
            if (showDiMinus) ...[
              const SizedBox(height: 8),
              ColorPickerWidget(
                selectedColor: diMinusColor,
                onColorSelected: (color) {
                  setState(() {
                    diMinusColor = color;
                  });
                },
              ),
            ],
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
            widget.indicator.adxLineColor = adxLineColor;
            widget.indicator.diPlusColor = diPlusColor;
            widget.indicator.diMinusColor = diMinusColor;
            widget.indicator.showDiPlus = showDiPlus;
            widget.indicator.showDiMinus = showDiMinus;
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
