import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class HighlightCorrectOptionChainValueTask extends Task {
  String optionChainId;
  List<int> correctRowIndex;

  HighlightCorrectOptionChainValueTask(
      {required this.optionChainId, required this.correctRowIndex})
      : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.highlightCorrectOptionChainValue,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['correctRowIndex'] = correctRowIndex;
    return data;
  }

  factory HighlightCorrectOptionChainValueTask.fromJson(
      Map<String, dynamic> json) {
    return HighlightCorrectOptionChainValueTask(
      optionChainId: json['optionChainId'],
      correctRowIndex: json['correctRowIndex'] is List
          ? List<int>.from(json['correctRowIndex'])
          : json['correctRowIndex'] is int
              ? [json['correctRowIndex']]
              : [],
    );
  }
}
