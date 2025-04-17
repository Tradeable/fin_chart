import 'package:fin_chart/models/layers/anchor_text.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class AnchorTextSettingsDialog extends StatefulWidget {
  final AnchorText layer;
  final Function(AnchorText) onUpdate;

  const AnchorTextSettingsDialog({
    super.key,
    required this.layer,
    required this.onUpdate,
  });

  @override
  State<AnchorTextSettingsDialog> createState() =>
      _AnchorTextSettingsDialogState();
}

class _AnchorTextSettingsDialogState extends State<AnchorTextSettingsDialog> {
  late Color selectedTextColor;
  late Color selectedBorderColor;
  late Color selectedBackgroundColor;
  late String label;
  late double borderWidth;

  @override
  void initState() {
    super.initState();
    selectedTextColor = widget.layer.textColor;
    selectedBorderColor = widget.layer.borderColor;
    selectedBackgroundColor = widget.layer.backgroundColor;
    label = widget.layer.label;
    borderWidth = widget.layer.borderWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Anchor Text Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text Label'),
            TextField(
              controller: TextEditingController(text: label),
              onChanged: (value) {
                setState(() {
                  label = value;
                });
              },
              decoration: const InputDecoration(hintText: 'Enter text'),
            ),
            const SizedBox(height: 16),
            const Text('Text Color'),
            ColorPickerWidget(
              selectedColor: selectedTextColor,
              onColorSelected: (color) {
                setState(() {
                  selectedTextColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Background Color'),
            ColorPickerWidget(
              selectedColor: selectedBackgroundColor,
              onColorSelected: (color) {
                setState(() {
                  selectedBackgroundColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Border Color'),
            ColorPickerWidget(
              selectedColor: selectedBorderColor,
              onColorSelected: (color) {
                setState(() {
                  selectedBorderColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Border Width'),
            Slider(
              value: borderWidth,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: borderWidth.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  borderWidth = value;
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
            widget.layer.label = label;
            widget.layer.textColor = selectedTextColor;
            widget.layer.backgroundColor = selectedBackgroundColor;
            widget.layer.borderColor = selectedBorderColor;
            widget.layer.borderWidth = borderWidth;
            widget.onUpdate(widget.layer);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
