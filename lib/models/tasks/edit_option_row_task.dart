import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/utils/calculations.dart';

class EditOptionRowTask extends Task {
  String optionChainId;
  int rowIndex;
  OptionData? updatedRow;

  EditOptionRowTask({
    required this.optionChainId,
    required this.rowIndex,
    this.updatedRow,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.editOptionRow,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['rowIndex'] = rowIndex;
    if (updatedRow != null) {
      data['updatedRow'] = updatedRow!.toJson();
    }
    return data;
  }

  factory EditOptionRowTask.fromJson(Map<String, dynamic> json) {
    return EditOptionRowTask(
      optionChainId: json['optionChainId'],
      rowIndex: json['rowIndex'],
      updatedRow:
          json['updatedRow'] != null ? OptionData.fromJson(json['updatedRow']) : null,
      id: json['id'],
    );
  }
}


