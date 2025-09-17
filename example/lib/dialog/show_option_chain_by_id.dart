import 'dart:math' as math;

import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';

Future<AddOptionChainTask?> showOptionChainById({
  required BuildContext context,
  required List<Task> tasks,
  AddOptionChainTask? initialTask,
}) async {
  final optionChainTasks = tasks.whereType<CreateOptionChainTask>().toList();

  if (optionChainTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No option chains available')),
    );
    return null;
  }
  int currentPage = 0;
  if (initialTask != null) {
    currentPage = optionChainTasks.indexWhere(
      (task) => task.optionChainId == initialTask.taskId,
    );
    if (currentPage == -1) currentPage = 0;
  }

  final selectedTask = await showDialog<CreateOptionChainTask>(
    context: context,
    builder: (BuildContext dialogContext) {
      final pageController = PageController(initialPage: currentPage);
      final totalPages = (optionChainTasks.length / 2).ceil();

      return StatefulBuilder(
        builder: (context, setState) {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Option Chain',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: totalPages,
                      onPageChanged: (index) {
                        setState(() => currentPage = index);
                      },
                      itemBuilder: (context, pageIndex) {
                        final startIndex = pageIndex * 2;
                        final endIndex =
                            math.min(startIndex + 2, optionChainTasks.length);
                        final pageItems =
                            optionChainTasks.sublist(startIndex, endIndex);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: pageItems.map((task) {
                              final previewKey =
                                  GlobalKey<PreviewScreenState>();
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(dialogContext, task);
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chain ${optionChainTasks.indexOf(task) + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: PreviewScreen(
                                            key: previewKey,
                                            previewData: PreviewData(
                                                optionData: task.data,
                                                columns: task.columns,
                                                visibility: task.visibility,
                                                settings: task.settings,
                                                isEditorMode: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: currentPage > 0
                              ? () {
                                  pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: currentPage < totalPages - 1
                              ? () {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                        ),
                      ],
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
    },
  );

  if (selectedTask == null) return null;

  return AddOptionChainTask(taskId: selectedTask.optionChainId);
}
