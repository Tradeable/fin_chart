import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ClearBucketRowsTask extends Task {
  String? optionChainId;
  List<CreateOptionChainTask>? availableOptionChains;

  ClearBucketRowsTask({
    this.optionChainId,
    this.availableOptionChains,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.clearBucketRows,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    if (availableOptionChains != null) {
      data['availableOptionChains'] = availableOptionChains!.map((task) => task.toJson()).toList();
    }
    return data;
  }

  factory ClearBucketRowsTask.fromJson(Map<String, dynamic> json) {
    List<CreateOptionChainTask>? chains;
    if (json['availableOptionChains'] != null) {
      chains = (json['availableOptionChains'] as List)
          .map((taskJson) => CreateOptionChainTask.fromJson(taskJson))
          .toList();
    }
    
    return ClearBucketRowsTask(
      optionChainId: json['optionChainId'],
      availableOptionChains: chains,
    );
  }
} 