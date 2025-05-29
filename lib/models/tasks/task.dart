import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:flutter/material.dart';

import 'highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/show_bottom_sheet.task.dart';

abstract class Task {
  final String id;
  final ActionType actionType;
  final TaskType taskType;

  Task({required this.id, required this.actionType, required this.taskType});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType.name,
      'taskType': taskType.name,
    };
  }

  buildDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(toJson().toString()),
            ),
          );
        });
  }

  static Task fromJson(Map<String, dynamic> json) {
    final taskType = json['taskType'];

    switch (taskType) {
      case 'addData':
        return AddDataTask.fromJson(json);
      case 'addLayer':
        return AddLayerTask.fromJson(json);
      case 'addPrompt':
        return AddPromptTask.fromJson(json);
      case 'addIndicator':
        return AddIndicatorTask.fromJson(json);
      case 'waitTask':
        return WaitTask.fromJson(json);
      case 'addMcq':
        return AddMcqTask.fromJson(json);
      case 'clearTask':
        return ClearTask.fromJson(json);
      case 'addOptionChain':
        return AddOptionChainTask.fromJson(json);
      case 'chooseCorrectOptionChainValue':
        return ChooseCorrectOptionValueChainTask.fromJson(json);
      case 'highlightCorrectOptionChainValue':
        return HighlightCorrectOptionChainValueTask.fromJson(json);
      case 'showPayOffGraph':
        return ShowPayOffGraphTask.fromJson(json);
      case 'addTab':
        return AddTabTask.fromJson(json);
      case 'removeTab':
        return RemoveTabTask.fromJson(json);
      case 'moveTab':
        return MoveTabTask.fromJson(json);
      case 'popUpTask':
        return ShowPopupTask.fromJson(json);
      case 'showBottomSheet':
        return ShowBottomSheetTask.fromJson(json);
      default:
        throw ArgumentError('Unknown task type: $taskType');
    }
  }
}

//Map<String, dynamic> toJson();
