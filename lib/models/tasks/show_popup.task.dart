import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';

class ShowPopupTask extends Task {
  String title;
  String description;
  String buttonText;

  ShowPopupTask({
    required this.title,
    required this.description,
    required this.buttonText,
  }) : super(
          id: generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.popUpTask,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['title'] = title;
    data['description'] = description;
    data['buttonText'] = buttonText;
    return data;
  }

  factory ShowPopupTask.fromJson(Map<String, dynamic> json) {
    return ShowPopupTask(
      title: json['title'],
      description: json['description'],
      buttonText: json['buttonText'],
    );
  }
}
