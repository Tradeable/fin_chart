import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/clear_bucket_rows_task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';

Future<ClearBucketRowsTask?> showClearBucketRowsDialog({
  required BuildContext context,
  required List<Task> tasks,
  ClearBucketRowsTask? initialTask,
}) async {
  // Get all AddOptionChainTasks
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
                  'Select Option Chain to Clear Bucket Rows',
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

  return ClearBucketRowsTask(
    optionChainId: selectedTask.optionChainId,
  );
} 