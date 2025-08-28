import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/insights_v2/content_block.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ShowInsightsPageV2Task extends Task {
  String title;
  List<ContentBlock> blocks;

  ShowInsightsPageV2Task({
    required this.title,
    required this.blocks,
    String? id,
  }) : super(
          id: id ?? generateV4(),
          actionType: ActionType.interupt,
          taskType: TaskType.showInsightsV2Page,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['title'] = title;
    data['blocks'] = blocks.map((e) => e.toJson()).toList();
    return data;
  }

  factory ShowInsightsPageV2Task.fromJson(Map<String, dynamic> json) {
    return ShowInsightsPageV2Task(
      title: json['title'],
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => ContentBlock.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      id: json['id'],
    );
  }
}
