import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ShowInsightsPageTask extends Task {
  String title;
  String description;

  ShowInsightsPageTask({
    required this.title,
    required this.description,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.showInsightsPage,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['title'] = title;
    data['description'] = description;
    return data;
  }

  factory ShowInsightsPageTask.fromJson(Map<String, dynamic> json) {
    return ShowInsightsPageTask(
      title: json['title'],
      description: json['description'],
      id: json['id'],
    );
  }
} 