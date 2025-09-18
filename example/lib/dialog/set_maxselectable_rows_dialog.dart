import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:flutter/material.dart';

Future<SetMaxSelectableRowsTask?> showSetMaxSelectableRowsDialog({
  required BuildContext context,
  required List<dynamic> tasks,
  SetMaxSelectableRowsTask? initialTask,
}) async {
  final addOptionChains = tasks.whereType<AddOptionChainTask>().toList();
  if (addOptionChains.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains found. Add one first.')),
    );
    return null;
  }

  String selectedOptionChainId =
      initialTask?.optionChainId ?? addOptionChains.first.taskId;
  int? maxRows = initialTask?.maxSelectableRows;

  return showDialog<SetMaxSelectableRowsTask>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('Set Max Selectable Rows'),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedOptionChainId,
                  items: addOptionChains
                      .map((c) => DropdownMenuItem(
                            value: c.taskId,
                            child: Text(c.taskId),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedOptionChainId = value;
                        maxRows = null;
                      });
                    }
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Selectable Rows',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: maxRows?.toString() ?? '',
                    ),
                    onChanged: (val) {
                      setState(() {
                        maxRows = int.tryParse(val);
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    SetMaxSelectableRowsTask(
                      optionChainId: selectedOptionChainId,
                      maxSelectableRows: maxRows,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
