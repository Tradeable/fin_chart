import 'package:fin_chart/fin_chart.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/task.dart';

Future<RemoveTabTask?> removeAddedTab({
  required BuildContext context,
  required List<Task> tasks,
}) async {
  final addedTabs = tasks.whereType<AddTabTask>().toList();
  final removedTabs = tasks.whereType<RemoveTabTask>().map((e) => e.tabTitle).toSet();
  final availableTabs =
      addedTabs.where((tab) => !removedTabs.contains(tab.tabTitle)).toList();

  if (availableTabs.isEmpty) return null;

  AddTabTask? selectedTask;

  return showDialog<RemoveTabTask>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Remove Tab',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableTabs.length,
                    itemBuilder: (context, index) {
                      final tab = availableTabs[index];
                      return Column(
                        children: [
                          RadioListTile<AddTabTask>(
                            title: Text(tab.tabTitle),
                            value: tab,
                            groupValue: selectedTask,
                            onChanged: (value) {
                              selectedTask = value;
                              (context as Element).markNeedsBuild();
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (selectedTask == null) return;
                        Navigator.of(context).pop(
                          RemoveTabTask(tabTitle: selectedTask!.tabTitle),
                        );
                      },
                      child: const Text('Remove'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
