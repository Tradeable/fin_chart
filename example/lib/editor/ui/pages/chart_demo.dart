import 'dart:convert';
import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/edit_column_visibility.task.dart';
import 'package:fin_chart/models/tasks/highlight_correct_option_chain_value_task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/highlight_table_row_task.dart';
import 'package:fin_chart/models/tasks/show_bottom_sheet.task.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';
import 'package:fin_chart/models/tasks/table_task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/create_option_chain.task.dart';
import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
import 'package:fin_chart/models/tasks/clear_bucket_rows_task.dart';
import 'package:example/editor/ui/widget/table_display_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:example/editor/ui/widgets/side_nav_panel.dart';

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
  List<CreateOptionChainTask> optionChainTasks = [];
  List<ShowPayOffGraphTask> payoffGraphTasks = [];
  List<Map<String, String>> tabs = [];
  int currentPageIndex = 0;
  Map<String, List<GlobalKey<TableDisplayWidgetState>>> tableWidgetKeys = {};
  Map<String, Map<int, Set<int>>> userSelectedRows = {};
  List<ShowSideNavTask> sideNavTasks = [];
  bool isSideNavVisible = false;
  Map<String, String?> sideNavSelectedDesc = {};
  String? expandedSideNavId;

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
      case TaskType.createOptionChain:
        CreateOptionChainTask task = currentTask as CreateOptionChainTask;
        optionChainTasks.add(task);
        onTaskFinish();
        break;
      case TaskType.addOptionChain:
        onTaskFinish();
        break;
      case TaskType.highlightCorrectOptionChainValue:
        HighlightCorrectOptionChainValueTask task =
            currentTask as HighlightCorrectOptionChainValueTask;
        final previewKey =
            previewScreenKeys[task.optionChainId] ?? _previewScreenKey;
        if ((task.bucketRows ?? []).isNotEmpty) {
          previewKey.currentState?.setBuySellSelections(task.bucketRows!);
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

          final optionChainTasks = recipe.tasks
              .whereType<AddOptionChainTask>()
              .where((t) => t.taskId == task.taskId)
              .toList();

          if (optionChainTasks.isNotEmpty) {
            tabs.add({
              "type": "option_chain",
              "title": task.tabTitle,
              "taskId": task.taskId
            });
          }

          final payoffTasks = recipe.tasks
              .whereType<ShowPayOffGraphTask>()
              .where((t) => t.id == task.taskId)
              .toList();

          if (payoffTasks.isNotEmpty) {
            tabs.add({
              "type": "payoff",
              "title": task.tabTitle,
              "taskId": task.taskId
            });
          }

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
          final tableTasks = recipe.tasks
              .whereType<TableTask>()
              .where((t) => t.id == task.taskId)
              .toList();
          if (tableTasks.isNotEmpty) {
            tabs.add({
              "type": "table",
              "title": task.tabTitle,
              "taskId": task.taskId,
            });
          }

          final insightsV2Tasks = recipe.tasks
              .whereType<ShowInsightsPageV2Task>()
              .where((t) => t.id == task.taskId)
              .toList();

          if (insightsV2Tasks.isNotEmpty) {
            tabs.add({
              "type": "insights_v2",
              "title": task.tabTitle,
              "taskId": task.taskId,
            });
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
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10),
                        child: MarkdownWidget(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          data: task.title,
                          config: MarkdownConfig(configs: [
                            H1Config(
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                      Flexible(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: MarkdownWidget(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  data: task.description),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(task.buttonText),
                      ),
                    ],
                  ),
                  // title: Text(task.title),
                  // content: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: SizedBox(
                  //       height: 200,
                  //       width: 200,
                  //       child: MarkdownWidget(
                  //         data: task.description,
                  //         shrinkWrap: true,
                  //         physics: NeverScrollableScrollPhysics(),
                  //       ),
                  //     )),
                  // actions: [
                  //   TextButton(
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Text(task.buttonText),
                  //   ),
                  // ],
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
                          MarkdownWidget(
                            data: task.title,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            config: MarkdownConfig(configs: [
                              H1Config(
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          MarkdownWidget(
                              data: task.description,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true),
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
      case TaskType.showSideNav:
        final task = currentTask as ShowSideNavTask;
        setState(() {
          if (!sideNavTasks.any((t) => t.id == task.id)) {
            sideNavTasks.add(task);
          }
          isSideNavVisible = true;
          expandedSideNavId = task.id;
        });
        break;
      case TaskType.showInsightsPage:
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.chooseBucketRows:
        ChooseBucketRowsTask task = currentTask as ChooseBucketRowsTask;
        final previewKey =
            previewScreenKeys[task.optionChainId] ?? _previewScreenKey;
        if (task.bucketRows != null && task.bucketRows!.isNotEmpty) {
          previewKey.currentState?.setBuySellSelections(task.bucketRows!);
        }
        onTaskFinish();
        break;
      case TaskType.clearBucketRows:
        ClearBucketRowsTask task = currentTask as ClearBucketRowsTask;
        final previewKey =
            previewScreenKeys[task.optionChainId] ?? _previewScreenKey;
        previewKey.currentState?.clearBucketSelections();
        onTaskFinish();
        break;
      case TaskType.tableTask:
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.highlightTableRow:
        final task = currentTask as HighlightTableRowTask;
        final keys = tableWidgetKeys[task.tableTaskId];
        if (keys != null && task.selectedRows.isNotEmpty) {
          task.selectedRows.forEach((tableIdx, rowIndices) {
            if (tableIdx < keys.length) {
              final key = keys[tableIdx];
              key.currentState?.setSelectedRows(rowIndices.toSet());
              userSelectedRows[task.tableTaskId] ??= {};
              userSelectedRows[task.tableTaskId]![tableIdx] =
                  rowIndices.toSet();
            }
          });
        }
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.showInsightsV2Page:
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.editOptionRow:
        final task = currentTask as EditOptionRowTask;
        final createChains =
            recipe.tasks.whereType<CreateOptionChainTask>().toList();
        final chainIdx = createChains
            .indexWhere((t) => t.optionChainId == task.optionChainId);
        if (chainIdx != -1 && task.updatedRow != null) {
          final chain = createChains[chainIdx];
          if (task.rowIndex >= 0 && task.rowIndex < chain.data.length) {
            setState(() {
              chain.data[task.rowIndex] = task.updatedRow!;
            });
          }
        }
        setState(() {});
        onTaskFinish();
        break;
      case TaskType.editColumnVisibility:
        final task = currentTask as EditColumnVisibilityTask;
        final createChains =
            recipe.tasks.whereType<CreateOptionChainTask>().toList();
        final chainIdx = createChains
            .indexWhere((t) => t.optionChainId == task.optionChainId);
        if (chainIdx != -1 && task.updatedColumns.isNotEmpty) {
          final chain = createChains[chainIdx];
          setState(() {
            for (final updated in task.updatedColumns) {
              final idx = chain.columns
                  .indexWhere((c) => c.columnType == updated.columnType);
              if (idx != -1) {
                chain.columns[idx].isColumnVisible = updated.isColumnVisible;
              }
            }
          });
        }
        onTaskFinish();
        break;
      case TaskType.setMaxSelectableRows:
        final task = currentTask as SetMaxSelectableRowsTask;
        final createChains =
            recipe.tasks.whereType<CreateOptionChainTask>().toList();
        final chainIdx = createChains
            .indexWhere((t) => t.optionChainId == task.optionChainId);
        if (chainIdx != -1) {
          final chain = createChains[chainIdx];
          setState(() {
            chain.settings?.maxSelectableRows = task.maxSelectableRows;
          });
        }
        onTaskFinish();
        break;
      case TaskType.toggleBuySellVisibility:
        final task = currentTask as ToggleBuySellVisibilityTask;
        final createChains =
            recipe.tasks.whereType<CreateOptionChainTask>().toList();
        final chainIdx = createChains
            .indexWhere((t) => t.optionChainId == task.optionChainId);
        if (chainIdx != -1) {
          final chain = createChains[chainIdx];
          setState(() {
            chain.settings?.isBuySellVisible = task.isBuySellVisible;
          });
        }
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
          child: Stack(children: [
        if (currentTask.taskType == TaskType.showSideNav && isSideNavVisible)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                closeSideNav(moveToNextNode: true);
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        Row(
          children: [
            Expanded(
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
                            MarkdownWidget(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                data: promptText),
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
                                  .whereType<AddOptionChainTask>()
                                  .firstWhere((t) => t.taskId == taskId);

                              final optionChainTask =
                                  optionChainTasks.firstWhere(
                                (t) => t.optionChainId == chooseTask.taskId,
                                orElse: () => optionChainTasks.first,
                              );

                              return PreviewScreen.from(
                                  key: previewScreenKeys[taskId] ??
                                      _previewScreenKey,
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
                                  child: Text(
                                      "Payoff Graph View for ${payoffTask.id}"),
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
                                    MarkdownWidget(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      data: insightsTask.title,
                                      config: MarkdownConfig(configs: [
                                        H1Config(
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                    ),
                                    const SizedBox(height: 16),
                                    MarkdownWidget(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        data: insightsTask.description),
                                  ],
                                ),
                              );
                            case "table":
                              final taskId = tab["taskId"]!;
                              final tableTask = recipe.tasks
                                  .whereType<TableTask>()
                                  .firstWhere((t) => t.id == taskId);
                              if (!tableWidgetKeys.containsKey(taskId)) {
                                tableWidgetKeys[taskId] = List.generate(
                                  tableTask.tables.tables.length,
                                  (_) => GlobalKey<TableDisplayWidgetState>(),
                                );
                              }
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...tableTask.tables.tables
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final idx = entry.key;
                                      final table = entry.value;
                                      final selectedRows =
                                          userSelectedRows[taskId]?[idx] ??
                                              <int>{};
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              table.tableTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            if (table
                                                .tableDescription.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  table.tableDescription,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                            TableDisplayWidget(
                                              key:
                                                  tableWidgetKeys[taskId]![idx],
                                              columns: table.columns,
                                              rows: table.rows,
                                              selectedRowIndices: selectedRows,
                                              onRowTap: (rowIdx) {
                                                setState(() {
                                                  userSelectedRows[taskId] ??=
                                                      {};
                                                  final selected =
                                                      userSelectedRows[taskId]![
                                                              idx] ??
                                                          <int>{};
                                                  if (selected
                                                      .contains(rowIdx)) {
                                                    selected.remove(rowIdx);
                                                  } else {
                                                    selected.add(rowIdx);
                                                  }
                                                  userSelectedRows[taskId]![
                                                      idx] = selected;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            case "insights_v2":
                              final taskId = tab["taskId"]!;
                              final insightsTask = recipe.tasks
                                  .whereType<ShowInsightsPageV2Task>()
                                  .firstWhere((t) => t.id == taskId);
                              return InsightsPreviewPage(task: insightsTask);
                            default:
                              return Container();
                          }
                        }),
                  ),
                  Expanded(
                      flex: 1,
                      child: FittedBox(
                          fit: BoxFit.none, child: userActionContainer()))
                ],
              ),
            ),
            if (currentTask.taskType == TaskType.showSideNav &&
                isSideNavVisible)
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: _buildSideNavPanel(),
              )
          ],
        )
      ])),
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
      case TaskType.createOptionChain:
      case TaskType.addOptionChain:
      case TaskType.editOptionRow:
      case TaskType.highlightCorrectOptionChainValue:
      case TaskType.showPayOffGraph:
      case TaskType.addTab:
      case TaskType.removeTab:
      case TaskType.moveTab:
      case TaskType.popUpTask:
      case TaskType.showBottomSheet:
      case TaskType.showInsightsPage:
      case TaskType.chooseBucketRows:
      case TaskType.clearBucketRows:
      case TaskType.tableTask:
      case TaskType.highlightTableRow:
      case TaskType.showInsightsV2Page:
      case TaskType.showSideNav:
      case TaskType.editColumnVisibility:
      case TaskType.setMaxSelectableRows:
      case TaskType.toggleBuySellVisibility:
        return Container();
    }
  }

  void closeSideNav({bool moveToNextNode = false}) {
    if (!isSideNavVisible) return;
    setState(() {
      isSideNavVisible = false;
    });
    if (moveToNextNode) {
      onTaskFinish();
    }
  }

  Widget _buildSideNavPanel() {
    return SideNavPanel(
      tasks: sideNavTasks,
      expandedId: expandedSideNavId,
      onExpandedChange: (id) {
        setState(() {
          expandedSideNavId = id;
        });
      },
      selectedDescriptions: sideNavSelectedDesc,
      onDescriptionSelect: (taskId, desc) {
        setState(() {
          sideNavSelectedDesc[taskId] = desc;
        });
      },
    );
  }
}
