import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class SelectRowTask extends Task {
  String optionChainId;
  List<int> selectedRowIndexes;

  SelectRowTask({
    required this.optionChainId,
    required this.selectedRowIndexes,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.selectRows,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['selectedRowIndexes'] = selectedRowIndexes;
    return data;
  }

  factory SelectRowTask.fromJson(Map<String, dynamic> json) {
    return SelectRowTask(
      optionChainId: json['optionChainId'],
      selectedRowIndexes: List<int>.from(json['selectedRowIndexes'] ?? []),
      id: json['id'],
    );
  }
}
