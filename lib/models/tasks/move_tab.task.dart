import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class MoveTabTask extends Task {
  String tabTaskID;

  MoveTabTask({required this.tabTaskID})
      : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.moveTab,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['tabTaskID'] = tabTaskID;
    return data;
  }

  factory MoveTabTask.fromJson(Map<String, dynamic> json) {
    return MoveTabTask(tabTaskID: json['tabTaskID']);
  }
}
