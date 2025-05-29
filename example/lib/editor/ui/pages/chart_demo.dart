import 'dart:convert';

import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
import 'package:fin_chart/models/tasks/show_bottom_sheet.task.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';
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
  Map<String, GlobalKey<PreviewScreenState>> previewScreenKeys = {};
  late Recipe recipe;

  int taskPointer = 0;
  late Task currentTask;

  String promptText = "";
  String hintText = "";
  Widget? chart;
  PageController controller = PageController();
  List<AddOptionChainTask> optionChainTasks = [];
  List<ShowPayOffGraphTask> payoffGraphTasks = [];
  List<Map<String, String>> tabs = [];
  int currentPageIndex = 0;

  @override
  void initState() {
    recipe = Recipe.fromJson(jsonDecode(widget.recipeDataJson));
    if (recipe.tasks.isNotEmpty) {
      currentTask = recipe.tasks.first;
      dd();
    }
    tabs.add({"type": "chart", "title": "Chart"});

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
          hintText = task.hint ?? "";
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
        onTaskFinish();
        break;
      case TaskType.chooseCorrectOptionChainValue:
        onTaskFinish();
        break;
      case TaskType.highlightCorrectOptionChainValue:
        HighlightCorrectOptionChainValueTask task =
            currentTask as HighlightCorrectOptionChainValueTask;
        final previewKey =
            previewScreenKeys[task.optionChainId] ?? _previewScreenKey;
        if ((task.bucketRows ?? []).isNotEmpty) {
          previewKey.currentState?.chooseBucketRows(task.bucketRows!);
        } else {
          for (int i in task.correctRowIndex) {
            previewKey.currentState?.chooseRow(i);
          }
        }
        onTaskFinish();
        break;
      case TaskType.showPayOffGraph:
        ShowPayOffGraphTask task = currentTask as ShowPayOffGraphTask;
        payoffGraphTasks.add(task);
        onTaskFinish();
        break;
      case TaskType.addTab:
        setState(() {
          final task = currentTask as AddTabTask;
          previewScreenKeys[task.taskId] = GlobalKey<PreviewScreenState>();

          final tasks = recipe.tasks
              .whereType<ChooseCorrectOptionValueChainTask>()
              .where((t) => t.taskId == task.taskId)
              .toList();

          if (tasks.isNotEmpty) {
            tabs.add({
              "type": "option_chain",
              "title": task.tabTitle,
              "taskId": task.taskId
            });
          } else {
            final payoffTasks =
                recipe.tasks.whereType<ShowPayOffGraphTask>().toList();

            if (payoffTasks.isNotEmpty) {
              tabs.add({
                "type": "payoff",
                "title": task.tabTitle,
                "taskId": task.taskId
              });
            } else {
              final insightsTasks = recipe.tasks
                  .whereType<ShowInsightsPageTask>()
                  .where((t) => t.id == task.taskId)
                  .toList();

              if (insightsTasks.isNotEmpty) {
                tabs.add({
                  "type": "insights",
                  "title": task.tabTitle,
                  "taskId": task.taskId,
                });
              }
            }
          }
        });
        onTaskFinish();
        break;
      case TaskType.removeTab:
        setState(() {
          final task = currentTask as RemoveTabTask;
          tabs.removeWhere((tab) => tab["title"] == task.tabTitle);
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
        final targetTabTask =
            addTabTasks.firstWhere((t) => t.taskId == task.tabTaskID);
        final targetTab = tabs.firstWhere(
          (tab) => tab["title"] == targetTabTask.tabTitle,
          orElse: () => tabs.first,
        );
        final targetTabIndex = tabs.indexOf(targetTab);

        navigateToPage(targetTabIndex).then((_) {
          onTaskFinish();
        });
        break;
      case TaskType.popUpTask:
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((c) {
          showDialog(
              context: context,
              builder: (context) {
                ShowPopupTask task = currentTask as ShowPopupTask;
                return AlertDialog(
                  title: Text(task.title),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(task.description),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(task.buttonText),
                    ),
                  ],
                );
              }).then((_) {
            onTaskFinish();
          });
        });
        setState(() {});
        break;
      case TaskType.showBottomSheet:
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((c) {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                ShowBottomSheetTask task = currentTask as ShowBottomSheetTask;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(task.description),
                          if (task.showImage) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Center(
                                  child: Text('Image Placeholder')),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (task.secondaryButtonText != null) ...[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(task.secondaryButtonText!),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(task.primaryButtonText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).then((_) {
            onTaskFinish();
          });
        });
        setState(() {});
        break;
      case TaskType.showInsightsPage:
        setState(() {});
        onTaskFinish();
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
                child: Column(
                  children: [
                    Text(promptText),
                    hintText.isNotEmpty ? Text(hintText) : Container()
                  ],
                ),
              ),
            ),
          ),
          Text(tabs.toString()),
          Expanded(
            flex: 6,
            child: PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  switch (tab["type"]) {
                    case "chart":
                      return Chart.from(
                          key: _chartKey,
                          recipe: recipe,
                          onInteraction: (p0, p1) {});
                    case "option_chain":
                      final taskId = tab["taskId"]!;
                      final chooseTask = recipe.tasks
                          .whereType<ChooseCorrectOptionValueChainTask>()
                          .firstWhere((t) => t.taskId == taskId);

                      final optionChainTask = optionChainTasks.firstWhere(
                        (t) => t.optionChainId == chooseTask.taskId,
                        orElse: () => optionChainTasks.first,
                      );

                      return PreviewScreen.from(
                          key: previewScreenKeys[taskId] ?? _previewScreenKey,
                          task: optionChainTask,
                          isEditorMode: false);
                    case "payoff":
                      final taskId = tab["taskId"]!;
                      final payoffTask = payoffGraphTasks.firstWhere(
                        (t) => t.id == taskId,
                        orElse: () => payoffGraphTasks.first,
                      );
                      return Container(
                        color: Colors.blue,
                        child: Center(
                          child: Text("Payoff Graph View for ${payoffTask.id}"),
                        ),
                      );
                    case "insights":
                      final taskId = tab["taskId"]!;
                      final insightsTask = recipe.tasks
                          .whereType<ShowInsightsPageTask>()
                          .firstWhere((t) => t.id == taskId);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insightsTask.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              insightsTask.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
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
      case TaskType.popUpTask:
      case TaskType.showBottomSheet:
      case TaskType.showInsightsPage:
        return Container();
    }
  }
}
