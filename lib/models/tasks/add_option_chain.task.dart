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
  double? strikePrice;

  AddOptionChainTask(
      {required this.columns,
      required this.data,
      required this.visibility,
      required this.expiryDate,
      required this.interval,
      this.correctRowIndex,
      required this.optionChainId,
      this.strikePrice})
      : super(
            id: generateV4(),
            actionType: ActionType.empty,
            taskType: TaskType.addOptionChain);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['columns'] = columns.map((e) => e.toJson()).toList();
    json['data'] = data.map((e) => e.toJson()).toList();
    json['visibility'] = visibility.name;
    json['expiryDate'] = expiryDate.toIso8601String();
    json['interval'] = interval;
    json['correctRowIndex'] = correctRowIndex;
    json['optionChainId'] = optionChainId;
    json['strikePrice'] = strikePrice;
    return json;
  }

  factory AddOptionChainTask.fromJson(Map<String, dynamic> json) {
    return AddOptionChainTask(
        columns: (json['columns'] as List)
            .map((e) => ColumnConfig.fromJson(e))
            .toList(),
        data:
            (json['data'] as List).map((e) => OptionData.fromJson(e)).toList(),
        visibility: OptionChainVisibility.values.firstWhere(
            (v) => v.name == json['visibility'],
            orElse: () => OptionChainVisibility.both),
        expiryDate: DateTime.parse(json['expiryDate']),
        interval: json['interval'] as int,
        correctRowIndex: json['correctRowIndex'] as int?,
        optionChainId: json['optionChainId'] as String,
        strikePrice: (json['strikePrice'] as num?)?.toDouble());
  }
}
