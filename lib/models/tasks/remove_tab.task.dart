import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class RemoveTabTask extends Task {
  String tabTitle;

  RemoveTabTask({required this.tabTitle})
      : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.removeTab,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['tabTitle'] = tabTitle;
    return data;
  }

  factory RemoveTabTask.fromJson(Map<String, dynamic> json) {
    return RemoveTabTask(tabTitle: json['tabTitle']);
  }
}
