import 'package:fin_chart/models/indicators/pb.dart';
import 'package:flutter/material.dart';

class PbSettingsDialog extends StatefulWidget {
  final Pb indicator;
  final Function(Pb) onUpdate;

  const PbSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<PbSettingsDialog> createState() => _PbSettingsDialogState();
}

class _PbSettingsDialogState extends State<PbSettingsDialog> {
  late TextEditingController _defaultBookValueController;
  late Color _selectedLineColor;

  @override
  void initState() {
    super.initState();
    _defaultBookValueController = TextEditingController(
      text: widget.indicator.defaultBookValue.toString(),
    );
    _selectedLineColor = widget.indicator.lineColor;
  }

  @override
  void dispose() {
    _defaultBookValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('P/B Indicator Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _defaultBookValueController,
            decoration: const InputDecoration(
              labelText: 'Default Book Value',
              hintText: 'Enter default book value per share',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Line Color: '),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _selectedLineColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Book Value Overrides: ${widget.indicator.bookValueOverrides.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (widget.indicator.bookValueOverrides.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Recent Book Value Changes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...widget.indicator.bookValueOverrides.entries
                .take(3)
                .map((entry) => Text(
                      '${entry.key.toLocal().toString().split(' ')[0]}: ${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _applySettings,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          children: [
            Colors.teal,
            Colors.blue,
            Colors.purple,
            Colors.green,
            Colors.orange,
            Colors.red,
            Colors.brown,
            Colors.cyan,
            Colors.pink,
          ]
              .map((color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLineColor = color;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: _selectedLineColor == color
                              ? Colors.black
                              : Colors.grey,
                          width: _selectedLineColor == color ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _applySettings() {
    final newBookValue = double.tryParse(_defaultBookValueController.text);

    if (newBookValue == null || newBookValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid book value greater than 0'),
        ),
      );
      return;
    }

    // Update the indicator
    widget.indicator.defaultBookValue = newBookValue;
    widget.indicator.lineColor = _selectedLineColor;

    // Trigger recalculation
    widget.indicator.calculatePB();
    widget.indicator.updateYAxisValues();

    widget.onUpdate(widget.indicator);
    Navigator.pop(context);
  }
}
