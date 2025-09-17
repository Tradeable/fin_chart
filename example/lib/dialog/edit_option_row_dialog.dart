import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/edit_option_row_task.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
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
    builder: (BuildContext context) {
      final Map<int, OptionData> editedRows = {};
      List<OptionData> workingData = [];

      CreateOptionChainTask? findChain(String id) {
        final createTasks = tasks.whereType<CreateOptionChainTask>();
        try {
          return createTasks.firstWhere((t) => t.optionChainId == id);
        } catch (_) {
          return null;
        }
      }

      return StatefulBuilder(builder: (context, setState) {
        final chain = findChain(selectedOptionChainId);
        if (chain == null) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Selected option chain not found'),
          );
        }

        if (workingData.isEmpty) {
          workingData = [...chain.data];
        }

        void openEditForm(OptionData row, int rowIndex) async {
          final result = await _showRowForm(context: context, row: row);
          if (result != null) {
            setState(() {
              editedRows[rowIndex] = result;
              workingData[rowIndex] = result;
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
                      editedRows.clear();
                      workingData = [...?findChain(value)?.data];
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
                openEditForm(workingData[rowIndex], rowIndex);
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
}) async {
  final strikeCtrl = TextEditingController(text: row.strike.toString());
  final callOiCtrl = TextEditingController(text: row.callOi.toString());
  final callPremCtrl = TextEditingController(text: row.callPremium.toString());
  final putOiCtrl = TextEditingController(text: row.putOi.toString());
  final putPremCtrl = TextEditingController(text: row.putPremium.toString());

  return showDialog<OptionData>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Row Values'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _numField(label: 'Strike', controller: strikeCtrl),
              _numField(label: 'Call OI', controller: callOiCtrl, isInt: true),
              _numField(label: 'Call Premium', controller: callPremCtrl),
              _numField(label: 'Put OI', controller: putOiCtrl, isInt: true),
              _numField(label: 'Put Premium', controller: putPremCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final updated = OptionData(
                  strike: double.parse(strikeCtrl.text),
                  callOi: int.parse(callOiCtrl.text),
                  callPremium: double.parse(callPremCtrl.text),
                  putOi: int.parse(putOiCtrl.text),
                  putPremium: double.parse(putPremCtrl.text),
                  callDelta: row.callDelta,
                  callGamma: row.callGamma,
                  callVega: row.callVega,
                  callTheta: row.callTheta,
                  callIV: row.callIV,
                  putDelta: row.putDelta,
                  putGamma: row.putGamma,
                  putVega: row.putVega,
                  putTheta: row.putTheta,
                  putIV: row.putIV,
                  callVolume: row.callVolume,
                  putVolume: row.putVolume,
                );
                Navigator.pop(context, updated);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid numbers')),
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

Widget _numField({
  required String label,
  required TextEditingController controller,
  bool isInt = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
  );
}
