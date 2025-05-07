import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/highlight_option_chain.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:flutter/material.dart';

Future<HighlightCorrectOptionChainValueTask?> showAllOptionChains({
  required BuildContext context,
  required List<Task> tasks,
}) async {
  final optionChainTasks = tasks.whereType<AddOptionChainTask>().toList();

  if (optionChainTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains available')),
    );
    return null;
  }

  final sourceTask = await showDialog<AddOptionChainTask>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select an Option Chain',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AddOptionChainTask>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: const Text('Select an Option Chain Task'),
                  items: optionChainTasks.map((task) {
                    return DropdownMenuItem<AddOptionChainTask>(
                      value: task,
                      child: Text('Task ID: ${task.optionChainId}'),
                    );
                  }).toList(),
                  onChanged: (selectedTask) {
                    if (selectedTask != null) {
                      Navigator.pop(dialogContext, selectedTask);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (sourceTask == null) return null;
  final highlightTask = tasks
      .whereType<ChooseCorrectOptionValueChainTask>()
      .firstWhere((task) => task.taskId == sourceTask.optionChainId);

  return HighlightCorrectOptionChainValueTask(
      optionChainId: sourceTask.optionChainId,
      correctRowIndex: highlightTask.selectedRowIndex);
}
