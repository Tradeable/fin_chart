import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/edit_column_visibility.task.dart';
import 'package:fin_chart/models/tasks/edit_option_row_task.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';

class OptionChainState {
  final List<OptionData> data;
  final List<ColumnConfig> columns;

  OptionChainState({
    required this.data,
    required this.columns,
  });

  OptionChainState copyWith({
    List<OptionData>? data,
    List<ColumnConfig>? columns,
  }) {
    return OptionChainState(
      data: data ?? this.data,
      columns: columns ?? this.columns,
    );
  }
}

OptionChainState rebuildOptionChainState({
  required List<dynamic> tasks,
  required int taskIndex,
  required String optionChainId,
}) {
  final createTask = tasks
      .whereType<CreateOptionChainTask>()
      .firstWhere((t) => t.optionChainId == optionChainId);

  var state = OptionChainState(
    data: [...createTask.data],
    columns: [...createTask.columns],
  );

  for (int i = 0; i < taskIndex; i++) {
    final t = tasks[i];

    if (t is EditOptionRowTask && t.optionChainId == optionChainId) {
      if (t.rowIndex >= 0 &&
          t.rowIndex < state.data.length &&
          t.updatedRow != null) {
        final updated = [...state.data];
        updated[t.rowIndex] = t.updatedRow!;
        state = state.copyWith(data: updated);
      }
    }

    if (t is EditColumnVisibilityTask && t.optionChainId == optionChainId) {
      state = state.copyWith(columns: [...t.updatedColumns]);
    }
  }

  return state;
}

