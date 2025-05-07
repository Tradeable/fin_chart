import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/highlight_option_chain.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<ChooseCorrectOptionValueChainTask?> showOptionChainById({
  required BuildContext context,
  required List<Task> tasks,
  ChooseCorrectOptionValueChainTask? initialTask,
}) async {
  AddOptionChainTask? sourceTask;

  if (initialTask != null) {
    try {
      sourceTask = tasks.whereType<AddOptionChainTask>().firstWhere(
            (task) => task.optionChainId == initialTask.taskId,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source option chain not found')),
      );
      return null;
    }
  } else {
    final optionChainTasks = tasks.whereType<AddOptionChainTask>().toList();

    if (optionChainTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No option chains available')),
      );
      return null;
    }

    sourceTask = await showDialog<AddOptionChainTask>(
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
  }

  final previewKey = GlobalKey<PreviewScreenState>();

  int? selectedRowIndex = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Builder(
              builder: (contextInside) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (initialTask != null) {
                    previewKey.currentState
                        ?.chooseRow(initialTask.selectedRowIndex);
                  }
                });

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PreviewScreen(
                          key: previewKey,
                          previewData: PreviewData(
                              optionData: sourceTask!.data,
                              columns: sourceTask.columns,
                              visibility: sourceTask.visibility),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final selectedIndex =
                                  previewKey.currentState?.getCorrectRowIndex();
                              if (selectedIndex != null) {
                                Navigator.pop(dialogContext, selectedIndex);
                              } else {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text('Please select a row')),
                                );
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      });

  if (selectedRowIndex != null) {
    return ChooseCorrectOptionValueChainTask(
      taskId: sourceTask.optionChainId,
      selectedRowIndex: selectedRowIndex,
    );
  }
  return null;
}
