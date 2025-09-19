import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/edit_option_row_task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/option_chain_state.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<EditOptionRowTask?> showEditOptionRowDialog({
  required BuildContext context,
  required List<dynamic> tasks,
  EditOptionRowTask? initialTask,
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

  return showDialog<EditOptionRowTask>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final Map<int, OptionData> editedRows = {};
      List<OptionData> workingData = [];

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

        if (workingData.isEmpty) {
          workingData = [...state.data];
        }

        void openEditForm(
            OptionData row, int rowIndex, List<ColumnConfig> columns) async {
          final result = await _showRowForm(
            context: context,
            row: row,
            columns: columns,
          );
          if (result != null) {
            setState(() {
              workingData[rowIndex] = result;
              editedRows[rowIndex] = result;
            });
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              const Text('Edit Option Row'),
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
                      editedRows.clear();
                      workingData = [...newState.data];
                    });
                  }
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.65,
            child: PreviewScreen.from(
              key: ValueKey('$selectedOptionChainId-${workingData.hashCode}'),
              task: CreateOptionChainTask(
                optionChainId: chain.optionChainId,
                strikePrice: chain.strikePrice,
                expiryDate: chain.expiryDate,
                data: workingData,
                columns: chain.columns,
                visibility: chain.visibility,
                settings: chain.settings,
                interval: chain.interval,
              ),
              isEditorMode: true,
              onRowEditRequested: (rowIndex) {
                openEditForm(workingData[rowIndex], rowIndex, state.columns);
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
                if (editedRows.isNotEmpty) {
                  Navigator.pop(
                    context,
                    EditOptionRowTask(
                      optionChainId: selectedOptionChainId,
                      rowIndex: editedRows.keys.first,
                      updatedRow: editedRows.values.first,
                    ),
                  );
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}

Future<OptionData?> _showRowForm({
  required BuildContext context,
  required OptionData row,
  required List<ColumnConfig> columns,
}) async {
  final visibleCols =
      columns.where((c) => c.isColumnVisible).map((c) => c.columnType).toList();

  final fullMap = row.toEditableMap();
  final filteredMap = {
    for (final col in visibleCols) col.name: fullMap[col.name],
  };

  final controllers = <String, TextEditingController>{};
  filteredMap.forEach((k, v) {
    controllers[k] = TextEditingController(text: v.toString());
  });

  return showDialog<OptionData>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Edit Row'),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.6,
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: ListView(
            children: filteredMap.keys.map((key) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: controllers[key],
                  decoration: InputDecoration(labelText: key),
                  keyboardType: TextInputType.number,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedMap = Map<String, dynamic>.from(fullMap);
              for (var key in filteredMap.keys) {
                final val = controllers[key]!.text;
                updatedMap[key] =
                    double.tryParse(val) ?? int.tryParse(val) ?? 0;
              }
              Navigator.pop(ctx, row.copyWithMap(updatedMap));
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
