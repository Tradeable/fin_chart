import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ToggleBuySellVisibilityTask extends Task {
  String optionChainId;
  bool isBuySellVisible;

  ToggleBuySellVisibilityTask({
    required this.optionChainId,
    required this.isBuySellVisible,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.toggleBuySellVisibility,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['isBuySellVisible'] = isBuySellVisible;
    return data;
  }

  factory ToggleBuySellVisibilityTask.fromJson(Map<String, dynamic> json) {
    return ToggleBuySellVisibilityTask(
      optionChainId: json['optionChainId'],
      isBuySellVisible: json['isBuySellVisible'] ?? false,
      id: json['id'],
    );
  }
}
