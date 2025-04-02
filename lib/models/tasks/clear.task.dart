import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ClearTask extends Task {
  ClearTask()
      : super(
            id: generateV4(),
            actionType: ActionType.empty,
            taskType: TaskType.clearTask);

  factory ClearTask.fromJson(Map<String, dynamic> json) {
    return ClearTask();
  }
}
