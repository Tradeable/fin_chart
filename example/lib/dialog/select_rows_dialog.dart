import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<SelectRowTask?> showSelectRowDialog({
  required BuildContext context,
  required List<dynamic> tasks,
  SelectRowTask? initialTask,
}) async {
  final addOptionChains = tasks.whereType<CreateOptionChainTask>().toList();
  if (addOptionChains.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains found. Add one first.')),
    );
    return null;
  }

  String selectedOptionChainId =
      initialTask?.optionChainId ?? addOptionChains.first.optionChainId;
  List<int> selectedRows = initialTask?.selectedRowIndexes ?? [];

  return showDialog<SelectRowTask>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final chainTask = addOptionChains
              .firstWhere((t) => t.optionChainId == selectedOptionChainId);

          return AlertDialog(
            title: Row(
              children: [
                const Text('Select Rows'),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedOptionChainId,
                  items: addOptionChains
                      .map((c) => DropdownMenuItem(
                            value: c.optionChainId,
                            child: Text(c.optionChainId),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedOptionChainId = value;
                        selectedRows = [];
                      });
                    }
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: PreviewScreen.from(
                key: UniqueKey(),
                isEditorMode: false,
                maxSelectableRows: chainTask.settings?.maxSelectableRows,
                task: chainTask,
                selectedRowIndex: selectedRows,
                onRowEditRequested: null,
                onBuySellSelected: (rowIndex, _) {
                  setState(() {
                    if (!selectedRows.contains(rowIndex)) {
                      if (chainTask.settings?.maxSelectableRows == 1) {
                        selectedRows = [rowIndex];
                      } else if (chainTask.settings?.maxSelectableRows !=
                              null &&
                          selectedRows.length <
                              chainTask.settings!.maxSelectableRows!) {
                        selectedRows.add(rowIndex);
                      } else if (chainTask.settings?.maxSelectableRows ==
                          null) {
                        selectedRows.add(rowIndex);
                      }
                    } else {
                      selectedRows.remove(rowIndex);
                    }
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
                onPressed: selectedRows.isEmpty
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          SelectRowTask(
                            optionChainId: selectedOptionChainId,
                            selectedRowIndexes: selectedRows,
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
