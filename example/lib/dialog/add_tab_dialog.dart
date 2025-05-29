import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';

Future<AddTabTask?> addTabDialog({
  required BuildContext context,
  required List<Task> tasks,
}) async {
  final filteredTasks = tasks
      .where((t) =>
          t is ChooseCorrectOptionValueChainTask ||
          t is ShowPayOffGraphTask ||
          t is ShowInsightsPageTask)
      .toList();
  String? selectedTaskId;
  String tabTitle = '';

  return showDialog<AddTabTask>(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Select Task',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final taskId =
                        task.runtimeType == ChooseCorrectOptionValueChainTask
                            ? (task as ChooseCorrectOptionValueChainTask).taskId
                            : task.id;
                    return ListTile(
                      title: Text(task.runtimeType.toString()),
                      subtitle: Text(taskId),
                      onTap: () {
                        if (task.runtimeType ==
                            ChooseCorrectOptionValueChainTask) {
                          selectedTaskId =
                              (task as ChooseCorrectOptionValueChainTask)
                                  .taskId;
                        } else {
                          selectedTaskId = task.id;
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                width: 200,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Enter Tab Title',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    TextField(
                                      onChanged: (value) => tabTitle = value,
                                      decoration: const InputDecoration(
                                          hintText: 'Tab Title'),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (tabTitle.trim().isEmpty) return;
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop(
                                                AddTabTask(
                                                    taskId: selectedTaskId!,
                                                    tabTitle: tabTitle));
                                          },
                                          child: const Text('Submit'),
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
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  )
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
