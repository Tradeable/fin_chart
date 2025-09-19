import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class SetMaxSelectableRowsTask extends Task {
  String optionChainId;
  int? maxSelectableRows;

  SetMaxSelectableRowsTask({
    required this.optionChainId,
    this.maxSelectableRows,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.setMaxSelectableRows,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['maxSelectableRows'] = maxSelectableRows;
    return data;
  }

  factory SetMaxSelectableRowsTask.fromJson(Map<String, dynamic> json) {
    return SetMaxSelectableRowsTask(
      optionChainId: json['optionChainId'],
      maxSelectableRows: json['maxSelectableRows'],
      id: json['id'],
    );
  }
}
