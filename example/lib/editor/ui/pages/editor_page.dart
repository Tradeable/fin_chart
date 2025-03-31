import 'dart:convert';

import 'package:example/editor/ui/pages/chart_demo.dart';
import 'package:example/dialog/add_data_dialog.dart';
import 'package:fin_chart/models/enums/mcq_arrangment_type.dart';
import 'package:fin_chart/models/indicators/atr.dart';
import 'package:fin_chart/models/indicators/mfi.dart';
import 'package:fin_chart/models/indicators/adx.dart';
import 'package:fin_chart/models/tasks/add_data.task.dart';
import 'package:fin_chart/models/tasks/add_indicator.task.dart';
import 'package:fin_chart/models/tasks/add_layer.task.dart';
import 'package:fin_chart/models/tasks/add_mcq.task.dart';
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
                                chartSettings:
                                    _chartKey.currentState!.getChartSettings(),
                                tasks: tasks)
                            .toJson())),
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
      for (Task task in tasks) {
        switch (task.taskType) {
          case TaskType.addPrompt:
          case TaskType.waitTask:
          case TaskType.addMcq:
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
        case TaskType.addMcq:
          mcqPrompt();
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
      case TaskType.addMcq:
        editMcqPrompt(task as AddMcqTask);
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

  void mcqPrompt() async {
    await showMcqTaskDialog(context: context).then((data) {
      setState(() {
        if (data != null) {
          tasks.insert(insertPosition, data);
        }
        _currentTaskType = null;
      });
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

    return showDialog<AddMcqTask>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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

const data = [
  {
    "id": "candle-1741891161755",
    "date": "2025-03-14T00:09:21.755390",
    "open": 3919.799097028158,
    "high": 4043.2018170638185,
    "low": 3382.5143097542964,
    "close": 3453.3345781446537,
    "volume": 2518.2359039782814,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741892061755",
    "date": "2025-03-14T00:24:21.755390",
    "open": 3414.6651689527725,
    "high": 3639.547568612365,
    "low": 3263.315622237166,
    "close": 3398.366981733096,
    "volume": 2803.9803379072537,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741892961755",
    "date": "2025-03-14T00:39:21.755390",
    "open": 3322.6870946823788,
    "high": 3526.3130840462136,
    "low": 2918.911555711072,
    "close": 3048.9035612095086,
    "volume": 6739.152466649261,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741893861755",
    "date": "2025-03-14T00:54:21.755390",
    "open": 2946.8312529218792,
    "high": 3173.3061375229777,
    "low": 2811.9831654560894,
    "close": 3070.1626607219814,
    "volume": 7937.133073892044,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741894761755",
    "date": "2025-03-14T01:09:21.755390",
    "open": 3152.781833904648,
    "high": 3305.089723306507,
    "low": 2763.3666409375337,
    "close": 2950.7435243416844,
    "volume": 2759.824103272538,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741895661755",
    "date": "2025-03-14T01:24:21.755390",
    "open": 2986.62150686838,
    "high": 3573.3441290227447,
    "low": 2913.1767217241973,
    "close": 3435.095954405645,
    "volume": 6290.064382614197,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741896561755",
    "date": "2025-03-14T01:39:21.755390",
    "open": 3497.4621073582084,
    "high": 3930.967236203687,
    "low": 3427.2804697531174,
    "close": 3862.014607300248,
    "volume": 8217.856275845195,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741897461755",
    "date": "2025-03-14T01:54:21.755390",
    "open": 3889.576433624734,
    "high": 4488.536137874453,
    "low": 3695.341758054871,
    "close": 4335.284932244093,
    "volume": 9018.200462523406,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741898361755",
    "date": "2025-03-14T02:09:21.755390",
    "open": 4307.03512858498,
    "high": 4641.14281417513,
    "low": 4238.669042141942,
    "close": 4464.427480706349,
    "volume": 3185.2441362532554,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741899261755",
    "date": "2025-03-14T02:24:21.755390",
    "open": 4561.162234556618,
    "high": 4798.136344001642,
    "low": 4448.521513797904,
    "close": 4707.124432663213,
    "volume": 9730.094746425619,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741900161755",
    "date": "2025-03-14T02:39:21.755390",
    "open": 4722.815816372872,
    "high": 4905.783210099598,
    "low": 4513.618977638402,
    "close": 4797.276202761557,
    "volume": 1651.1069410090304,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741901061755",
    "date": "2025-03-14T02:54:21.755390",
    "open": 4872.429056659387,
    "high": 4887.542439274233,
    "low": 4669.961465322778,
    "close": 4867.357542261818,
    "volume": 2390.5964187527807,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741901961755",
    "date": "2025-03-14T03:09:21.755390",
    "open": 4762.1546479702265,
    "high": 5227.829918279797,
    "low": 4744.280129368863,
    "close": 5201.676727508739,
    "volume": 6255.983993905732,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741902861755",
    "date": "2025-03-14T03:24:21.755390",
    "open": 5106.698556749229,
    "high": 5613.343076713694,
    "low": 4939.024995698739,
    "close": 5443.3475932449555,
    "volume": 3505.9441622874047,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741903761755",
    "date": "2025-03-14T03:39:21.755390",
    "open": 5375.643561089663,
    "high": 5469.6936728100645,
    "low": 4372.281340530149,
    "close": 4374.022007466533,
    "volume": 4335.594709170131,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741904661755",
    "date": "2025-03-14T03:54:21.755390",
    "open": 4367.056253572926,
    "high": 4371.552361447626,
    "low": 2887.179408875178,
    "close": 2968.9358545659993,
    "volume": 4641.195732717707,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741905561755",
    "date": "2025-03-14T04:09:21.755390",
    "open": 3047.4720770225913,
    "high": 3487.4840156363175,
    "low": 2863.5852813366387,
    "close": 3333.2458850937737,
    "volume": 8454.392385469757,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741906461755",
    "date": "2025-03-14T04:24:21.755390",
    "open": 3235.024562482295,
    "high": 3324.331662309798,
    "low": 2860.16761207262,
    "close": 3023.1141115312735,
    "volume": 8799.50819296858,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741907361755",
    "date": "2025-03-14T04:39:21.755390",
    "open": 2960.019719574993,
    "high": 3169.939262303563,
    "low": 2806.827613100986,
    "close": 2965.7188893313814,
    "volume": 2652.8683103290496,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741908261755",
    "date": "2025-03-14T04:54:21.755390",
    "open": 2877.234809436977,
    "high": 3352.9958479255997,
    "low": 2813.04978824327,
    "close": 3334.4378501906826,
    "volume": 4933.8442644814895,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741909161755",
    "date": "2025-03-14T05:09:21.755390",
    "open": 3279.1885019842675,
    "high": 3464.359816044512,
    "low": 3262.351387545817,
    "close": 3460.116078497752,
    "volume": 6981.318124813003,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741910061755",
    "date": "2025-03-14T05:24:21.755390",
    "open": 3574.433276642993,
    "high": 4179.223332258887,
    "low": 3493.024266412418,
    "close": 4073.7427934692487,
    "volume": 3837.4814794735767,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741910961755",
    "date": "2025-03-14T05:39:21.755390",
    "open": 4022.0013597265865,
    "high": 4563.26074751336,
    "low": 3835.1569244001175,
    "close": 4394.129944165117,
    "volume": 1870.3534978397483,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741911861755",
    "date": "2025-03-14T05:54:21.755390",
    "open": 4392.785903197578,
    "high": 5098.665040754406,
    "low": 4328.250119159509,
    "close": 4990.2354856816855,
    "volume": 9830.757509352752,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741912761755",
    "date": "2025-03-14T06:09:21.755390",
    "open": 5099.532656701784,
    "high": 5667.109189593008,
    "low": 4989.912952892034,
    "close": 5581.919595437926,
    "volume": 9370.556256602677,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741913661755",
    "date": "2025-03-14T06:24:21.755390",
    "open": 5692.681442202977,
    "high": 5810.71851575098,
    "low": 5195.083339835632,
    "close": 5402.481748615893,
    "volume": 8092.71239115838,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741914561755",
    "date": "2025-03-14T06:39:21.755390",
    "open": 5412.049891450932,
    "high": 5768.657050096102,
    "low": 5251.45538068773,
    "close": 5601.583489574063,
    "volume": 2400.5399024492162,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741915461755",
    "date": "2025-03-14T06:54:21.755390",
    "open": 5629.832298873264,
    "high": 5783.919723612398,
    "low": 5517.911067051656,
    "close": 5552.254771727115,
    "volume": 6717.691656907152,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741916361755",
    "date": "2025-03-14T07:09:21.755390",
    "open": 5482.560491721526,
    "high": 5606.607481456571,
    "low": 5048.0822920841265,
    "close": 5067.7278712129155,
    "volume": 4218.232987921761,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741917261755",
    "date": "2025-03-14T07:24:21.755390",
    "open": 4959.244684306037,
    "high": 4984.275967471779,
    "low": 4674.59393325349,
    "close": 4718.128035626104,
    "volume": 7678.565785261006,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741918161755",
    "date": "2025-03-14T07:39:21.755390",
    "open": 4824.552417554713,
    "high": 5055.052615985571,
    "low": 4049.7679842323196,
    "close": 4224.465272673609,
    "volume": 7905.268549902138,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741919061755",
    "date": "2025-03-14T07:54:21.755390",
    "open": 4285.607785036093,
    "high": 4295.325656579597,
    "low": 3469.004631079564,
    "close": 3646.568075426076,
    "volume": 6222.986605655163,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741919961755",
    "date": "2025-03-14T08:09:21.755390",
    "open": 3622.8067526608106,
    "high": 4559.714400825355,
    "low": 3524.504061779207,
    "close": 4346.977376420425,
    "volume": 5690.824808706139,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741920861755",
    "date": "2025-03-14T08:24:21.755390",
    "open": 4277.354478819425,
    "high": 4297.683158584395,
    "low": 4144.630964463197,
    "close": 4276.717063477573,
    "volume": 9736.297893016166,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741921761755",
    "date": "2025-03-14T08:39:21.755390",
    "open": 4341.482524207215,
    "high": 4501.872190222114,
    "low": 4306.210995725161,
    "close": 4416.22412290025,
    "volume": 3635.864111900431,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741922661755",
    "date": "2025-03-14T08:54:21.755390",
    "open": 4403.511555017688,
    "high": 4830.595543089271,
    "low": 4403.240899747856,
    "close": 4714.215500193073,
    "volume": 8276.015780134225,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741923561755",
    "date": "2025-03-14T09:09:21.755390",
    "open": 4608.166386598421,
    "high": 4890.658018835797,
    "low": 4449.526725917246,
    "close": 4726.742006072516,
    "volume": 1939.8501902781522,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741924461755",
    "date": "2025-03-14T09:24:21.755390",
    "open": 4779.503239444285,
    "high": 4917.200177021434,
    "low": 4643.294230312329,
    "close": 4825.101789148515,
    "volume": 5957.018054863777,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741925361755",
    "date": "2025-03-14T09:39:21.755390",
    "open": 4713.422415831563,
    "high": 5033.232210893802,
    "low": 4551.575341675605,
    "close": 4995.53801983019,
    "volume": 6135.509830345694,
    "promptText": null,
    "state": "natural"
  },
  {
    "id": "candle-1741926261755",
    "date": "2025-03-14T09:54:21.755390",
    "open": 5077.806130396957,
    "high": 5202.177655527023,
    "low": 4658.290004741161,
    "close": 4776.742744382347,
    "volume": 7529.726013410661,
    "promptText": null,
    "state": "natural"
  }
];
