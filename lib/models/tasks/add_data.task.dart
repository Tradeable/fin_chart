import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class AddDataTask extends Task {
  final String verticleLineId;
  int fromPoint;
  int tillPoint;

  AddDataTask(
      {required this.verticleLineId,
      required this.fromPoint,
      required this.tillPoint})
      : super(
            id: generateV4(),
            actionType: ActionType.empty,
            taskType: TaskType.addData);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['verticleLineId'] = verticleLineId;
    data['fromPoint'] = fromPoint;
    data['tillPoint'] = tillPoint;
    return data;
  }

  factory AddDataTask.fromJson(Map<String, dynamic> json) {
    return AddDataTask(
        verticleLineId: json['verticleLineId'] ?? "",
        fromPoint: json['fromPoint'],
        tillPoint: json['tillPoint']);
  }
}
