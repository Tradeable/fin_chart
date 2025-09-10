import 'dart:convert';
import 'package:example/dialog/add_tab_dialog.dart';
import 'package:example/dialog/choose_bucket_rows_dialog.dart';
import 'package:example/dialog/edit_added_tab_dialog.dart';
import 'package:example/dialog/edit_move_tab_dialog.dart';
import 'package:example/dialog/edit_payoff_graph_dialog.dart';
import 'package:example/dialog/show_all_added_tabs_dialog.dart';
import 'package:example/dialog/show_all_option_chains_dialog.dart';
import 'package:example/dialog/show_bottom_sheet_dialog.dart';
import 'package:example/dialog/show_insights_page_dialog.dart';
import 'package:example/dialog/show_insights_pagev2_dialog.dart';
import 'package:example/dialog/show_option_chain_by_id.dart';
import 'package:example/dialog/show_payoff_graph_dialog.dart';
import 'package:example/dialog/show_popup_dialog.dart';
import 'package:example/dialog/show_table_task_dialog.dart';
import 'package:example/editor/ui/pages/chart_demo.dart';
import 'package:example/dialog/add_data_dialog.dart';
import 'package:example/editor/ui/widget/markdown_textfield.dart';
import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/mcq_arrangment_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/indicators/ev_ebitda.dart';
import 'package:fin_chart/models/indicators/ev_sales.dart';
import 'package:fin_chart/models/indicators/pivot_point.dart';
import 'package:fin_chart/models/indicators/pe.dart';
import 'package:fin_chart/models/indicators/pb.dart';
import 'package:fin_chart/models/indicators/scanner_indicator.dart';
import 'package:fin_chart/models/indicators/supertrend.dart';
import 'package:fin_chart/models/indicators/vwap.dart';
import 'package:fin_chart/models/region/main_plot_region.dart';
import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/choose_correct_option_chain_task.dart';
import 'package:fin_chart/models/tasks/clear_bucket_rows_task.dart';
import 'package:fin_chart/models/tasks/highlight_table_row_task.dart';
import 'package:fin_chart/models/tasks/show_bottom_sheet.task.dart';
import 'package:fin_chart/models/tasks/show_sidenav.task.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';
import 'package:fin_chart/models/tasks/table_task.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:example/editor/ui/widget/blinking_text.dart';
import 'package:example/editor/ui/widget/indicator_type_dropdown.dart';
import 'package:example/editor/ui/widget/layer_type_dropdown.dart';
import 'package:example/editor/ui/widget/task_list_widget.dart';
import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/layers/arrow.dart';
import 'package:fin_chart/models/layers/circular_area.dart';
import 'package:fin_chart/models/layers/horizontal_line.dart';
import 'package:fin_chart/models/layers/label.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/layers/rect_area.dart';
import 'package:fin_chart/models/layers/trend_line.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/ui/add_event_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:example/dialog/add_option_chain_dialog.dart';
import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
import 'package:example/dialog/clear_bucket_rows_dialog.dart';
import 'package:example/dialog/show_highlight_table_row_dialog.dart';

class EditorPage extends StatefulWidget {
  final String? recipeStr;

  const EditorPage({super.key, this.recipeStr});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final GlobalKey<ChartState> _chartKey = GlobalKey();
  List<ICandle> candleData = [];
  List<Task> tasks = [];
  int insertPosition = -1;

  LayerType? _selectedLayerType;
  IndicatorType? _selectedIndicatorType;
  List<Offset> drawPoints = [];
  Offset startingPoint = Offset.zero;
  PlotRegion? selectedRegion;

  TaskType? _currentTaskType;

  bool _isRecording = false;

  Recipe? recipe;

  List<FundamentalEvent> fundamentalEvents = [];
  bool isWaitingForEventPosition = false;
  FundamentalEvent? selectedEvent;

  ChartType _chartType = ChartType.candlestick;

