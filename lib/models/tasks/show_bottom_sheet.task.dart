import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ShowBottomSheetTask extends Task {
  String title;
  String description;
  bool showImage;
  String primaryButtonText;
  String? secondaryButtonText;

  ShowBottomSheetTask({
    required this.title,
    required this.description,
    required this.showImage,
    required this.primaryButtonText,
    this.secondaryButtonText,
  }) : super(
          id: generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.showBottomSheet,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['title'] = title;
    data['description'] = description;
    data['showImage'] = showImage;
    data['primaryButtonText'] = primaryButtonText;
    if (secondaryButtonText != null) {
      data['secondaryButtonText'] = secondaryButtonText;
    }
    return data;
  }

  factory ShowBottomSheetTask.fromJson(Map<String, dynamic> json) {
    return ShowBottomSheetTask(
      title: json['title'],
      description: json['description'],
      showImage: json['showImage'],
      primaryButtonText: json['primaryButtonText'],
      secondaryButtonText: json['secondaryButtonText'],
    );
  }
} 