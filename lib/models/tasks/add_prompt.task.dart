import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';

class AddPromptTask extends Task {
  String promptText;
  bool isExplanation;
  String? hint;

  AddPromptTask(
      {required this.promptText, this.isExplanation = false, this.hint})
      : super(
            id: generateV4(),
            actionType: ActionType.empty,
            taskType: TaskType.addPrompt);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['promptText'] = promptText;
    data['isExplanation'] = isExplanation;
    data['hint'] = hint;
    return data;
  }

  factory AddPromptTask.fromJson(Map<String, dynamic> json) {
    return AddPromptTask(
        promptText: json['promptText'],
        isExplanation: json['isExplanation'],
        hint: json['hint']);
  }
}
