import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ChooseCorrectOptionValueChainTask extends Task {
  String taskId;
  int? maxSelectableRows;

  ChooseCorrectOptionValueChainTask(
      {required this.taskId, this.maxSelectableRows})
      : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.chooseCorrectOptionChainValue,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['taskId'] = taskId;
    data['maxSelectableRows'] = maxSelectableRows;
    return data;
  }

  factory ChooseCorrectOptionValueChainTask.fromJson(
      Map<String, dynamic> json) {
    return ChooseCorrectOptionValueChainTask(
        taskId: json['taskId'], maxSelectableRows: json['maxSelectableRows']);
  }
}
