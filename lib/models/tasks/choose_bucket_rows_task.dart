import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ChooseBucketRowsTask extends Task {
  String optionChainId;
  List<Map<int, int>>? bucketRows;
  int? maxSelectableRows;

  ChooseBucketRowsTask({
    required this.optionChainId,
    this.bucketRows,
    this.maxSelectableRows,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.chooseBucketRows,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    if (bucketRows != null) {
      data['bucketRows'] = bucketRows!
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    data['maxSelectableRows'] = maxSelectableRows;
    return data;
  }

  factory ChooseBucketRowsTask.fromJson(Map<String, dynamic> json) {
    return ChooseBucketRowsTask(
      optionChainId: json['optionChainId'],
      bucketRows: json['bucketRows'] != null
          ? List<Map<int, int>>.from(json['bucketRows'].map((map) =>
              Map<int, int>.from(map.map((k, v) => MapEntry(int.parse(k), v)))))
          : null,
      maxSelectableRows: json['maxSelectableRows'],
    );
  }
} 