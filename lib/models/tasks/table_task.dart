import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/table_model.dart';
import 'package:fin_chart/utils/calculations.dart';

class TableTask extends Task {
  TablesModel tables;

  TableTask({
    required this.tables,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.tableTask,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['tables'] = tables.toJson();
    return data;
  }

  factory TableTask.fromJson(Map<String, dynamic> json) {
    return TableTask(
      tables: TablesModel.fromJson(json['tables']),
      id: json['id'],
    );
  }
} 