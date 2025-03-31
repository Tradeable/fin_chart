import 'dart:convert';

// import 'package:fin_chart/ui/add_event_dialog.dart';
import 'package:example/editor/ui/pages/chart_demo.dart';
import 'package:example/dialog/add_data_dialog.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/indicators/atr.dart';
import 'package:fin_chart/models/indicators/mfi.dart';
import 'package:fin_chart/models/indicators/adx.dart';
// import 'package:fin_chart/models/region/main_plot_region.dart';
import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_prompt.task.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/tasks/wait.task.dart';
import 'package:example/editor/ui/widget/blinking_text.dart';
import 'package:example/editor/ui/widget/indicator_type_dropdown.dart';
import 'package:example/editor/ui/widget/layer_type_dropdown.dart';
import 'package:example/editor/ui/widget/task_list_widget.dart';
import 'package:fin_chart/chart.dart';
import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/bollinger_bands.dart';
import 'package:fin_chart/models/indicators/ema.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/indicators/macd.dart';
import 'package:fin_chart/models/indicators/rsi.dart';
import 'package:fin_chart/models/indicators/sma.dart';
import 'package:fin_chart/models/indicators/stochastic.dart';
import 'package:fin_chart/models/layers/arrow.dart';
import 'package:fin_chart/models/layers/circular_area.dart';
import 'package:fin_chart/models/layers/horizontal_band.dart';
import 'package:fin_chart/models/layers/horizontal_line.dart';
import 'package:fin_chart/models/layers/label.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/layers/parallel_channel.dart';
import 'package:fin_chart/models/layers/rect_area.dart';
import 'package:fin_chart/models/layers/trend_line.dart';
import 'package:fin_chart/models/layers/vertical_line.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              : const Text("Finance Charts"),
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
                            tasks: tasks)
                        .toJson())))
                .then((_) {
              if (context.mounted) {
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

  @override
  void initState() {
    //candleData.addAll(data.map((data) => ICandle.fromJson(data)).toList());
    if (widget.recipeStr != null) {
      recipe = Recipe.fromJson(jsonDecode(widget.recipeStr!));
      populateRecipe(recipe!);
    }
    super.initState();
  }

  populateRecipe(Recipe recipe) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      candleData.addAll(recipe.data);
      _chartKey.currentState?.addData(candleData);
      tasks.addAll(recipe.tasks);
      fundamentalEvents.addAll(recipe.fundamentalEvents);
      for (Task task in tasks) {
        switch (task.taskType) {
          case TaskType.addPrompt:
          case TaskType.waitTask:
            break;
          case TaskType.addData:
            VerticalLine layer = VerticalLine.fromTool(
                pos: (task as AddDataTask).tillPoint.toDouble());
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
                        fundamentalEvents: fundamentalEvents,
                        // dataFit: DataFit.fixedWidth,
                        // yAxisSettings:
                        //     const YAxisSettings(yAxisPos: YAxisPos.left),
                        // xAxisSettings:
                        //     const XAxisSettings(xAxisPos: XAxisPos.bottom),
                        onLayerSelect: _onLayerSelect,
                        onRegionSelect: _onRegionSelect,
                        onIndicatorSelect: _onIndicatorSelect,
                        onInteraction: _onInteraction)
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
      setState(() {
        //tasks.add(AddLayerTask(regionId: region.id, layer: layer));
        tasks.insert(
            insertPosition, AddLayerTask(regionId: region.id, layer: layer));
        _currentTaskType = null;
      });
    }
  }

  _onRegionSelect(PlotRegion region) {
    selectedRegion = region;
  }

  _onIndicatorSelect(Indicator indicator) {
    setState(() {
      if (_currentTaskType == TaskType.addIndicator) {
        //tasks.add(AddIndicatorTask(indicator: indicator));
        tasks.insert(insertPosition, AddIndicatorTask(indicator: indicator));
        _currentTaskType = null;
      }
    });
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
                return;
              } else {
                fromPoint = task.tillPoint;
              }
            }
          }
          setState(() {
            tasks.add(AddDataTask(
                fromPoint: fromPoint,
                tillPoint: tapDownPoint.dx.round() + 1,
                verticleLineId: layer?.id ?? ""));
            _currentTaskType = null;
          });
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
          if (_isRecording && layer.type != LayerType.verticalLine) {
            setState(() {
              tasks.add(
                  AddLayerTask(regionId: selectedRegion!.id, layer: layer!));
            });
          }
        }
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
        onTaskReorder: _onTaskReorder,
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
        break;
      case TaskType.addPrompt:
        editPrompt(task as AddPromptTask);
        break;
      case TaskType.waitTask:
        editWaitTask(task as WaitTask);
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

  _onTaskReorder(int oldIndex, int newIndex) {
    // setState(() {
    //   if (oldIndex < newIndex) {
    //     newIndex -= 1;
    //   }

    //   if (newIndex >= tasks.length) {
    //     return;
    //   }

    //   final Task item = tasks.removeAt(oldIndex);
    //   tasks.insert(newIndex, item);
    // });

    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, item);
    });
  }

  void prompt() async {
    await showPromptDialog(context: context).then((data) {
      setState(() {
        if (data != null) {
          //tasks.add(data);
          tasks.insert(insertPosition, data);
        }
        _currentTaskType = null;
      });
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
      setState(() {
        if (data != null) {
          //tasks.add(data);
          tasks.insert(insertPosition, data);
        }
        _currentTaskType = null;
      });
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

  Future<AddPromptTask?> showPromptDialog({
    required BuildContext context,
    String title = 'Enter Text',
    String hintText = 'Enter your text here',
    String okButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    AddPromptTask? initialTask,
    int? maxLines = 5,
    TextInputType keyboardType = TextInputType.multiline,
  }) async {
    final TextEditingController textController =
        TextEditingController(text: initialTask?.promptText ?? '');

    // Track if this is an explanation
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
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: const OutlineInputBorder(),
                        filled: true,
                      ),
                      maxLines: maxLines,
                      keyboardType: keyboardType,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
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
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      // Create and return a new AddPromptTask
                      final task = AddPromptTask(
                        promptText: text,
                        isExplanation: isExplanation,
                      );
                      Navigator.of(context).pop(task);
                    } else {
                      // Show error or just close with null
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

  Widget _buildToolBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        reverse: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: _showAddEventDialog,
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
    }
    _chartKey.currentState?.addIndicator(indicator);
    if (_isRecording) {
      setState(() {
        tasks.add(AddIndicatorTask(indicator: indicator!));
      });
    }
  }
}
