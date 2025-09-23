import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class AddTabTask extends Task {
  String taskId;
  String tabTitle;

  AddTabTask({required this.taskId, required this.tabTitle})
      : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.addTab,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['taskId'] = taskId;
    data['tabTitle'] = tabTitle;
    return data;
  }

  factory AddTabTask.fromJson(Map<String, dynamic> json) {
    return AddTabTask(
      taskId: json['taskId'],
      tabTitle: json['tabTitle'],
    );
  }
}
