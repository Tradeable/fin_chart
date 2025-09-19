import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/edit_column_visibility.task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_state.dart';
import 'package:flutter/material.dart';

Future<EditColumnVisibilityTask?> showEditColumnVisibilityDialog({
  required BuildContext context,
  required List<dynamic> tasks,
  EditColumnVisibilityTask? initialTask,
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

  return showDialog<EditColumnVisibilityTask>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      List<ColumnConfig> workingColumns = [];

      CreateOptionChainTask? findChain(String id) {
        return tasks
            .whereType<CreateOptionChainTask>()
            .firstWhere((t) => t.optionChainId == id);
      }

      return StatefulBuilder(builder: (context, setState) {
        final chain = findChain(selectedOptionChainId);
        if (chain == null) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Selected option chain not found'),
          );
        }

        final state = rebuildOptionChainState(
          tasks: tasks,
          taskIndex: initialTask != null
              ? tasks.indexOf(initialTask) + 1
              : tasks.length,
          optionChainId: selectedOptionChainId,
        );

        if (workingColumns.isEmpty) {
          workingColumns = [...state.columns];
        }

        return AlertDialog(
          title: Row(
            children: [
              const Text('Edit Column Visibility'),
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
                      final newState = rebuildOptionChainState(
                        tasks: tasks,
                        taskIndex: initialTask != null
                            ? tasks.indexOf(initialTask) + 1
                            : tasks.length,
                        optionChainId: value,
                      );
                      workingColumns = [...newState.columns];
                    });
                  }
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              itemCount: workingColumns.length,
              itemBuilder: (context, index) {
                final col = workingColumns[index];
                return CheckboxListTile(
                  title: Text(col.columnTitle),
                  value: col.isColumnVisible,
                  onChanged: (val) {
                    setState(() {
                      workingColumns[index] =
                          ColumnConfig.fromJson(col.toJson())
                            ..isColumnVisible = val ?? false;
                    });
                  },
                );
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
                  EditColumnVisibilityTask(
                    optionChainId: selectedOptionChainId,
                    updatedColumns: List.from(workingColumns),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
