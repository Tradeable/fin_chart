import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/mcq_arrangment_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class AddMcqTask extends Task {
  bool isMultiSelect;
  MCQArrangementType arrangementType;
  List<String> options;
  List<String> correctOptionIndices;

  AddMcqTask(
      {required this.isMultiSelect,
      required this.arrangementType,
      required this.options,
      required this.correctOptionIndices})
      : super(
            id: generateV4(),
            actionType: ActionType.interupt,
            taskType: TaskType.addMcq);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['isMultiSelect'] = isMultiSelect;
    data['arrangementType'] = arrangementType.name;
    data['options'] = options;
    data['correctOptionIndices'] = correctOptionIndices;
    return data;
  }

  factory AddMcqTask.fromJson(Map<String, dynamic> json) {
    return AddMcqTask(
      isMultiSelect: json['isMultiSelect'],
      arrangementType:
          (json['arrangementType'] as String).toMCQArrangementType(),
      options: List<String>.from(json['options']),
      correctOptionIndices: List<String>.from(json['correctOptionIndices']),
    );
  }
}
