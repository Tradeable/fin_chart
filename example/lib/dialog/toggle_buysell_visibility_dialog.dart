import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:flutter/material.dart';

Future<ToggleBuySellVisibilityTask?> showToggleBuySellVisibilityDialog({
  required BuildContext context,
  required List<dynamic> tasks,
  ToggleBuySellVisibilityTask? initialTask,
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
  bool isBuySellVisible = initialTask?.isBuySellVisible ?? false;

  return showDialog<ToggleBuySellVisibilityTask>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('Toggle Buy/Sell Visibility'),
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
                        isBuySellVisible = false;
                      });
                    }
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.2,
              child: SwitchListTile(
                title: const Text('Show Buy/Sell'),
                value: isBuySellVisible,
                onChanged: (newValue) {
                  setState(() {
                    isBuySellVisible = newValue;
                  });
                },
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
                    ToggleBuySellVisibilityTask(
                      optionChainId: selectedOptionChainId,
                      isBuySellVisible: isBuySellVisible,
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
