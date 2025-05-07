import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/utils/calculations.dart';

class AddOptionChainTask extends Task {
  List<ColumnConfig> columns;
  List<OptionData> data;
  OptionChainVisibility visibility;
  DateTime expiryDate;
  int interval;
  int? correctRowIndex;
  String optionChainId;

  AddOptionChainTask(
      {required this.columns,
      required this.data,
      required this.visibility,
      required this.expiryDate,
      required this.interval,
      this.correctRowIndex,
      required this.optionChainId})
      : super(
            id: generateV4(),
            actionType: ActionType.empty,
            taskType: TaskType.addOptionChain);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['columns'] = columns.map((c) => c.toJson()).toList();
    data['data'] = this.data.map((d) => d.toJson()).toList();
    data['visibility'] = visibility.name;
    data['expiryDate'] = expiryDate.toIso8601String();
    data['interval'] = interval;
    data['correctRowIndex'] = correctRowIndex;
    data['optionChainId'] = optionChainId;
    return data;
  }

  factory AddOptionChainTask.fromJson(Map<String, dynamic> json) {
    return AddOptionChainTask(
      columns: (json['columns'] as List)
          .map((c) => ColumnConfig.fromJson(c))
          .toList(),
      data: (json['data'] as List).map((d) => OptionData.fromJson(d)).toList(),
      visibility: OptionChainVisibility.values.firstWhere(
          (v) => v.name == json['visibility'],
          orElse: () => OptionChainVisibility.both),
      expiryDate: DateTime.parse(json['expiryDate']),
      interval: json['interval'] as int,
      optionChainId: json['optionChainId'] as String,
    );
  }
}
