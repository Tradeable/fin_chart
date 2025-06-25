import 'package:fin_chart/models/indicators/pe.dart';
import 'package:flutter/material.dart';

class PeSettingsDialog extends StatefulWidget {
  final Pe indicator;
  final Function(Pe) onUpdate;

  const PeSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<PeSettingsDialog> createState() => _PeSettingsDialogState();
}

class _PeSettingsDialogState extends State<PeSettingsDialog> {
  late TextEditingController _defaultEPSController;
  late Color _selectedLineColor;

  @override
  void initState() {
    super.initState();
    _defaultEPSController = TextEditingController(
      text: widget.indicator.defaultEPS.toString(),
    );
    _selectedLineColor = widget.indicator.lineColor;
  }

  @override
  void dispose() {
    _defaultEPSController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('P/E Indicator Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _defaultEPSController,
            decoration: const InputDecoration(
              labelText: 'Default EPS',
              hintText: 'Enter default earnings per share',
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
            'EPS Overrides: ${widget.indicator.epsOverrides.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (widget.indicator.epsOverrides.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Recent EPS Changes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...widget.indicator.epsOverrides.entries
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
            Colors.orange,
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.purple,
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
    final newEPS = double.tryParse(_defaultEPSController.text);

    if (newEPS == null || newEPS <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid EPS value greater than 0'),
        ),
      );
      return;
    }

    // Update the indicator
    widget.indicator.defaultEPS = newEPS;
    widget.indicator.lineColor = _selectedLineColor;

    // Trigger recalculation
    widget.indicator.calculatePE();
    widget.indicator.updateYAxisValues();

    widget.onUpdate(widget.indicator);
    Navigator.pop(context);
  }
}
