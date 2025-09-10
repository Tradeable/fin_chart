import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ShowSideNavTask extends Task {
  String title;
  String primaryButtonText;
  String secondaryButtonText;
  String primaryDescription;
  String secondaryDescription;

  ShowSideNavTask({
    required this.title,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.primaryDescription,
    required this.secondaryDescription,
  }) : super(
          id: generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.showSideNav,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['title'] = title;
    data['primaryButtonText'] = primaryButtonText;
    data['secondaryButtonText'] = secondaryButtonText;
    data['primaryDescription'] = primaryDescription;
    data['secondaryDescription'] = secondaryDescription;
    return data;
  }

  factory ShowSideNavTask.fromJson(Map<String, dynamic> json) {
    return ShowSideNavTask(
      title: json['title'],
      primaryButtonText: json['primaryButtonText'],
      secondaryButtonText: json['secondaryButtonText'],
      primaryDescription: json['primaryDescription'],
      secondaryDescription: json['secondaryDescription'],
    );
  }
}
