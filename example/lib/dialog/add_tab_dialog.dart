import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';
import 'package:fin_chart/models/tasks/table_task.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';

Future<AddTabTask?> addTabDialog({
  required BuildContext context,
  required List<Task> tasks,
}) async {
  final filteredTasks = tasks
      .where((t) =>
          t is ChooseCorrectOptionValueChainTask ||
          t is ShowPayOffGraphTask ||
          t is ShowInsightsPageTask ||
          t is TableTask)
      .toList();
  String? selectedTaskId;
  String tabTitle = '';

  AddOptionChainTask? getOptionChainDetails(String taskId) {
    return tasks
        .whereType<AddOptionChainTask>()
        .firstWhere((task) => task.optionChainId == taskId);
  }

  return showDialog<AddTabTask>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Select Task to Add as Tab',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    Widget previewWidget;
                    String taskType;

                    if (task is ChooseCorrectOptionValueChainTask) {
                      final optionChain = getOptionChainDetails(task.taskId);
                      taskType = 'Option Chain';
                      if (optionChain != null) {
                        final previewKey = GlobalKey<PreviewScreenState>();
                        previewWidget = Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.table_chart, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Option Chain',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Expiry: ${optionChain.expiryDate.toString().split(' ')[0]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: PreviewScreen(
                                    key: previewKey,
                                    previewData: PreviewData(
                                      optionData: optionChain.data,
                                      columns: optionChain.columns,
                                      visibility: optionChain.visibility,
                                      settings: optionChain.settings,
                                      isEditorMode: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        previewWidget = const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Option Chain not found'),
                          ),
                        );
                      }
                    } else if (task is ShowPayOffGraphTask) {
                      taskType = 'Payoff Graph';
                      previewWidget = Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.show_chart, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payoff Graph',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Quantity: ${task.quantity}'),
                              Text('Spot Price: ${task.spotPrice}'),
                              Text('Day Delta: ${task.spotPriceDayDelta}'),
                            ],
                          ),
                        ),
                      );
                    } else if (task is ShowInsightsPageTask) {
                      taskType = 'Insights Page';
                      previewWidget = Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Insights Page',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Title: ${task.title}'),
                              const SizedBox(height: 8),
                              Text('Description: ${task.description}'),
                            ],
                          ),
                        ),
                      );
                    } else if (task is TableTask) {
                      taskType = 'Table';
                      previewWidget = Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.table_chart, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Table Task (${task.tables.tables.length} table${task.tables.tables.length > 1 ? 's' : ''})',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              ...task.tables.tables
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final idx = entry.key;
                                final table = entry.value;
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Table ${idx + 1}: ${table.tableTitle}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      if (table.tableDescription.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(table.tableDescription),
                                        ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: table.columns
                                              .map((col) =>
                                                  DataColumn(label: Text(col)))
                                              .toList(),
                                          rows: table.rows
                                              .map((row) => DataRow(
                                                    cells: row
                                                        .map((cell) => DataCell(
                                                            Text(cell)))
                                                        .toList(),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                      const Divider(height: 24, thickness: 1),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    } else {
                      previewWidget = const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Unknown Task Type'),
                        ),
                      );
                      taskType = 'Unknown';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          selectedTaskId =
                              task is ChooseCorrectOptionValueChainTask
                                  ? task.taskId
                                  : task.id;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Enter Tab Title for $taskType',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        onChanged: (value) => tabTitle = value,
                                        decoration: const InputDecoration(
                                            hintText: 'Tab Title',
                                            border: OutlineInputBorder()),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (tabTitle.trim().isEmpty) {
                                                return;
                                              }
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop(
                                                  AddTabTask(
                                                      taskId: selectedTaskId!,
                                                      tabTitle: tabTitle));
                                            },
                                            child: const Text('Create Tab'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: previewWidget,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
