import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class HighlightTableRowTask extends Task {
  String tableTaskId;
  Map<int, List<int>> selectedRows; // tableIndex -> list of row indices

  // Deprecated single selection fields for backward compatibility
  int? tableIndex;
  int? rowIndex;

  HighlightTableRowTask({
    required this.tableTaskId,
    required this.selectedRows,
    this.tableIndex,
    this.rowIndex,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.highlightTableRow,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['tableTaskId'] = tableTaskId;
    data['selectedRows'] = selectedRows.map((k, v) => MapEntry(k.toString(), v));
    if (tableIndex != null) data['tableIndex'] = tableIndex;
    if (rowIndex != null) data['rowIndex'] = rowIndex;
    return data;
  }

  factory HighlightTableRowTask.fromJson(Map<String, dynamic> json) {
    Map<int, List<int>> selectedRows = {};
    if (json['selectedRows'] != null) {
      (json['selectedRows'] as Map<String, dynamic>).forEach((k, v) {
        selectedRows[int.parse(k)] = List<int>.from(v);
      });
    } else if (json['tableIndex'] != null && json['rowIndex'] != null) {
      // Backward compatibility: single selection
      selectedRows[int.parse(json['tableIndex'].toString())] = [json['rowIndex']];
    }
    return HighlightTableRowTask(
      tableTaskId: json['tableTaskId'],
      selectedRows: selectedRows,
      tableIndex: json['tableIndex'],
      rowIndex: json['rowIndex'],
      id: json['id'],
    );
  }
}
