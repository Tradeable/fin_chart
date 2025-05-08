import 'dart:convert';

import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/highlight_option_chain.task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';

class ChartDemo extends StatefulWidget {
  final String recipeDataJson;

  const ChartDemo({super.key, required this.recipeDataJson});

  @override
  State<ChartDemo> createState() => _ChartDemoState();
}

class _ChartDemoState extends State<ChartDemo> {
  final GlobalKey<ChartState> _chartKey = GlobalKey();
  final GlobalKey<PreviewScreenState> _previewScreenKey = GlobalKey();
  late Recipe recipe;

  int taskPointer = 0;
  late Task currentTask;

  String promptText = "";
  bool switchToOptionChain = false;
  Widget? chart;
  PageController controller = PageController();
  bool optionChainButtonVisibility = false;
  List<AddOptionChainTask> optionChainTasks = [];
  AddOptionChainTask? correctOptionChainTask;

  @override
  void initState() {
    recipe = Recipe.fromJson(jsonDecode(widget.recipeDataJson));
    if (recipe.tasks.isNotEmpty) {
      currentTask = recipe.tasks.first;
      dd();
    }

    chart =
        Chart.from(key: _chartKey, recipe: recipe, onInteraction: (p0, p1) {});
    super.initState();
  }

  void dd() async {
    await Future.delayed(const Duration(milliseconds: 300));
    onTaskRun();
  }

  void onTaskRun() {
    switch (currentTask.taskType) {
      case TaskType.addData:
        AddDataTask task = currentTask as AddDataTask;
        _chartKey.currentState
            ?.addDataWithAnimation(
                recipe.data.sublist(task.fromPoint, task.tillPoint),
                const Duration(milliseconds: 10))
            .then((value) {
          if (value) {
            onTaskFinish();
          }
        });
        break;
      case TaskType.addIndicator:
        AddIndicatorTask task = currentTask as AddIndicatorTask;
        _chartKey.currentState?.addIndicator(task.indicator);
        onTaskFinish();
        break;
      case TaskType.addLayer:
        AddLayerTask task = currentTask as AddLayerTask;
        _chartKey.currentState?.addLayerAtRegion(task.regionId, task.layer);
        onTaskFinish();
        break;
      case TaskType.addPrompt:
        AddPromptTask task = currentTask as AddPromptTask;
        setState(() {
          promptText = task.promptText;
        });
        onTaskFinish();
        break;
      case TaskType.waitTask:
        setState(() {});
        break;
      case TaskType.addMcq:
        setState(() {});
        break;
      case TaskType.clearTask:
        _chartKey.currentState?.clearChart();
        onTaskFinish();
        break;
      case TaskType.addOptionChain:
        AddOptionChainTask task = currentTask as AddOptionChainTask;

        optionChainButtonVisibility = true;
        optionChainTasks.add(task);
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.chooseCorrectOptionChainValue:
        ChooseCorrectOptionValueChainTask task =
            currentTask as ChooseCorrectOptionValueChainTask;
        correctOptionChainTask =
            optionChainTasks.firstWhere((e) => e.optionChainId == task.taskId);
        controller
            .animateToPage(1,
                duration: Duration(seconds: 1), curve: Curves.easeIn)
            .then((val) {
          onTaskFinish();
        });
        switchToOptionChain = true;
        setState(() {});
        break;
      case TaskType.highlightCorrectOptionChainValue:
        HighlightCorrectOptionChainValueTask task =
            currentTask as HighlightCorrectOptionChainValueTask;
        _previewScreenKey.currentState?.chooseRow(task.correctRowIndex);
        onTaskFinish();
        setState(() {});
        break;
    }
  }

  void onTaskFinish() {
    taskPointer += 1;
    if (taskPointer < recipe.tasks.length) {
      currentTask = recipe.tasks[taskPointer];
      onTaskRun();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Finance Charts Demo"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.none,
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(promptText),
              ),
            ),
          ),
          optionChainButtonVisibility
              ? Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            switchToOptionChain = !switchToOptionChain;
                            controller.animateToPage(
                                switchToOptionChain ? 1 : 0,
                                duration: Duration(seconds: 1),
                                curve: Curves.easeIn);
                          });
                        },
                        child: Text(switchToOptionChain
                            ? "View Chart"
                            : "View Option Chain")),
                  ))
              : Container(),
          Expanded(
            flex: 6,
            child: PageView.builder(
                controller: controller,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Chart.from(
                        key: _chartKey,
                        recipe: recipe,
                        onInteraction: (p0, p1) {});
                  } else {
                    return PreviewScreen.from(
                        key: _previewScreenKey, task: correctOptionChainTask!);
                  }
                }),
          ),
          // Expanded(
          //     flex: 6,
          //     child: switchToOptionChain
          //         ? PreviewScreen.from(
          //             key: _previewScreenKey,
          //             task: (currentTask as AddOptionChainTask))
          //         : chart ?? Container()),
          Expanded(
              flex: 1,
              child: FittedBox(fit: BoxFit.none, child: userActionContainer()))
        ],
      )),
    );
  }

  Widget userActionContainer() {
    switch (currentTask.taskType) {
      case TaskType.addData:
      case TaskType.addIndicator:
      case TaskType.addLayer:
      case TaskType.addPrompt:
      case TaskType.clearTask:
        return Container();
      case TaskType.addMcq:
        Task task = currentTask as AddMcqTask;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...(task as AddMcqTask).options.map((e) {
              return ElevatedButton(
                  onPressed: () {
                    onTaskFinish();
                  },
                  child: Text(e));
            })
          ],
        );
      case TaskType.waitTask:
        return ElevatedButton(
            onPressed: () {
              onTaskFinish();
            },
            child: Text((currentTask as WaitTask).btnText));
      case TaskType.addOptionChain:
      case TaskType.chooseCorrectOptionChainValue:
      case TaskType.highlightCorrectOptionChainValue:
        return Container();
      // return ElevatedButton(
      //     onPressed: () {
      //       HighlightCorrectOptionChainValueTask task =
      //           currentTask as HighlightCorrectOptionChainValueTask;
      //       _previewScreenKey.currentState?.chooseRow(task.correctRowIndex);
      //       onTaskFinish();
      //     },
      //     child: Text("Okay"));
    }
  }
}
