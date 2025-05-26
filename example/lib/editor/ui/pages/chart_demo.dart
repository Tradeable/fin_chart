import 'dart:convert';

import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
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
  Widget? chart;
  PageController controller = PageController();
  List<AddOptionChainTask> optionChainTasks = [];
  AddOptionChainTask? correctOptionChainTask;
  List<String> tabs = [];
  int currentPageIndex = 0; // 0: chart, 1: option chain, 2: payoff graph

  @override
  void initState() {
    recipe = Recipe.fromJson(jsonDecode(widget.recipeDataJson));
    if (recipe.tasks.isNotEmpty) {
      currentTask = recipe.tasks.first;
      dd();
    }

    // Add default Chart tab
    tabs.add("Chart");

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
        optionChainTasks.add(task);
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.chooseCorrectOptionChainValue:
        ChooseCorrectOptionValueChainTask task =
            currentTask as ChooseCorrectOptionValueChainTask;
        correctOptionChainTask =
            optionChainTasks.firstWhere((e) => e.optionChainId == task.taskId);
        onTaskFinish();
        break;
      case TaskType.highlightCorrectOptionChainValue:
        HighlightCorrectOptionChainValueTask task =
            currentTask as HighlightCorrectOptionChainValueTask;
        if ((task.bucketRows ?? []).isNotEmpty) {
          _previewScreenKey.currentState?.chooseBucketRows(task.bucketRows!);
        } else {
          for (int i in task.correctRowIndex) {
            _previewScreenKey.currentState?.chooseRow(i);
          }
        }
        onTaskFinish();
        setState(() {});
        break;
      case TaskType.showPayOffGraph:
        onTaskFinish();
        break;
      case TaskType.addTab:
        setState(() {
          tabs.add((currentTask as AddTabTask).tabTitle);
        });
        onTaskFinish();
        break;
      case TaskType.removeTab:
        setState(() {
          tabs.remove((currentTask as RemoveTabTask).tabTitle);
        });
        onTaskFinish();
        break;
      case TaskType.moveTab:
        MoveTabTask task = currentTask as MoveTabTask;
        if (task.tabTaskID == "chart") {
          navigateToPage(0).then((_) {
            onTaskFinish();
          });
          return;
        }
        final addTabTasks = recipe.tasks.whereType<AddTabTask>().toList();
        if (addTabTasks.isEmpty) {
          onTaskFinish();
          return;
        }
        final targetTabTask = addTabTasks.firstWhere(
          (t) => t.taskId == task.tabTaskID,
          orElse: () => addTabTasks.first,
        );
        final targetTab = tabs.firstWhere(
          (tab) => tab == targetTabTask.tabTitle,
          orElse: () => tabs.first,
        );
        navigateToPage(tabs.indexOf(targetTab)).then((_) {
          onTaskFinish();
        });
        break;
    }
  }

  Future<void> navigateToPage(int pageIndex) async {
    setState(() {
      currentPageIndex = pageIndex;
    });
    await controller.animateToPage(
      pageIndex,
      duration: const Duration(seconds: 1),
      curve: Curves.easeIn,
    );
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
          Text(tabs.toString()),
          // optionChainButtonVisibility
          //     ? Flexible(
          //         flex: 1,
          //         child: Align(
          //           alignment: Alignment.topRight,
          //           child: ElevatedButton(
          //               onPressed: () {
          //                 setState(() {
          //                   currentPageIndex = currentPageIndex == 1 ? 0 : 1;
          //                   navigateToPage(currentPageIndex);
          //                 });
          //               },
          //               child: Text(currentPageIndex == 1
          //                   ? "View Chart"
          //                   : "View Option Chain")),
          //         ))
          //     : Container(),
          Expanded(
            flex: 6,
            child: PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Chart.from(
                          key: _chartKey,
                          recipe: recipe,
                          onInteraction: (p0, p1) {});
                    case 1:
                      return PreviewScreen.from(
                          key: _previewScreenKey,
                          task: correctOptionChainTask!,
                          isEditorMode: false);
                    case 2:
                      return Container(
                        color: Colors.blue,
                        child: const Center(
                          child: Text("Payoff Graph View"),
                        ),
                      );
                    default:
                      return Container();
                  }
                }),
          ),
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
      case TaskType.showPayOffGraph:
      case TaskType.addTab:
      case TaskType.removeTab:
      case TaskType.moveTab:
        return Container();
    }
  }
}
