import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class HighlightCorrectOptionChainValueTask extends Task {
  String optionChainId;
  List<int> correctRowIndex;
  List<Map<int, int>>? bucketRows;

  HighlightCorrectOptionChainValueTask({
    required this.optionChainId,
    required this.correctRowIndex,
    this.bucketRows,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.highlightCorrectOptionChainValue,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['correctRowIndex'] = correctRowIndex;
    if (bucketRows != null) {
      data['bucketRows'] = bucketRows!
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
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
      bucketRows: json['bucketRows'] != null
          ? List<Map<int, int>>.from(json['bucketRows'].map((map) =>
              Map<int, int>.from(map.map((k, v) => MapEntry(int.parse(k), v)))))
          : null,
    );
  }
}
