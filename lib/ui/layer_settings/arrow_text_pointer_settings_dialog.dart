import 'package:fin_chart/models/layers/arrow_text_pointer.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class ArrowTextPointerSettingsDialog extends StatefulWidget {
  final ArrowTextPointer layer;
  final Function(ArrowTextPointer) onUpdate;

  const ArrowTextPointerSettingsDialog({
    super.key,
    required this.layer,
    required this.onUpdate,
  });

  @override
  State<ArrowTextPointerSettingsDialog> createState() =>
      _ArrowTextPointerSettingsDialogState();
}

class _ArrowTextPointerSettingsDialogState
    extends State<ArrowTextPointerSettingsDialog> {
  late Color selectedColor;
  late double strokeWidth;
  late bool isPointingUp;
  late String label;
  late TextAlignPosition textAlignment;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.layer.color;
    isPointingUp = widget.layer.isPointingDown;
    label = widget.layer.label;
    textAlignment = widget.layer.textAlignment;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Arrow Text Pointer Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Arrow Color'),
            const SizedBox(height: 8),
            ColorPickerWidget(
              selectedColor: selectedColor,
              onColorSelected: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Arrow Direction'),
            SwitchListTile(
              title: Text(isPointingUp
                  ? 'Arrow Direction: Downward ↓'
                  : 'Arrow Direction: Upward ↑'),
              value: isPointingUp,
              onChanged: (value) {
                setState(() {
                  isPointingUp = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Text Alignment'),
            DropdownButton<TextAlignPosition>(
              value: textAlignment,
              onChanged: (value) {
                setState(() {
                  textAlignment = value!;
                });
              },
              items: TextAlignPosition.values
                  .map<DropdownMenuItem<TextAlignPosition>>(
                (TextAlignPosition value) {
                  return DropdownMenuItem<TextAlignPosition>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 16),
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
            widget.layer.color = selectedColor;
            widget.layer.isPointingDown = isPointingUp;
            widget.layer.label = label;
            widget.layer.textAlignment = textAlignment;
            widget.onUpdate(widget.layer);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
