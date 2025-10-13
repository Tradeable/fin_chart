import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/edit_column_visibility.task.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_settings.dart';

class OptionChainState {
  final List<OptionData> data;
  final List<ColumnConfig> columns;
  final OptionChainSettings settings;

  OptionChainState({
    required this.data,
    required this.columns,
    required this.settings,
  });

  OptionChainState copyWith({
    List<OptionData>? data,
    List<ColumnConfig>? columns,
    OptionChainSettings? settings,
    List<int>? selectedRows,
  }) {
    return OptionChainState(
      data: data ?? this.data,
      columns: columns ?? this.columns,
      settings: settings ?? this.settings,
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
    settings: createTask.settings ?? OptionChainSettings(),
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

    if (t is SetMaxSelectableRowsTask && t.optionChainId == optionChainId) {
      final newSettings = OptionChainSettings.fromJson(state.settings.toJson())
        ..maxSelectableRows = t.maxSelectableRows;
      state = state.copyWith(settings: newSettings);
    }
  }

  return state;
}
