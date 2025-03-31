import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:example/editor/ui/widget/task_type_dropdown.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> task;
  final Function(TaskType, int) onTaskAdd; // Modified to include position
  final Function(Task) onTaskClick;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskDelete;
  final Function(int, int) onTaskReorder;

  const TaskListWidget({
    super.key,
    required this.task,
    required this.onTaskAdd,
    required this.onTaskClick,
    required this.onTaskEdit,
    required this.onTaskDelete,
    required this.onTaskReorder,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  void _showTaskTypeSelectionDialog(BuildContext context, int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Task Type'),
          content: SizedBox(
            width: 300,
            child: TaskTypeDropdown(
              selectedType: null,
              onChanged: (taskType) {
                Navigator.of(context).pop();
                widget.onTaskAdd(taskType, position);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddButton(int position) {
    return InkWell(
      onTap: () => _showTaskTypeSelectionDialog(context, position),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: const CircleAvatar(
          radius: 15,
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.isEmpty) {
      // Show only a centered + button when list is empty
      return Center(
        child: _buildAddButton(0),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 9,
          child: SizedBox(
            height: 80, // Set height for horizontal list
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add button at the beginning
                _buildAddButton(0),

                // Tasks with add buttons in between
                ...widget.task.asMap().entries.map((entry) {
                  int index = entry.key;
                  Task task = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        key: ValueKey("task-$index"),
                        onTap: () {
                          widget.onTaskClick(task);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 0.0),
                                child: Icon(
                                  Icons.drag_indicator,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ),
                              Text(
                                '${task.taskType.toString().split('.').last} ${task.actionType == ActionType.interupt ? ": " : ""}',
                              ),
                              taskBaseOptions(task),
                              const SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.onTaskDelete(task);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Add button after each task except the last one
                      _buildAddButton(index + 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget taskBaseOptions(Task task) {
    switch (task.taskType) {
      case TaskType.addData:
        task as AddDataTask;
        return Text("${task.fromPoint} - ${task.tillPoint}");
      case TaskType.addIndicator:
        return Text((task as AddIndicatorTask).indicator.type.name);
      case TaskType.addLayer:
        return Text((task as AddLayerTask).layer.type.name);
      case TaskType.addPrompt:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () {
                widget.onTaskEdit(task);
              },
              child: const Icon(
                Icons.edit,
                color: Colors.blue,
                size: 18,
              ),
            ),
          ],
        );
      case TaskType.waitTask:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (task as WaitTask).btnText,
            ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () {
                widget.onTaskEdit(task);
              },
              child: const Icon(
                Icons.edit,
                color: Colors.blue,
                size: 18,
              ),
            ),
          ],
        );
    }
  }
}
