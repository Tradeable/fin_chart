import 'package:fin_chart/models/indicators/vwap.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class VwapSettingsDialog extends StatefulWidget {
  final Vwap indicator;
  final Function(Vwap) onUpdate;

  const VwapSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<VwapSettingsDialog> createState() => _VwapSettingsDialogState();
}

class _VwapSettingsDialogState extends State<VwapSettingsDialog> {
  late Color lineColor;
  late double strokeWidth;
  late bool useSessionReset;
  late int sessionStartHour;
  late int sessionStartMinute;
  late double standardDeviations;
  late Color upperBandColor;
  late Color lowerBandColor;
  late bool showBands;

  @override
  void initState() {
    super.initState();
    lineColor = widget.indicator.lineColor;
    strokeWidth = widget.indicator.strokeWidth;
    useSessionReset = widget.indicator.useSessionReset;
    sessionStartHour = widget.indicator.sessionStartHour;
    sessionStartMinute = widget.indicator.sessionStartMinute;
    standardDeviations = widget.indicator.standardDeviations;
    upperBandColor = widget.indicator.upperBandColor;
    lowerBandColor = widget.indicator.lowerBandColor;
    showBands = widget.indicator.showBands;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('VWAP Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            CheckboxListTile(
              title: const Text('Reset VWAP Daily'),
              subtitle: const Text('Reset VWAP calculation at session start'),
              value: useSessionReset,
              onChanged: (value) {
                setState(() {
                  useSessionReset = value ?? true;
                });
              },
            ),
            if (useSessionReset) ...[
              const SizedBox(height: 16),
              const Text('Session Start Time'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: sessionStartHour,
                      isExpanded: true,
                      items: List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text('${index.toString().padLeft(2, '0')}:00'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          sessionStartHour = value ?? 9;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      value: sessionStartMinute,
                      isExpanded: true,
                      items: [0, 15, 30, 45].map((minute) {
                        return DropdownMenuItem(
                          value: minute,
                          child: Text(':${minute.toString().padLeft(2, '0')}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sessionStartMinute = value ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Show Bands'),
              subtitle: const Text('Display standard deviation bands'),
              value: showBands,
              onChanged: (value) {
                setState(() {
                  showBands = value ?? true;
                });
              },
            ),
            if (showBands) ...[
              const SizedBox(height: 16),
              const Text('Standard Deviations'),
              Slider(
                value: standardDeviations,
                min: 0.5,
                max: 3.0,
                divisions: 10,
                label: standardDeviations.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    standardDeviations = value;
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
            // Update the existing indicator's properties
            widget.indicator.lineColor = lineColor;
            widget.indicator.strokeWidth = strokeWidth;
            widget.indicator.useSessionReset = useSessionReset;
            widget.indicator.sessionStartHour = sessionStartHour;
            widget.indicator.sessionStartMinute = sessionStartMinute;
            widget.indicator.standardDeviations = standardDeviations;
            widget.indicator.upperBandColor = upperBandColor;
            widget.indicator.lowerBandColor = lowerBandColor;
            widget.indicator.showBands = showBands;

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
