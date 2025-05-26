import 'package:fin_chart/fin_chart.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/task.dart';

Future<MoveTabTask?> editMoveTabDialog(
    {required BuildContext context,
    required MoveTabTask task,
    required List<Task> tasks}) async {
  final addTabTasks = tasks.whereType<AddTabTask>().toList();
  final availableTabs = [
    AddTabTask(tabTitle: "Chart", taskId: "chart"),
    ...addTabTasks,
  ];

  if (availableTabs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No tabs available')),
    );
    return null;
  }

  AddTabTask? selectedTask;

  return showDialog<MoveTabTask>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Move To Tab'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: availableTabs.map((tab) {
                return RadioListTile<AddTabTask>(
                  title: Text(tab.tabTitle),
                  value: tab,
                  groupValue: selectedTask,
                  onChanged: (AddTabTask? value) {
                    setState(() {
                      selectedTask = value;
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedTask != null) {
                Navigator.of(context).pop(
                  MoveTabTask(tabTaskID: selectedTask!.taskId),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
