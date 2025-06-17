import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_settings.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<HighlightCorrectOptionChainValueTask?> showAllOptionChains({
  required BuildContext context,
  required List<Task> tasks,
}) async {
  final optionChainTasks = tasks.whereType<AddOptionChainTask>().toList();
  final chooseCorrectTasks =
      tasks.whereType<ChooseCorrectOptionValueChainTask>().toList();

  if (optionChainTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains available')),
    );
    return null;
  }

  int? getMaxSelectableRows(String optionChainId) {
    try {
      final task = chooseCorrectTasks.firstWhere(
        (task) => task.taskId == optionChainId,
      );
      return task.maxSelectableRows;
    } catch (e) {
      return null;
    }
  }

  final selectedOptionChain = await showDialog<AddOptionChainTask>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Option Chain',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: optionChainTasks.length,
                  itemBuilder: (context, index) {
                    final task = optionChainTasks[index];
                    return GestureDetector(
                      onTap: () => Navigator.pop(dialogContext, task),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chain ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID: ${task.optionChainId}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: PreviewScreen(
                                  previewData: PreviewData(
                                      optionData: task.data,
                                      columns: task.columns,
                                      visibility: task.visibility,
                                      settings: task.settings,
                                      isEditorMode: true,
                                      maxSelectableRows: getMaxSelectableRows(
                                          task.optionChainId)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (selectedOptionChain == null) return null;

  final selectedRowIndex = await showDialog<dynamic>(
    context: context,
    builder: (BuildContext dialogContext) {
      final previewKey = GlobalKey<PreviewScreenState>();

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Row in ${selectedOptionChain.optionChainId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PreviewScreen(
                    key: previewKey,
                    previewData: PreviewData(
                        optionData: selectedOptionChain.data,
                        columns: selectedOptionChain.columns,
                        visibility: selectedOptionChain.visibility,
                        settings: (selectedOptionChain.settings ?? OptionChainSettings())
                          ..isBuySellVisible = false,
                        isEditorMode: false,
                        maxSelectableRows: getMaxSelectableRows(
                            selectedOptionChain.optionChainId)),
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
                        final selectionMode =
                            selectedOptionChain.settings?.selectionMode ??
                                SelectionMode.entireRow;
                        
                        if (selectionMode == SelectionMode.bucketRow) {
                          // Handle bucket row selection
                          final bucketRows =
                              previewKey.currentState?.getBucketRows();
                          if (bucketRows != null && bucketRows.isNotEmpty) {
                            Navigator.pop(dialogContext, bucketRows);
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select at least one row')),
                            );
                          }
                        } else {
                          // Handle regular row selection
                          final selectedIndex =
                              previewKey.currentState?.getCorrectRowIndex();
                          if (selectedIndex != null &&
                              selectedIndex.isNotEmpty) {
                            Navigator.pop(dialogContext, selectedIndex);
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select at least one row')),
                            );
                          }
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (selectedRowIndex != null) {
    final selectionMode =
        selectedOptionChain.settings?.selectionMode ?? SelectionMode.entireRow;
    
    if (selectionMode == SelectionMode.bucketRow) {
      // Handle bucket row selection
      final bucketRows = selectedRowIndex as List<BucketRowSelection>;
      return HighlightCorrectOptionChainValueTask(
        optionChainId: selectedOptionChain.optionChainId,
        correctRowIndex: [],
        bucketRows: bucketRows,
      );
    } else {
      // Handle regular row selection
      final rowIndices = selectedRowIndex as List<int>;
      return HighlightCorrectOptionChainValueTask(
        optionChainId: selectedOptionChain.optionChainId,
        correctRowIndex: rowIndices,
      );
    }
  }
  return null;
}