  Timer? _autosaveTimer;
  static const String _savedRecipeKey = 'saved_recipe';

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: _currentTaskType != null
          ? BlinkingText(text: "Waiting for ${_currentTaskType?.name}")
          : _isRecording
              ? const BlinkingText(
                  text: "RECORDING",
                  style: TextStyle(color: Colors.red, fontSize: 24),
                )
              : const Text("Trade:able Charts"),
      actions: [
        // ElevatedButton(
        //     onPressed: () {
        //       //log(jsonEncode(_chartKey.currentState?.toJson()));
        //       //_chartKey.currentState?.addIndicator(Rsi());
        //     },
        //     child: const Text("Action")),
        // const SizedBox(
        //   width: 20,
        // ),
        if (selectedEvent != null)
          IconButton(
            onPressed: _deleteSelectedEvent,
            icon: const Icon(Icons.delete),
            tooltip: "Delete Event",
          ),
        Switch(
          value: _isRecording,
          onChanged: (value) {
            setState(() {
              _isRecording = value;
              if (value) {
                _currentTaskType = null;
              }
            });
          },
        ),
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartDemo(
                        recipeDataJson: jsonEncode(Recipe(
                      data: candleData,
                      chartSettings: _chartKey.currentState!.getChartSettings(),
                      tasks: tasks,
                      fundamentalEvents: fundamentalEvents,
                    ).toJson())),
                  ));
            },
            iconSize: 42,
            icon: const Icon(Icons.play_arrow_rounded)),

        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(
                    text: jsonEncode(Recipe(
                            data: candleData,
                            chartSettings:
                                _chartKey.currentState!.getChartSettings(),
                            tasks: tasks,
                            fundamentalEvents: fundamentalEvents)
                        .toJson())))
                .then((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("recipe to clipboar")));
              }
            });
          },
          iconSize: 42,
          icon: const Icon(Icons.copy_all_rounded),
        )
      ],
    );
  }

  void _deleteSelectedEvent() {
    if (selectedEvent != null) {
      setState(() {
        fundamentalEvents.removeWhere((event) => event.id == selectedEvent!.id);
        // Update the chart to reflect the removal
        for (var region in _chartKey.currentState!.regions) {
          if (region is MainPlotRegion) {
            region.fundamentalEvents
                .removeWhere((event) => event.id == selectedEvent!.id);
          }
        }
        selectedEvent = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.recipeStr != null) {
      recipe = Recipe.fromJson(jsonDecode(widget.recipeStr!));
      _chartType = recipe!.chartSettings.chartType;
      populateRecipe(recipe!);
    }

    // Setup autosave timer
    _autosaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveCurrentRecipe();
    });
  }

  void _saveCurrentRecipe() {
    if (candleData.isEmpty) return; // Don't save empty states

    try {
      final recipeData = Recipe(
        data: candleData,
        chartSettings: _chartKey.currentState!.getChartSettings(),
        tasks: tasks,
        fundamentalEvents: fundamentalEvents,
      );

      final jsonString = jsonEncode(recipeData.toJson());
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_savedRecipeKey, jsonString);
        if (kDebugMode) {
          print('Chart recipe autosaved successfully.');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error autosaving chart recipe: $e');
      }
    }
  }

  populateRecipe(Recipe recipe) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      candleData.addAll(recipe.data);
      _chartKey.currentState?.addData(candleData);
      tasks.addAll(recipe.tasks);
      fundamentalEvents.addAll(recipe.fundamentalEvents ?? []);
      for (Task task in tasks) {
        switch (task.taskType) {
          case TaskType.addPrompt:
          case TaskType.waitTask:
          case TaskType.addMcq:
          case TaskType.clearTask:
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
          case TaskType.chooseBucketRows:
          case TaskType.clearBucketRows:
          case TaskType.tableTask:
          case TaskType.highlightTableRow:
          case TaskType.showInsightsV2Page:
          case TaskType.showSideNav:
            break;
          case TaskType.addData:
            VerticalLine layer = VerticalLine.fromRecipe(
                id: (task as AddDataTask).verticleLineId,
                pos: (task).tillPoint.toDouble() - 1);
            layer.isLocked = true;
            _chartKey.currentState?.addLayerAtRegion(
                recipe.chartSettings.mainPlotRegionId, layer);
            break;
          case TaskType.addIndicator:
            _chartKey.currentState
                ?.addIndicator((task as AddIndicatorTask).indicator);
            break;
          case TaskType.addLayer:
            AddLayerTask t = task as AddLayerTask;
            _chartKey.currentState?.addLayerAtRegion(t.regionId, t.layer);
            break;
        }
      }
    });
  }

  _updateTaskList(Task task) {
    setState(() {
      tasks.insert(insertPosition, task);
      _currentTaskType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(flex: 1, child: _buildTaskListWidget()),
          Expanded(
              flex: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.withAlpha(50)
                      : Colors.white.withAlpha(100),
                ),
                child: widget.recipeStr == null
                    ? Chart(
                        key: _chartKey,
                        candles: candleData,
                        onLayerSelect: _onLayerSelect,
                        onRegionSelect: _onRegionSelect,
                        onIndicatorSelect: _onIndicatorSelect,
                        onInteraction: _onInteraction,
                        chartType: _chartType,
                      )
                    : Chart.from(
                        key: _chartKey,
                        recipe: recipe!,
                        onLayerSelect: _onLayerSelect,
                        onRegionSelect: _onRegionSelect,
                        onIndicatorSelect: _onIndicatorSelect,
                        onInteraction: _onInteraction),
              )),
          Expanded(flex: 1, child: _buildToolBox()),
        ],
      )),
    );
  }

  _onLayerSelect(PlotRegion region, Layer layer) {
    if (_currentTaskType == TaskType.addLayer) {
      _updateTaskList(AddLayerTask(regionId: region.id, layer: layer));
    }
  }

  void _onRegionSelect(PlotRegion region) {
    selectedRegion = region;

    // Check if the region has a selected event
    if (region is MainPlotRegion && region.selectedEvent != null) {
      setState(() {
        selectedEvent = region.selectedEvent;
      });
    } else {
      setState(() {
        selectedEvent = null;
      });
    }
  }

  _onIndicatorSelect(Indicator indicator) {
    if (_currentTaskType == TaskType.addIndicator) {
      _updateTaskList(AddIndicatorTask(indicator: indicator));
    }
  }

  _onInteraction(Offset tapDownPoint, Offset updatedPoint) {
    if (_selectedLayerType != null) {
      drawPoints.add(tapDownPoint);
      startingPoint = updatedPoint;
      Layer? layer;
      switch (_selectedLayerType) {
        case LayerType.label:
          layer = Label.fromTool(
              pos: drawPoints.first,
              label: "Text",
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold));
          break;
        case LayerType.trendLine:
          if (drawPoints.length >= 2) {
            layer = TrendLine.fromTool(
                from: drawPoints.first,
                to: drawPoints.last,
                startPoint: startingPoint);
          } else {
            layer = null;
          }
          break;
        case LayerType.horizontalLine:
          layer = HorizontalLine.fromTool(value: drawPoints.first.dy);
          break;
        case LayerType.horizontalBand:
          layer = HorizontalBand.fromTool(
              value: drawPoints.first.dy, allowedError: 70);
          break;
        case LayerType.rectArea:
          if (drawPoints.length >= 2) {
            layer = RectArea.fromTool(
                topLeft: drawPoints.first,
                bottomRight: drawPoints.last,
                dragStartPos: startingPoint);
          } else {
            layer = null;
          }
          break;
        case LayerType.circularArea:
          layer = CircularArea.fromTool(point: drawPoints.first);
          break;
        case LayerType.arrow:
          if (drawPoints.length >= 2) {
            layer = Arrow.fromTool(
                from: drawPoints.first,
                to: drawPoints.last,
                startPoint: startingPoint);
          } else {
            layer = null;
          }
          break;
        case LayerType.verticalLine:
          layer = VerticalLine.fromTool(pos: tapDownPoint.dx);
          layer.isLocked = true;
          int fromPoint = 0;
          for (Task task in tasks) {
            if (task is AddDataTask) {
              if (tapDownPoint.dx.round() < task.tillPoint) {
                task.fromPoint = tapDownPoint.dx.round() + 1;
                break;
              } else {
                fromPoint = task.tillPoint;
              }
            }
          }
          _updateTaskList(AddDataTask(
              fromPoint: fromPoint,
              tillPoint: tapDownPoint.dx.round() + 1,
              verticleLineId: layer.id));
          break;
        case null:
          layer = null;
          break;
        case LayerType.parallelChannel:
          if (drawPoints.length >= 2) {
            layer = ParallelChannel.fromTool(
                topLeft: drawPoints.first,
                bottomRight: drawPoints.last,
                dragPoint: startingPoint);
          } else {
            layer = null;
          }
          break;
        case LayerType.arrowTextPointer:
          layer = ArrowTextPointer.fromTool(pos: drawPoints.first, label: "");
          break;
      }
      setState(() {
        if (layer != null) {
          _selectedLayerType = null;
          drawPoints.clear();
          layer.updateRegionProp(
              leftPos: selectedRegion!.leftPos,
              topPos: selectedRegion!.topPos,
              rightPos: selectedRegion!.rightPos,
              bottomPos: selectedRegion!.bottomPos,
              xStepWidth: selectedRegion!.xStepWidth,
              xOffset: selectedRegion!.xOffset,
              yMinValue: selectedRegion!.yMinValue,
              yMaxValue: selectedRegion!.yMaxValue);
          _chartKey.currentState?.addLayerUsingTool(layer);
        }
      });
    }
    if (isWaitingForEventPosition) {
      setState(() {
        isWaitingForEventPosition = false;
        DateTime candleDate = candleData[tapDownPoint.dx.round()].date;

        // Show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddEventDialog(
              index: tapDownPoint.dx.round(),
              onEventAdded: (event) {
                setState(() {
                  _chartKey.currentState?.addFundamentalEvent(event);
                  fundamentalEvents.add(event);
                });
              },
              preSelectedDate: candleDate,
            );
          },
        );
      });
    }
  }

  Widget _buildTaskListWidget() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(100),
      ),
      child: TaskListWidget(
        task: tasks,
        onTaskAdd: _onTaskAdd,
        onTaskClick: _onTaskClick,
        onTaskEdit: _onTaskEdit,
        onTaskDelete: _onTaskDelete,
      ),
    );
  }

  _onTaskAdd(TaskType taskType, int pos) {
    setState(() {
      switch (taskType) {
        case TaskType.addIndicator:
        case TaskType.addLayer:
          _currentTaskType = taskType;
          break;
        case TaskType.addData:
          _chartKey.currentState
              ?.updateLayerGettingAddedState(LayerType.verticalLine);
          _currentTaskType = taskType;
          _selectedLayerType = LayerType.verticalLine;
          break;
        case TaskType.addPrompt:
          prompt();
          break;
        case TaskType.waitTask:
          waitTaskPrompt();
          break;
        case TaskType.addMcq:
          mcqPrompt();
          break;
        case TaskType.clearTask:
          if (pos >= 0 && pos <= tasks.length) {
            insertPosition = pos;
          } else {
            insertPosition = tasks.length;
          }
          _updateTaskList(ClearTask());
          break;
        case TaskType.addOptionChain:
          optionChainPrompt();
          break;
        case TaskType.chooseCorrectOptionChainValue:
          showOptionChain();
          break;
        case TaskType.highlightCorrectOptionChainValue:
          selectOptionChainToHighlight();
          break;
        case TaskType.showPayOffGraph:
          showPayoffGraphTemplate();
          break;
        case TaskType.addTab:
          showAddTab();
          break;
        case TaskType.removeTab:
          showAllAddedTabs();
          break;
        case TaskType.moveTab:
          moveToTab();
          break;
        case TaskType.popUpTask:
          showPopupTask();
          break;
        case TaskType.showBottomSheet:
          showBottomSheetTask();
          break;
        case TaskType.showInsightsPage:
          showInsightsPageTask();
          break;
        case TaskType.chooseBucketRows:
          showChooseBucketRows();
          break;
        case TaskType.clearBucketRows:
          showClearBucketRows();
          break;
        case TaskType.tableTask:
          showTableTask();
          break;
        case TaskType.highlightTableRow:
          highlightTableRowPrompt();
          break;
        case TaskType.showInsightsV2Page:
          showInsightsPageV2Task();
          break;
        case TaskType.showSideNav:
          showSideNavTask();
          break;
      }
      if (pos >= 0 && pos <= tasks.length) {
        insertPosition = pos;
      } else {
        insertPosition = tasks.length;
      }
    });
  }

  _onTaskClick(Task task) {
    task.buildDialog(context: context);
  }

  _onTaskEdit(Task task) {
    switch (task.taskType) {
      case TaskType.addData:
      case TaskType.addIndicator:
      case TaskType.addLayer:
      case TaskType.clearTask:
        break;
      case TaskType.addPrompt:
        editPrompt(task as AddPromptTask);
        break;
      case TaskType.waitTask:
        editWaitTask(task as WaitTask);
        break;
      case TaskType.addMcq:
        editMcqPrompt(task as AddMcqTask);
        break;
      case TaskType.addOptionChain:
        editOptionChain(task as AddOptionChainTask);
        break;
      case TaskType.chooseCorrectOptionChainValue:
        editHighlightedOptionChainData(
            task as ChooseCorrectOptionValueChainTask);
        break;
      case TaskType.highlightCorrectOptionChainValue:
        selectOptionChainToHighlight();
        break;
      case TaskType.showPayOffGraph:
        editPayoffGraph(task as ShowPayOffGraphTask);
        break;
      case TaskType.addTab:
        editAddedTab(task as AddTabTask);
        break;
      case TaskType.removeTab:
        break;
      case TaskType.moveTab:
        editMoveToTab(task as MoveTabTask);
        break;
      case TaskType.popUpTask:
        editPopupTask(task as ShowPopupTask);
        break;
      case TaskType.showBottomSheet:
        editBottomSheetTask(task as ShowBottomSheetTask);
        break;
      case TaskType.showInsightsPage:
        editInsightsPageTask(task as ShowInsightsPageTask);
        break;
      case TaskType.chooseBucketRows:
        editChooseBucketRows(task as ChooseBucketRowsTask);
        break;
      case TaskType.clearBucketRows:
        editClearBucketRows(task as ClearBucketRowsTask);
        break;
      case TaskType.tableTask:
        editTableTask(task as TableTask);
        break;
      case TaskType.highlightTableRow:
        editHighlightTableRowTask(task as HighlightTableRowTask);
        break;
      case TaskType.showInsightsV2Page:
        editInsightsPageV2Task(task as ShowInsightsPageV2Task);
        break;
      case TaskType.showSideNav:
        editShowSideNavTask(task as ShowSideNavTask);
        break;
    }
  }

  _onTaskDelete(Task task) {
    setState(() {
      tasks.removeWhere((t) => t == task);
      if (task is AddDataTask) {
        _chartKey.currentState?.removeLayerById(task.verticleLineId);
      }
    });
  }

  void prompt() async {
    await showPromptDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editPrompt(AddPromptTask task) async {
    await showPromptDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          setState(() {
            task.promptText = data.promptText;
            task.isExplanation = data.isExplanation;
          });
        }
      });
    });
  }

  void waitTaskPrompt() async {
    await showWaitTaskDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editWaitTask(WaitTask task) async {
    await showWaitTaskDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          task.btnText = data.btnText;
        }
      });
    });
  }

  void mcqPrompt() async {
    await showMcqTaskDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editMcqPrompt(AddMcqTask task) async {
    await showMcqTaskDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          task.isMultiSelect = data.isMultiSelect;
          task.arrangementType = data.arrangementType;
          task.options = data.options;
          task.correctOptionIndices = data.correctOptionIndices;
        }
      });
    });
  }

  void optionChainPrompt() async {
    await showOptionChainDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  Future<void> editOptionChain(AddOptionChainTask task) async {
    await showOptionChainDialog(context: context, initialTask: task)
        .then((data) {
      setState(() {
        if (data != null) {
          task.strikePrice = data.strikePrice;
          task.data = data.data;
          task.visibility = data.visibility;
          task.columns = data.columns;
          task.expiryDate = data.expiryDate;
          task.interval = data.interval;
          task.settings = data.settings;
        }
      });
    });
  }

  void showOptionChain() async {
    final highlightedDataTask =
        await showOptionChainById(context: context, tasks: tasks);
    if (highlightedDataTask != null) {
      _updateTaskList(highlightedDataTask);
    }
  }

  void showAddTab() async {
    final chooseTab = await addTabDialog(context: context, tasks: tasks);
    if (chooseTab != null) {
      _updateTaskList(chooseTab);
    }
  }

  void editAddedTab(AddTabTask task) async {
    await editTabDialog(context: context, task: task).then((data) {
      setState(() {
        if (data != null) {
          task.tabTitle = data.tabTitle;
        }
      });
    });
  }

  void showAllAddedTabs() async {
    final removeTab = await removeAddedTab(context: context, tasks: tasks);
    if (removeTab != null) {
      _updateTaskList(removeTab);
    }
  }

  void showPayoffGraphTemplate() async {
    final payOffData = await showPayOffGraphDialog(context: context);
    if (payOffData != null) {
      _updateTaskList(payOffData);
    }
  }

  Future<void> editHighlightedOptionChainData(
      ChooseCorrectOptionValueChainTask task) async {
    await showOptionChainById(
      context: context,
      tasks: tasks,
      initialTask: task,
    ).then((data) {
      setState(() {
        if (data != null) {
          task.taskId = data.taskId;
          task.maxSelectableRows = data.maxSelectableRows;
        }
      });
    });
  }

  Future<void> selectOptionChainToHighlight() async {
    final selectedOptionChain =
        await showAllOptionChains(context: context, tasks: tasks);
    if (selectedOptionChain != null) {
      _updateTaskList(selectedOptionChain);
    }
  }

  Future<AddPromptTask?> showPromptDialog({
    required BuildContext context,
    String title = 'Enter Text',
    String okButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    AddPromptTask? initialTask,
    int? maxLines = 5,
    TextInputType keyboardType = TextInputType.multiline,
  }) async {
    final TextEditingController promptController =
        TextEditingController(text: initialTask?.promptText ?? '');
    final TextEditingController hintController =
        TextEditingController(text: initialTask?.hint ?? '');
    bool isExplanation = initialTask?.isExplanation ?? false;

    return showDialog<AddPromptTask>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MarkdownTextField(
                              controller: promptController,
                              hint: "Enter Prompt"),
                        )),
                    const SizedBox(height: 16),
                    Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MarkdownTextField(
                              controller: hintController, hint: "Enter Hint"),
                        )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isExplanation,
                          onChanged: (bool? value) {
                            setState(() {
                              isExplanation = value ?? false;
                            });
                          },
                        ),
                        const Text('Is Explanation'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Returns null
                  },
                  child: Text(cancelButtonText),
                ),
                TextButton(
                  onPressed: () {
                    final promptText = promptController.text.trim();
                    final hintText = hintController.text.trim();
                    if (promptText.isNotEmpty) {
                      final task = AddPromptTask(
                        promptText: promptText,
                        isExplanation: isExplanation,
                        hint: hintText.isNotEmpty ? hintText : null,
                      );
                      Navigator.of(context).pop(task);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(okButtonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<WaitTask?> showWaitTaskDialog({
    required BuildContext context,
    WaitTask? initialTask,
  }) {
    final TextEditingController textController = TextEditingController(
      text: initialTask?.btnText ?? 'Done',
    );

    final List<String> quickOptions = [
      'Done',
      'Understood',
      "Let's Go",
      "Okay",
      "Got it",
      "Next"
    ];

    return showDialog<WaitTask>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Button Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Enter text for button',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(WaitTask(btnText: value));
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Quick Select:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: quickOptions.map((option) {
                  return ActionChip(
                    label: Text(option),
                    onPressed: () {
                      textController.text = option;
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(context).pop(WaitTask(btnText: text));
                } else {
                  // If empty, use default "Done"
                  Navigator.of(context).pop(WaitTask(btnText: 'Done'));
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<AddMcqTask?> showMcqTaskDialog({
    required BuildContext context,
    AddMcqTask? initialTask,
  }) async {
    // Initialize state based on initialTask or defaults
    bool isMultiSelect = initialTask?.isMultiSelect ?? false;
    MCQArrangementType arrangementType =
        initialTask?.arrangementType ?? MCQArrangementType.grid1x2;
    List<String> options =
        initialTask?.options != null && initialTask!.options.isNotEmpty
            ? List<String>.from(initialTask.options)
            : ['', ''];

    // Convert correctOptionIndices to selectedOptions boolean array
    List<bool> selectedOptions =
        List.generate(options.length, (index) => false);
    if (initialTask != null) {
      for (String index in initialTask.correctOptionIndices) {
        int idx = int.tryParse(index) ?? -1;
        if (idx >= 0 && idx < selectedOptions.length) {
          selectedOptions[idx] = true;
        }
      }
    }

    // Quick options for MCQ
    final List<String> quickOptions = [
      'True',
      'False',
      'Yes',
      'No',
      'Up',
      'Down',
      'Correct',
      'Incorrect',
      'All of the above',
      'None of the above'
    ];

    return showDialog<AddMcqTask>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Current selected option for quick option insertion
            int selectedOptionIndex = 0;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isMultiSelect,
                          onChanged: (value) {
                            setState(() {
                              isMultiSelect = value ?? false;

                              // If switching to single select and multiple options are selected,
                              // keep only the first selected option
                              if (!isMultiSelect &&
                                  selectedOptions.where((so) => so).length >
                                      1) {
                                int firstSelectedIndex =
                                    selectedOptions.indexOf(true);
                                for (int i = 0;
                                    i < selectedOptions.length;
                                    i++) {
                                  selectedOptions[i] =
                                      (i == firstSelectedIndex);
                                }
                              }
                            });
                          },
                        ),
                        const Text('Allow multiple selections'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Arrangement type dropdown
                    Row(
                      children: [
                        const Text('Arrangement: '),
                        const SizedBox(width: 16),
                        DropdownButton<MCQArrangementType>(
                          value: arrangementType,
                          onChanged: (MCQArrangementType? newValue) {
                            if (newValue != null) {
                              setState(() {
                                arrangementType = newValue;
                              });
                            }
                          },
                          items: MCQArrangementType.values
                              .map((MCQArrangementType type) {
                            return DropdownMenuItem<MCQArrangementType>(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Options',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    // List of options
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final TextEditingController optionController =
                              TextEditingController(text: options[index]);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                // Checkbox for correct option
                                Checkbox(
                                  value: selectedOptions[index],
                                  onChanged: (value) {
                                    setState(() {
                                      if (isMultiSelect) {
                                        selectedOptions[index] = value ?? false;
                                      } else {
                                        // For single select, uncheck all others
                                        for (int i = 0;
                                            i < selectedOptions.length;
                                            i++) {
                                          selectedOptions[i] =
                                              i == index && (value ?? false);
                                        }
                                      }
                                    });
                                  },
                                ),

                                // Option text field
                                Expanded(
                                  child: TextField(
                                    controller: optionController,
                                    decoration: InputDecoration(
                                      hintText: 'Option ${index + 1}',
                                      border: const OutlineInputBorder(),
                                      // Add a small button to select this field for quick options
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        tooltip: 'Apply quick option',
                                        onPressed: () {
                                          // Set the selected index for quick options
                                          selectedOptionIndex = index;
                                          // Show bottom sheet with quick options
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Quick Options for Option ${index + 1}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: quickOptions
                                                          .map((option) {
                                                        return ActionChip(
                                                          label: Text(option),
                                                          onPressed: () {
                                                            // Apply the selected quick option
                                                            setState(() {
                                                              options[selectedOptionIndex] =
                                                                  option;
                                                              optionController
                                                                      .text =
                                                                  option;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    onChanged: (value) {
                                      options[index] = value;
                                    },
                                  ),
                                ),

                                // Remove option button
                                if (options.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        options.removeAt(index);
                                        selectedOptions.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Quick options section
                    const SizedBox(height: 16),
                    Text(
                      'Quick Options:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // True/False preset
                        ActionChip(
                          label: const Text('Add True/False'),
                          onPressed: () {
                            setState(() {
                              options = ['True', 'False'];
                              selectedOptions = [false, false];
                            });
                          },
                        ),
                        // Yes/No preset
                        ActionChip(
                          label: const Text('Add Yes/No'),
                          onPressed: () {
                            setState(() {
                              options = ['Yes', 'No'];
                              selectedOptions = [false, false];
                            });
                          },
                        ),
                        // Up/Down preset
                        ActionChip(
                          label: const Text('Add Up/Down'),
                          onPressed: () {
                            setState(() {
                              options = ['Up', 'Down'];
                              selectedOptions = [false, false];
                            });
                          },
                        ),
                      ],
                    ),

                    // Add option button
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Option'),
                      onPressed: () {
                        setState(() {
                          options.add('');
                          selectedOptions.add(false);
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Returns null
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Validate
                            if (!selectedOptions.contains(true)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please select at least one correct option')),
                              );
                              return;
                            }

                            if (options
                                .any((option) => option.trim().isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please fill in all options')),
                              );
                              return;
                            }

                            // Create list of correct option indices
                            List<String> correctOptionIndices = [];
                            for (int i = 0; i < selectedOptions.length; i++) {
                              if (selectedOptions[i]) {
                                correctOptionIndices.add(i.toString());
                              }
                            }

                            // Create the task (preserve original id if editing)
                            final task = initialTask != null
                                ? AddMcqTask(
                                    isMultiSelect: isMultiSelect,
                                    arrangementType: arrangementType,
                                    options: options,
                                    correctOptionIndices: correctOptionIndices,
                                  )
                                : AddMcqTask(
                                    isMultiSelect: isMultiSelect,
                                    arrangementType: arrangementType,
                                    options: options,
                                    correctOptionIndices: correctOptionIndices,
                                  );

                            Navigator.of(context).pop(task);
                          },
                          child:
                              Text(initialTask != null ? 'Update' : 'Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void editPayoffGraph(ShowPayOffGraphTask task) async {
    await editPayoffGraphDialog(context: context, task: task).then((data) {
      setState(() {
        if (data != null) {
          task.quantity = data.quantity;
          task.spotPrice = data.spotPrice;
          task.spotPriceDayDelta = data.spotPriceDayDelta;
          task.spotPriceDayDeltaPer = data.spotPriceDayDeltaPer;
        }
      });
    });
  }

  void editMoveToTab(MoveTabTask task) async {
    await editMoveTabDialog(context: context, task: task, tasks: tasks)
        .then((data) {
      setState(() {
        if (data != null) {
          task.tabTaskID = data.tabTaskID;
        }
      });
    });
  }

  void moveToTab() async {
    final moveTab = await editMoveTabDialog(
      context: context,
      task: MoveTabTask(tabTaskID: ''),
      tasks: tasks,
    );
    if (moveTab != null) {
      _updateTaskList(moveTab);
    }
  }

  void showPopupTask() async {
    await showPopupDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editPopupTask(ShowPopupTask task) async {
    await showPopupDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          task.title = data.title;
          task.description = data.description;
          task.buttonText = data.buttonText;
        }
      });
    });
  }

  void showBottomSheetTask() async {
    await showBottomSheetDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editBottomSheetTask(ShowBottomSheetTask task) async {
    await showBottomSheetDialog(context: context, initialTask: task)
        .then((data) {
      setState(() {
        if (data != null) {
          task.title = data.title;
          task.showImage = data.showImage;
          task.primaryButtonText = data.primaryButtonText;
          task.secondaryButtonText = data.secondaryButtonText;
        }
      });
    });
  }

  void showInsightsPageTask() async {
    await showInsightsPageDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editInsightsPageTask(ShowInsightsPageTask task) async {
    await showInsightsPageDialog(context: context, initialTask: task)
        .then((data) {
      setState(() {
        if (data != null) {
          task.title = data.title;
          task.description = data.description;
        }
      });
    });
  }

  void showInsightsPageV2Task() async {
    await showInsightsPageV2Dialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editInsightsPageV2Task(ShowInsightsPageV2Task task) async {
    await showInsightsPageV2Dialog(context: context, initialTask: task)
        .then((data) {
      setState(() {
        if (data != null) {
          task.title = data.title;
          task.blocks = data.blocks;
        }
      });
    });
  }

  void showSideNavTask() async {
    await showSideNavDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editShowSideNavTask(ShowSideNavTask task) async {
    await showSideNavDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          task.title = data.title;
          task.primaryDescription = data.primaryDescription;
          task.secondaryDescription = data.secondaryDescription;
          task.primaryButtonText = data.primaryButtonText;
          task.secondaryButtonText = data.secondaryButtonText;
        }
      });
    });
  }

  Future<ShowSideNavTask?> showSideNavDialog({
    required BuildContext context,
    ShowSideNavTask? initialTask,
  }) async {
    final TextEditingController titleController =
        TextEditingController(text: initialTask?.title ?? '');
    final TextEditingController primaryDescriptionController =
        TextEditingController(text: initialTask?.primaryDescription ?? '');
    final TextEditingController secondaryDescriptionController =
        TextEditingController(text: initialTask?.secondaryDescription ?? '');
    final TextEditingController primaryBtnController = TextEditingController(
        text: initialTask?.primaryButtonText ?? 'Continue');
    final TextEditingController secondaryBtnController =
        TextEditingController(text: initialTask?.secondaryButtonText ?? '');

    return showDialog<ShowSideNavTask>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Side Nav'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Primary Action',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: primaryBtnController,
                        decoration: const InputDecoration(
                          labelText: 'Primary Button Text',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.touch_app),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: primaryDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Primary Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_border,
                              color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Secondary Action (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: secondaryBtnController,
                        decoration: const InputDecoration(
                          labelText: 'Secondary Button Text',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.touch_app),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: secondaryDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Secondary Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final primaryDesc = primaryDescriptionController.text.trim();
                final secondaryDesc =
                    secondaryDescriptionController.text.trim();
                final primary = primaryBtnController.text.trim();
                final secondary = secondaryBtnController.text.trim();

                if (title.isEmpty || primaryDesc.isEmpty || primary.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill required fields')),
                  );
                  return;
                }

                Navigator.of(context).pop(ShowSideNavTask(
                  title: title,
                  primaryButtonText: primary,
                  secondaryButtonText: secondary.isNotEmpty ? secondary : '',
                  primaryDescription: primaryDesc,
                  secondaryDescription:
                      secondaryDesc.isNotEmpty ? secondaryDesc : '',
                ));
              },
              child: Text(initialTask != null ? 'Update' : 'Create'),
            ),
          ],
        );
      },
    );
  }

  void showChooseBucketRows() async {
    final bucketRowsTask = await showChooseBucketRowsDialog(
      context: context,
      tasks: tasks,
    );
    if (bucketRowsTask != null) {
      _updateTaskList(bucketRowsTask);
    }
  }

  Future<void> editChooseBucketRows(ChooseBucketRowsTask task) async {
    await showChooseBucketRowsDialog(
      context: context,
      tasks: tasks,
      initialTask: task,
    ).then((data) {
      setState(() {
        if (data != null) {
          task.optionChainId = data.optionChainId;
          task.bucketRows = data.bucketRows;
          task.maxSelectableRows = data.maxSelectableRows;
        }
      });
    });
  }

  void showClearBucketRows() async {
    final clearBucketRowsTask = await showClearBucketRowsDialog(
      context: context,
      tasks: tasks,
    );
    if (clearBucketRowsTask != null) {
      _updateTaskList(clearBucketRowsTask);
    }
  }

  Future<void> editClearBucketRows(ClearBucketRowsTask task) async {
    await showClearBucketRowsDialog(
      context: context,
      tasks: tasks,
      initialTask: task,
    ).then((data) {
      setState(() {
        if (data != null) {
          task.optionChainId = data.optionChainId;
        }
      });
    });
  }

  void showTableTask() async {
    await showTableTaskDialog(context: context).then((data) {
      if (data != null) {
        _updateTaskList(data);
      }
    });
  }

  void editTableTask(TableTask task) async {
    await showTableTaskDialog(context: context, initialTask: task).then((data) {
      setState(() {
        if (data != null) {
          task.tables = data.tables;
        }
      });
    });
  }

  void highlightTableRowPrompt() async {
    final tableTasks = tasks.whereType<TableTask>().toList();
    if (tableTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No TableTask found. Add a table first.')),
        );
      }
      return;
    }
    String tableTaskId = tableTasks.first.id;
    if (tableTasks.length > 1) {
      final selected = await showDialog<String>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Select Table Task'),
            children: tableTasks
                .map((t) => SimpleDialogOption(
                      child: Text(t.tables.tables.first.tableTitle.isNotEmpty
                          ? t.tables.tables.first.tableTitle
                          : t.id),
                      onPressed: () => Navigator.pop(context, t.id),
                    ))
                .toList(),
          );
        },
      );
      if (selected == null) return;
      tableTaskId = selected;
    }
    final tableTask = tableTasks.firstWhere((t) => t.id == tableTaskId);
    final result = await showHighlightTableRowDialog(
      context: context,
      tableTaskId: tableTaskId,
      tables: tableTask.tables.tables,
    );
    if (result != null) {
      final selectedRows = result.map((k, v) => MapEntry(k, v.toList()));
      _updateTaskList(HighlightTableRowTask(
        tableTaskId: tableTaskId,
        selectedRows: selectedRows,
      ));
    }
  }

  void editHighlightTableRowTask(HighlightTableRowTask task) async {
    final tableTasks = tasks.whereType<TableTask>().toList();
    if (tableTasks.isEmpty) return;
    final tableTask = tableTasks.firstWhere((t) => t.id == task.tableTaskId,
        orElse: () => tableTasks.first);
    final initialSelection =
        task.selectedRows.map((k, v) => MapEntry(k, v.toSet()));
    final result = await showHighlightTableRowDialog(
      context: context,
      tableTaskId: tableTask.id,
      tables: tableTask.tables.tables,
      initialSelection: initialSelection,
    );
    if (result != null) {
      setState(() {
        task.selectedRows = result.map((k, v) => MapEntry(k, v.toList()));
      });
    }
  }

  Widget _buildToolBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        reverse: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              iconSize: 30,
              tooltip: "Toggle Chart Type",
              icon: Icon(_chartType == ChartType.candlestick
                  ? Icons.candlestick_chart
                  : Icons.show_chart),
              onPressed: () {
                setState(() {
                  _chartType = _chartType == ChartType.candlestick
                      ? ChartType.line
                      : ChartType.candlestick;
                  _chartKey.currentState?.setChartType(_chartType);
                });
              },
            ),
            ElevatedButton(
              onPressed: _showAddEventDialog,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    isWaitingForEventPosition ? Colors.tealAccent : null),
              ),
              child: const Text("Add Event"),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
                onPressed: _showAddDataDialog, child: const Text("Add Data")),
            const SizedBox(width: 20),
            IndicatorTypeDropdown(
                selectedType: _selectedIndicatorType,
                onChanged: (indicatorType) {
                  _addIndicator(indicatorType);
                }),
            const SizedBox(width: 20),
            LayerTypeDropdown(
                selectedType: _selectedLayerType,
                onChanged: (layerType) {
                  setState(() {
                    _selectedLayerType = layerType;
                    _chartKey.currentState
                        ?.updateLayerGettingAddedState(layerType);
                  });
                })
          ],
        ),
      ),
    );
  }

  void _showAddDataDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddDataDialog(onDataUpdate: (data) {
            setState(() {
              candleData.addAll(data);
            });
            _chartKey.currentState?.addData(data);
          });
        });
  }

  void _showAddEventDialog() {
    setState(() {
      // Enable waiting mode in chart
      isWaitingForEventPosition = true;
      _chartKey.currentState?.isWaitingForEventPosition = true;
    });
  }

  void _addIndicator(IndicatorType indicatorType) {
    Indicator? indicator;
    switch (indicatorType) {
      case IndicatorType.rsi:
        indicator = Rsi();
        break;
      case IndicatorType.macd:
        indicator = Macd();
        break;
      case IndicatorType.sma:
        indicator = Sma();
        break;
      case IndicatorType.ema:
        indicator = Ema();
        break;
      case IndicatorType.bollingerBand:
        indicator = BollingerBands();
        break;
      case IndicatorType.stochastic:
        indicator = Stochastic();
        break;
      case IndicatorType.atr:
        indicator = Atr();
        break;
      case IndicatorType.mfi:
        indicator = Mfi();
        break;
      case IndicatorType.adx:
        indicator = Adx();
        break;
      case IndicatorType.pivotPoint:
        indicator = PivotPoint();
      case IndicatorType.pe:
        indicator = Pe(getFundamentalEvents: () {
          for (final region in _chartKey.currentState!.regions) {
            if (region is MainPlotRegion) {
              return region.fundamentalEvents;
            }
          }
          return <FundamentalEvent>[];
        });
        break;
      case IndicatorType.pb:
        indicator = Pb(getFundamentalEvents: () {
          for (final region in _chartKey.currentState!.regions) {
            if (region is MainPlotRegion) {
              return region.fundamentalEvents;
            }
          }
          return <FundamentalEvent>[];
        });
        break;
      case IndicatorType.supertrend:
        indicator = Supertrend();
        break;
      case IndicatorType.vwap:
        indicator = Vwap();
        break;
      case IndicatorType.evEbitda:
        indicator = EvEbitda();
        break;
      case IndicatorType.evSales:
        indicator = EvSales();
        break;
      case IndicatorType.scanner:
        indicator = ScannerIndicator();
    }
    _chartKey.currentState?.addIndicator(indicator);
  }

  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _autosaveTimer?.cancel();
    super.dispose();
  }
}
