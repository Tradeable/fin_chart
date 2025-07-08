import 'package:fin_chart/models/indicators/ev_ebitda.dart';
import 'package:fin_chart/ui/color_picker_widget.dart';
import 'package:flutter/material.dart';

class EvEbitdaSettingsDialog extends StatefulWidget {
  final EvEbitda indicator;
  final Function(EvEbitda) onUpdate;

  const EvEbitdaSettingsDialog({
    super.key,
    required this.indicator,
    required this.onUpdate,
  });

  @override
  State<EvEbitdaSettingsDialog> createState() => _EvEbitdaSettingsDialogState();
}

class _EvEbitdaSettingsDialogState extends State<EvEbitdaSettingsDialog> {
  late Color lineColor;
  late List<EvEbitdaPoint> points;

  @override
  void initState() {
    super.initState();
    lineColor = widget.indicator.lineColor;
    points = List.from(widget.indicator.points);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('EV/EBITDA Settings'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('EV/EBITDA Points',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _addPoint,
                    child: const Text('Add Point'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: points.isEmpty
                    ? const Center(child: Text('No points added'))
                    : ListView.builder(
                        itemCount: points.length,
                        itemBuilder: (context, index) {
                          final point = points[index];
                          return ListTile(
                            title: Text(
                                point.date.toLocal().toString().split(' ')[0]),
                            subtitle: Text(
                                'EV/EBITDA: ${point.value.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removePoint(index),
                            ),
                            onTap: () => _editPoint(index),
                          );
                        },
                      ),
              ),
            ],
          ),
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
            widget.indicator.lineColor = lineColor;
            widget.indicator.points = points;
            widget.onUpdate(widget.indicator);
            widget.indicator.updateData(widget.indicator.candles);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _addPoint() {
    _showPointDialog();
  }

  void _editPoint(int index) {
    _showPointDialog(existingPoint: points[index], index: index);
  }

  void _removePoint(int index) {
    setState(() {
      points.removeAt(index);
    });
  }

  void _showPointDialog({EvEbitdaPoint? existingPoint, int? index}) {
    DateTime selectedDate = existingPoint?.date ?? DateTime.now();
    double value = existingPoint?.value ?? 10.0;

    final dateController = TextEditingController(
      text: selectedDate.toLocal().toString().split(' ')[0],
    );
    final valueController = TextEditingController(
      text: value.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingPoint == null
            ? 'Add EV/EBITDA Point'
            : 'Edit EV/EBITDA Point'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                hintText: '2024-01-15',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  selectedDate = date;
                  dateController.text = date.toLocal().toString().split(' ')[0];
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'EV/EBITDA Value',
                hintText: '15.5',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                value = double.tryParse(val) ?? value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPoint = EvEbitdaPoint(date: selectedDate, value: value);
              setState(() {
                if (index != null) {
                  points[index] = newPoint;
                } else {
                  points.add(newPoint);
                }
                // Sort points by date
                points.sort((a, b) => a.date.compareTo(b.date));
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
