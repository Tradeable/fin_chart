import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/utils/calculations.dart';

class EditColumnVisibilityTask extends Task {
  String optionChainId;
  List<ColumnConfig> updatedColumns;

  EditColumnVisibilityTask({
    required this.optionChainId,
    required this.updatedColumns,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.editColumnVisibility,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['updatedColumns'] = updatedColumns.map((c) => c.toJson()).toList();
    return data;
  }

  factory EditColumnVisibilityTask.fromJson(Map<String, dynamic> json) {
    return EditColumnVisibilityTask(
      optionChainId: json['optionChainId'],
      updatedColumns: (json['updatedColumns'] as List<dynamic>)
          .map((e) => ColumnConfig.fromJson(e))
          .toList(),
      id: json['id'],
    );
  }
}
