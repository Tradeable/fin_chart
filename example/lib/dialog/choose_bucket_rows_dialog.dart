import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_settings.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<ChooseBucketRowsTask?> showChooseBucketRowsDialog({
  required BuildContext context,
  required List<Task> tasks,
  ChooseBucketRowsTask? initialTask,
}) async {
  final optionChainTasks = tasks.whereType<AddOptionChainTask>().toList();

  if (optionChainTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains available')),
    );
    return null;
  }

  int currentPage = 0;
  if (initialTask != null) {
    currentPage = optionChainTasks.indexWhere(
      (task) => task.optionChainId == initialTask.optionChainId,
    );
    if (currentPage == -1) currentPage = 0;
  }

  final selectedTask = await showDialog<AddOptionChainTask>(
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
                                  ),
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

  if (selectedTask == null) return null;

  selectedTask.settings ??= OptionChainSettings();
  selectedTask.settings!.selectionMode = SelectionMode.bucketRow;
  selectedTask.settings!.isBuySellVisible = true;

  final selectedBucketRows = await showDialog<List<BucketRowSelection>>(
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
                  'Select Bucket Rows in ${selectedTask.optionChainId}',
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
                      optionData: selectedTask.data,
                      columns: selectedTask.columns,
                      visibility: selectedTask.visibility,
                      settings: selectedTask.settings,
                      isEditorMode: false,
                      maxSelectableRows: initialTask?.maxSelectableRows,
                      bucketRows: initialTask?.bucketRows,
                    ),
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
                        final bucketRows =
                            previewKey.currentState?.getBucketRows();
                        if (bucketRows != null && bucketRows.isNotEmpty) {
                          Navigator.pop(dialogContext, bucketRows);
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one row'),
                            ),
                          );
                        }
                      },
                      child: const Text('OK'),
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

  if (selectedBucketRows == null) return null;

  return ChooseBucketRowsTask(
    optionChainId: selectedTask.optionChainId,
    bucketRows: selectedBucketRows,
    maxSelectableRows: initialTask?.maxSelectableRows,
  );
}
