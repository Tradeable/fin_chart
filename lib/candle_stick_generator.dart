import 'package:fin_chart/models/i_candle.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:fin_chart/models/enums/candle_state.dart';

// Add enum for trendline visibility states
enum TrendlineVisibility {
  visible,
  translucent,
  invisible;

  String get label {
    switch (this) {
      case TrendlineVisibility.visible:
        return 'VISIBLE';
      case TrendlineVisibility.translucent:
        return 'TRANSLUCENT';
      case TrendlineVisibility.invisible:
        return 'INVISIBLE';
    }
  }
}

// Time interval options for candles
enum TimeInterval {
  m1,
  m5,
  m15,
  m30,
  h1,
  d1,
  w1,
  mo1,
  y1;

  String get label {
    switch (this) {
      case TimeInterval.m1:
        return '1m';
      case TimeInterval.m5:
        return '5m';
      case TimeInterval.m15:
        return '15m';
      case TimeInterval.m30:
        return '30m';
      case TimeInterval.h1:
        return '1h';
      case TimeInterval.d1:
        return '1d';
      case TimeInterval.w1:
        return '1w';
      case TimeInterval.mo1:
        return '1M';
      case TimeInterval.y1:
        return '1y';
    }
  }

  Duration get duration {
    switch (this) {
      case TimeInterval.m1:
        return const Duration(minutes: 1);
      case TimeInterval.m5:
        return const Duration(minutes: 5);
      case TimeInterval.m15:
        return const Duration(minutes: 15);
      case TimeInterval.m30:
        return const Duration(minutes: 30);
      case TimeInterval.h1:
        return const Duration(hours: 1);
      case TimeInterval.d1:
        return const Duration(days: 1);
      case TimeInterval.w1:
        return const Duration(days: 7);
      case TimeInterval.mo1:
        return const Duration(days: 30);
      case TimeInterval.y1:
        return const Duration(days: 365);
    }
  }
}

enum SelectionType { candle, volume }

class CandleData {
  final double open;
  final double high;
  final double low;
  final double close;
  final bool isAdjusted;
  final double volume;
  final bool isExisting; // New field to track existing vs generated candles

  CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.isAdjusted = false,
    this.volume = 0,
    this.isExisting = false,
  });

  CandleData copyWith({
    double? open,
    double? high,
    double? low,
    double? close,
    bool? isAdjusted,
    double? volume,
    bool? isExisting,
  }) {
    return CandleData(
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      isAdjusted: isAdjusted ?? this.isAdjusted,
      volume: volume ?? this.volume,
      isExisting: isExisting ?? this.isExisting,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'isAdjusted': isAdjusted,
      'volume': volume,
      'isExisting': isExisting,
    };
  }
}

class CandleStickGenerator extends StatefulWidget {
  final Function(List<ICandle> candles) onCandleDataGenerated;
  final List<ICandle>? existingCandles; // New parameter for existing candles

  const CandleStickGenerator({
    super.key,
    required this.onCandleDataGenerated,
    this.existingCandles,
  });

  @override
  State<CandleStickGenerator> createState() => _CandleStickGeneratorState();
}

class _CandleStickGeneratorState extends State<CandleStickGenerator> {
  final TextEditingController minController =
      TextEditingController(text: '1500');
  final TextEditingController maxController =
      TextEditingController(text: '6150');
  final TextEditingController candlesController =
      TextEditingController(text: '100');
  final TextEditingController volumeMinController =
      TextEditingController(text: '1000');
  final TextEditingController volumeMaxController =
      TextEditingController(text: '10000');

  int? selectedVolumeIndex;
  SelectionType lastClickedType = SelectionType.candle;

  // Add visibility state
  TrendlineVisibility trendlineVisibility = TrendlineVisibility.visible;

  // Add time interval selection
  TimeInterval selectedTimeInterval = TimeInterval.m15;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  bool volumeEnabled = true;

  List<math.Point> trendPoints = [
    const math.Point(0, 0.5),
    const math.Point(1, 0.5)
  ];
  List<CandleData> candles = [];
  int? selectedPointIndex;
  int? selectedCandleIndex;
  int existingCandlesCount = 0; // Track how many existing candles we have

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _initializeWithExistingCandles();
  }

  void _initializeWithExistingCandles() {
    if (widget.existingCandles != null && widget.existingCandles!.isNotEmpty) {
      existingCandlesCount = widget.existingCandles!.length;

      // Convert existing ICandles to CandleData
      final existingCandleData = widget.existingCandles!
          .map((iCandle) => CandleData(
                open: iCandle.open,
                high: iCandle.high,
                low: iCandle.low,
                close: iCandle.close,
                volume: iCandle.volume,
                isAdjusted: iCandle.state == CandleState.selected,
                isExisting: true,
              ))
          .toList();

      // Update price range based on existing data
      _updatePriceRangeFromExistingData(existingCandleData);

      // Set start date and time interval from existing data
      startDate = widget.existingCandles!.first.date;
      _inferTimeInterval();

      setState(() {
        candles = List.from(existingCandleData);

        // Initialize trendline starting from the last existing candle's close
        final lastClose = existingCandleData.last.close;
        final priceRatio = _priceToRatio(lastClose);
        trendPoints = [
          math.Point(
              existingCandlesCount /
                  (existingCandlesCount + int.parse(candlesController.text)),
              1 - priceRatio),
          const math.Point(1, 0.5)
        ];
      });
    }
  }

  void _updatePriceRangeFromExistingData(List<CandleData> existingData) {
    if (existingData.isEmpty) return;

    double minPrice = existingData.first.low;
    double maxPrice = existingData.first.high;

    for (var candle in existingData) {
      minPrice = math.min(minPrice, candle.low);
      maxPrice = math.max(maxPrice, candle.high);
    }

    // Add some padding
    final padding = (maxPrice - minPrice) * 0.1;
    minPrice -= padding;
    maxPrice += padding;

    minController.text = minPrice.toStringAsFixed(2);
    maxController.text = maxPrice.toStringAsFixed(2);
  }

  void _inferTimeInterval() {
    if (widget.existingCandles == null || widget.existingCandles!.length < 2)
      return;

    final diff = widget.existingCandles![1].date
        .difference(widget.existingCandles![0].date);

    // Find the closest matching time interval
    for (var interval in TimeInterval.values) {
      if (diff.inMinutes <= interval.duration.inMinutes * 1.1 &&
          diff.inMinutes >= interval.duration.inMinutes * 0.9) {
        selectedTimeInterval = interval;
        break;
      }
    }
  }

  void _updateTrendlineForCandleCountChange() {
    // Parse the new candle count, use default if invalid
    final newCandleCount = int.tryParse(candlesController.text) ?? 100;
    final totalCandles = existingCandlesCount + newCandleCount;

    if (totalCandles <= 0 || existingCandlesCount >= totalCandles) return;

    setState(() {
      // Update trendline points to reflect new proportions
      final existingRatio = existingCandlesCount / totalCandles;

      // If we have existing candles, update the first trendline point
      if (existingCandlesCount > 0) {
        // Get the close price of the last existing candle for the Y position
        final lastClose =
            candles.isNotEmpty && existingCandlesCount <= candles.length
                ? candles[existingCandlesCount - 1].close
                : double.parse(minController.text) +
                    (double.parse(maxController.text) -
                            double.parse(minController.text)) *
                        0.5;

        final priceRatio = _priceToRatio(lastClose);

        // Update trendline points
        if (trendPoints.isNotEmpty) {
          trendPoints[0] = math.Point(existingRatio, 1 - priceRatio);
        }
      } else {
        // No existing candles, start from beginning
        if (trendPoints.isNotEmpty) {
          trendPoints[0] = math.Point(0, trendPoints[0].y);
        }
      }

      // Ensure the last point is at x=1.0
      if (trendPoints.length > 1) {
        trendPoints[trendPoints.length - 1] =
            math.Point(1.0, trendPoints.last.y);
      }

      // Remove any intermediate points that are now before the existing ratio
      trendPoints
          .removeWhere((point) => point.x > 0 && point.x < existingRatio);

      // Sort trendpoints to maintain order
      trendPoints.sort((a, b) => (a.x - b.x).sign.toInt());
    });
  }

  double _priceToRatio(double price) {
    final min = double.tryParse(minController.text) ?? 1500.0;
    final max = double.tryParse(maxController.text) ?? 6150.0;
    return (price - min) / (max - min);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _isNumberKeyPressed = false;
  int? _activeNumberKey;

  void _handleKeyDown(KeyEvent event) {
    // Check for number keys 1-4
    if (event.logicalKey.keyLabel.length == 1 &&
        "1234".contains(event.logicalKey.keyLabel)) {
      _isNumberKeyPressed = true;
      _activeNumberKey = int.parse(event.logicalKey.keyLabel);
      return;
    }

    _adjustSelectedCandle(event.logicalKey);
  }

  void _handleKeyUp(KeyEvent event) {
    if (event.logicalKey.keyLabel.length == 1 &&
        "1234".contains(event.logicalKey.keyLabel)) {
      _isNumberKeyPressed = false;
      _activeNumberKey = null;
    }
  }

  void _adjustSelectedCandle(LogicalKeyboardKey key) {
    if (selectedCandleIndex == null) return;

    // Don't allow editing existing candles (only new generated ones)
    if (selectedCandleIndex! < existingCandlesCount) return;

    final adjustmentStep = (maxController.text.isEmpty
            ? 150.0
            : double.parse(maxController.text) -
                (minController.text.isEmpty
                    ? 50.0
                    : double.parse(minController.text))) *
        0.01;

    setState(() {
      final oldCandle = candles[selectedCandleIndex!];
      CandleData? newCandle;

      if (_isNumberKeyPressed && _activeNumberKey != null) {
        switch (_activeNumberKey) {
          case 1: // Open
            if (key == LogicalKeyboardKey.arrowUp) {
              newCandle = oldCandle.copyWith(
                open: oldCandle.open + adjustmentStep,
              );
            } else if (key == LogicalKeyboardKey.arrowDown) {
              newCandle = oldCandle.copyWith(
                open: oldCandle.open - adjustmentStep,
              );
            }
            break;

          case 2: // High
            if (key == LogicalKeyboardKey.arrowUp) {
              newCandle = oldCandle.copyWith(
                high: oldCandle.high + adjustmentStep,
              );
            } else if (key == LogicalKeyboardKey.arrowDown) {
              final minValue = math.max(oldCandle.open, oldCandle.close);
              final newHigh = oldCandle.high - adjustmentStep;
              if (newHigh > minValue) {
                newCandle = oldCandle.copyWith(high: newHigh);
              }
            }
            break;

          case 3: // Low
            if (key == LogicalKeyboardKey.arrowUp) {
              final maxValue = math.min(oldCandle.open, oldCandle.close);
              final newLow = oldCandle.low + adjustmentStep;
              if (newLow < maxValue) {
                newCandle = oldCandle.copyWith(low: newLow);
              }
            } else if (key == LogicalKeyboardKey.arrowDown) {
              newCandle = oldCandle.copyWith(
                low: oldCandle.low - adjustmentStep,
              );
            }
            break;

          case 4: // Close
            if (key == LogicalKeyboardKey.arrowUp) {
              newCandle = oldCandle.copyWith(
                close: oldCandle.close + adjustmentStep,
              );
            } else if (key == LogicalKeyboardKey.arrowDown) {
              newCandle = oldCandle.copyWith(
                close: oldCandle.close - adjustmentStep,
              );
            }
            break;
        }
      } else {
        if (key == LogicalKeyboardKey.arrowLeft) {
          selectedCandleIndex = math.max(0, selectedCandleIndex! - 1);
          return;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          selectedCandleIndex =
              math.min(candles.length - 1, selectedCandleIndex! + 1);
          return;
        } else if (key == LogicalKeyboardKey.escape) {
          selectedCandleIndex = null;
          return;
        }
      }

      if (newCandle != null) {
        candles[selectedCandleIndex!] = newCandle;
        // Only send newly generated candles to callback
        final newCandlesOnly = candles.skip(existingCandlesCount).toList();
        widget.onCandleDataGenerated(
            _convertToICandles(newCandlesOnly, startFromExisting: true));
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // First check if a volume bar is selected
      if (selectedVolumeIndex != null) {
        _handleVolumeKeyDown(event);
        // Prevent the event from bubbling up
        return;
      } else {
        _handleKeyDown(event); // Original handler for candles
      }
    } else if (event is KeyUpEvent) {
      _handleKeyUp(event); // Original handler
    }
  }

  void _saveAdjustment() {
    if (selectedCandleIndex != null &&
        selectedCandleIndex! >= existingCandlesCount) {
      setState(() {
        candles[selectedCandleIndex!] = candles[selectedCandleIndex!].copyWith(
          isAdjusted: true,
        );
      });
    } else if (selectedVolumeIndex != null &&
        selectedVolumeIndex! >= existingCandlesCount) {
      setState(() {
        candles[selectedVolumeIndex!] = candles[selectedVolumeIndex!].copyWith(
          isAdjusted: true,
        );
      });
    }
  }

  void _handleVolumeKeyDown(KeyEvent event) {
    if (selectedVolumeIndex == null) return;

    // Don't allow editing existing candles (only new generated ones)
    if (selectedVolumeIndex! < existingCandlesCount) return;

    final adjustmentStep = (double.parse(volumeMaxController.text) -
            double.parse(volumeMinController.text)) *
        0.05;

    setState(() {
      final oldCandle = candles[selectedVolumeIndex!];
      CandleData? newCandle;

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        newCandle = oldCandle.copyWith(
          volume: oldCandle.volume + adjustmentStep,
          isAdjusted: true,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        newCandle = oldCandle.copyWith(
          volume: math.max(0, oldCandle.volume - adjustmentStep),
          isAdjusted: true,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        selectedVolumeIndex = math.max(0, selectedVolumeIndex! - 1);
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        selectedVolumeIndex =
            math.min(candles.length - 1, selectedVolumeIndex! + 1);
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        selectedVolumeIndex = null;
        return;
      }

      if (newCandle != null) {
        candles[selectedVolumeIndex!] = newCandle;
      }
      // Only send newly generated candles to callback
      final newCandlesOnly = candles.skip(existingCandlesCount).toList();
      widget.onCandleDataGenerated(
          _convertToICandles(newCandlesOnly, startFromExisting: true));
    });
  }

  void _toggleTrendlineVisibility() {
    setState(() {
      const values = TrendlineVisibility.values;
      final currentIndex = values.indexOf(trendlineVisibility);
      trendlineVisibility = values[(currentIndex + 1) % values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // Only intercept keys when a candle/volume is selected AND the focus is on our widget
        // (not on a text field)
        if ((selectedVolumeIndex != null || selectedCandleIndex != null) &&
            _focusNode.hasFocus) {
          final isArrowKey = event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.arrowRight;

          final isEscapeKey = event.logicalKey == LogicalKeyboardKey.escape;

          final isNumberKey = event.logicalKey.keyLabel.length == 1 &&
              "1234".contains(event.logicalKey.keyLabel);

          if (isArrowKey || isEscapeKey || isNumberKey) {
            if (event is KeyDownEvent) {
              if (selectedVolumeIndex != null) {
                _handleVolumeKeyDown(event);
              } else if (selectedCandleIndex != null) {
                _handleKeyDown(event);
              }
              return KeyEventResult.handled;
            } else if (event is KeyUpEvent) {
              _handleKeyUp(event);
              return KeyEventResult.handled;
            }
          }
        }

        return KeyEventResult.ignored; // Let text fields handle everything else
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Card(
          margin: const EdgeInsets.all(4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateTrendlineForCandleCountChange();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateTrendlineForCandleCountChange();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: candlesController,
                        decoration: const InputDecoration(
                          labelText: 'New Candles',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Update the trendline positioning when candle count changes
                          _updateTrendlineForCandleCountChange();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: volumeMinController,
                        decoration: const InputDecoration(
                          labelText: 'Min Volume',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: volumeMaxController,
                        decoration: const InputDecoration(
                          labelText: 'Max Volume',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeIntervalDropdown(),
                    ),
                  ],
                ),
                if (existingCandlesCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Existing candles: $existingCandlesCount | New candles: ${candlesController.text}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          _selectCandle(
                              details.localPosition, constraints.biggest);
                          _focusNode.requestFocus();
                        },
                        onDoubleTapDown: (details) {
                          if (trendlineVisibility ==
                              TrendlineVisibility.visible) {
                            _handleDoubleTap(
                                details.localPosition, constraints.biggest);
                          }
                        },
                        onPanDown: (details) {
                          if (trendlineVisibility ==
                              TrendlineVisibility.visible) {
                            _selectPoint(
                                details.localPosition, constraints.biggest);
                          }
                        },
                        onPanUpdate: (details) {
                          if (trendlineVisibility ==
                              TrendlineVisibility.visible) {
                            _updatePointPosition(
                                details.localPosition, constraints.biggest);
                          }
                        },
                        onPanEnd: (_) {
                          setState(() {
                            selectedPointIndex = null;
                          });
                        },
                        onPanCancel: () {
                          setState(() {
                            selectedPointIndex = null;
                          });
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: TrendLinePainter(
                            points: trendPoints,
                            candles: candles,
                            selectedPointIndex: selectedPointIndex,
                            selectedCandleIndex: selectedCandleIndex,
                            visibility: trendlineVisibility,
                            minPrice: double.parse(minController.text),
                            maxPrice: double.parse(maxController.text),
                            existingCandlesCount: existingCandlesCount,
                            totalExpectedCandles: existingCandlesCount +
                                (int.tryParse(candlesController.text) ?? 100),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          _selectVolume(
                              details.localPosition, constraints.biggest);
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: VolumePainter(
                            candles: candles,
                            selectedVolumeIndex: selectedVolumeIndex,
                            volumeEnabled: volumeEnabled,
                            existingCandlesCount: existingCandlesCount,
                            totalExpectedCandles: existingCandlesCount +
                                (int.tryParse(candlesController.text) ?? 100),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _pickStartDate,
                        child: Text('Start Date: ${_formatDate(startDate)}'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: ((selectedCandleIndex != null &&
                                    selectedCandleIndex! >=
                                        existingCandlesCount) ||
                                (selectedVolumeIndex != null &&
                                    selectedVolumeIndex! >=
                                        existingCandlesCount))
                            ? _saveAdjustment
                            : null,
                        child: const Text('Save Adjustment'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _toggleTrendlineVisibility,
                        child: Text('Trendline: ${trendlineVisibility.label}'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            volumeEnabled = !volumeEnabled;

                            if (!volumeEnabled) {
                              for (int i = 0; i < candles.length; i++) {
                                if (!candles[i].isAdjusted) {
                                  candles[i] = candles[i].copyWith(volume: 0.0);
                                }
                              }
                            } else if (candles.isNotEmpty) {
                              _regenerateVolumes();
                            }

                            widget.onCandleDataGenerated(_convertToICandles(
                                candles.skip(existingCandlesCount).toList(),
                                startFromExisting: true));
                          });
                        },
                        child: Text('Volume: ${volumeEnabled ? 'ON' : 'OFF'}'),
                      ),
                      ElevatedButton(
                        onPressed: _generateCandles,
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIntervalDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeInterval>(
          value: selectedTimeInterval,
          isExpanded: true,
          hint: const Text('Time Interval'),
          onChanged: (TimeInterval? value) {
            if (value != null) {
              setState(() {
                selectedTimeInterval = value;
              });
            }
          },
          items: TimeInterval.values.map((TimeInterval value) {
            return DropdownMenuItem<TimeInterval>(
              value: value,
              child: Text(value.label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _selectCandle(Offset position, Size size) {
    final totalCandles = candles.length;
    if (totalCandles == 0) return;

    final candleWidth = size.width / (totalCandles + 1);
    final x = position.dx;

    final candleIndex = ((x / candleWidth) - 0.5).round() - 1;

    setState(() {
      selectedVolumeIndex = null;

      if (candleIndex >= 0 && candleIndex < totalCandles) {
        selectedCandleIndex = candleIndex;
      } else {
        selectedCandleIndex = null;
      }

      lastClickedType = SelectionType.candle;
    });
  }

  void _selectVolume(Offset position, Size size) {
    final totalCandles = candles.length;
    if (totalCandles == 0) return;

    final candleWidth = size.width / (totalCandles + 1);
    final x = position.dx;

    final volumeIndex = ((x / candleWidth) - 0.5).round() - 1;

    setState(() {
      selectedCandleIndex = null;

      if (volumeIndex >= 0 && volumeIndex < totalCandles) {
        selectedVolumeIndex = volumeIndex;
      } else {
        selectedVolumeIndex = null;
      }

      lastClickedType = SelectionType.volume;
    });
  }

  void _regenerateVolumes() {
    final volumeMin = double.parse(volumeMinController.text);
    final volumeMax = double.parse(volumeMaxController.text);
    final random = math.Random();

    for (int i = 0; i < candles.length; i++) {
      if (!candles[i].isAdjusted) {
        final volume =
            volumeMin + random.nextDouble() * (volumeMax - volumeMin);
        candles[i] = candles[i].copyWith(volume: volume);
      }
    }
  }

  void _generateCandles() {
    final min = double.parse(minController.text);
    final max = double.parse(maxController.text);
    final volumeMin = double.parse(volumeMinController.text);
    final volumeMax = double.parse(volumeMaxController.text);
    final numNewCandles = int.parse(candlesController.text);
    final random = math.Random();

    setState(() {
      // Keep existing candles, only generate new ones
      final existingCandles = candles.take(existingCandlesCount).toList();

      // Determine starting point for new candles
      double lastClose;
      if (existingCandles.isNotEmpty) {
        lastClose = existingCandles.last.close;
      } else {
        // For empty dataset, start at a reasonable price based on trendline
        final startTrendValue = 1 - _interpolateTrendValue(0);
        lastClose = min + (max - min) * startTrendValue;
      }

      final newCandles = <CandleData>[];

      for (int i = 0; i < numNewCandles; i++) {
        // Check if there's an existing adjusted candle at this position
        final globalIndex = existingCandlesCount + i;
        if (globalIndex < candles.length && candles[globalIndex].isAdjusted) {
          newCandles.add(candles[globalIndex]);
          lastClose = candles[globalIndex].close;
          continue;
        }

        // Calculate position relative to the new candles section
        final x = i / (numNewCandles - 1).clamp(1, double.infinity);
        final trendValue = 1 -
            _interpolateTrendValue((existingCandlesCount + i) /
                (existingCandlesCount + numNewCandles));

        final range = (max - min) * 0.1;
        final targetPrice = min + (max - min) * trendValue;

        double open;
        if (i == 0 && existingCandles.isEmpty) {
          // For the very first candle with no existing data, use trendline value
          open = targetPrice + (random.nextDouble() - 0.5) * range * 0.3;
        } else if (i == 0) {
          // First new candle should start from the last existing candle's close
          open = lastClose + (random.nextDouble() - 0.5) * range * 0.3;
        } else {
          open = lastClose + (random.nextDouble() - 0.5) * range * 0.5;
        }

        final close = targetPrice + (random.nextDouble() - 0.5) * range;
        final high = math.max(open, close) + random.nextDouble() * range * 0.5;
        final low = math.min(open, close) - random.nextDouble() * range * 0.5;

        final volume = volumeEnabled
            ? volumeMin + random.nextDouble() * (volumeMax - volumeMin)
            : 0.0;

        newCandles.add(CandleData(
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
          isExisting: false,
        ));

        lastClose = close;
      }

      // Combine existing and new candles
      candles = [...existingCandles, ...newCandles];

      // Only send newly generated candles to callback
      widget.onCandleDataGenerated(_convertToICandles(newCandles,
          startFromExisting: existingCandles.isNotEmpty));
    });
  }

  List<ICandle> _convertToICandles(List<CandleData> candleDataList,
      {bool startFromExisting = false}) {
    final iCandles = <ICandle>[];
    DateTime currentDate = startDate;

    // If we're starting from existing data, calculate the correct start date
    if (startFromExisting &&
        widget.existingCandles != null &&
        widget.existingCandles!.isNotEmpty) {
      // Start from the date after the last existing candle
      final lastExistingDate = widget.existingCandles!.last.date;
      currentDate = lastExistingDate.add(selectedTimeInterval.duration);
    }

    for (int i = 0; i < candleDataList.length; i++) {
      final candle = candleDataList[i];

      // Create unique ID for each candle
      final id = 'candle-${currentDate.millisecondsSinceEpoch}';

      // Convert CandleData to ICandle
      iCandles.add(
        ICandle(
          id: id,
          date: currentDate,
          open: candle.open,
          high: candle.high,
          low: candle.low,
          close: candle.close,
          volume: candle.volume,
          state: candle.isAdjusted ? CandleState.selected : CandleState.natural,
        ),
      );

      // Increment date by selected interval for next candle
      currentDate = currentDate.add(selectedTimeInterval.duration);
    }

    return iCandles;
  }

  void _handleDoubleTap(Offset position, Size size) {
    // Only allow trendline editing in the new candles area
    final totalCandles =
        existingCandlesCount + int.parse(candlesController.text);
    final existingRatio = existingCandlesCount / totalCandles;
    final relativeX = position.dx / size.width;

    // Don't allow trendline editing in existing candles area
    if (relativeX < existingRatio) return;

    int? nearbyPointIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < trendPoints.length; i++) {
      final point = trendPoints[i];
      final dx = (point.x * size.width) - position.dx;
      final dy = (point.y * size.height) - position.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < 20 && distance < minDistance) {
        minDistance = distance;
        nearbyPointIndex = i;
      }
    }

    setState(() {
      if (nearbyPointIndex != null) {
        if (nearbyPointIndex > 0 && nearbyPointIndex < trendPoints.length - 1) {
          _removeTrendPoint(nearbyPointIndex);
        }
      } else {
        _addTrendPoint(position, size);
      }
    });
  }

  void _removeTrendPoint(int index) {
    setState(() {
      trendPoints.removeAt(index);
      _generateCandles();
    });
  }

  void _selectPoint(Offset position, Size size) {
    // Only allow trendline point selection in the new candles area
    final totalCandles =
        existingCandlesCount + int.parse(candlesController.text);
    final existingRatio = existingCandlesCount / totalCandles;
    final relativeX = position.dx / size.width;

    if (relativeX < existingRatio) return;

    int? closest;
    double minDistance = double.infinity;

    for (int i = 0; i < trendPoints.length; i++) {
      final point = trendPoints[i];
      final dx = (point.x * size.width) - position.dx;
      final dy = (point.y * size.height) - position.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < 20 && distance < minDistance) {
        minDistance = distance;
        closest = i;
      }
    }

    setState(() {
      selectedPointIndex = closest;
    });
  }

  void _updatePointPosition(Offset position, Size size) {
    if (selectedPointIndex == null) return;

    final totalCandles =
        existingCandlesCount + int.parse(candlesController.text);
    final existingRatio = existingCandlesCount / totalCandles;

    double x = position.dx / size.width;
    double y = position.dy / size.height;

    y = y.clamp(0.0, 1.0).toDouble();

    setState(() {
      if (selectedPointIndex == 0) {
        // First point should be at the boundary between existing and new candles
        trendPoints[0] = math.Point(existingRatio, y);
      } else if (selectedPointIndex == trendPoints.length - 1) {
        trendPoints[trendPoints.length - 1] = math.Point(1.0, y);
      } else {
        final prevX = trendPoints[selectedPointIndex! - 1].x;
        final nextX = trendPoints[selectedPointIndex! + 1].x;
        x = x.clamp(math.max(prevX, existingRatio), nextX).toDouble();
        trendPoints[selectedPointIndex!] = math.Point(x, y);
      }

      _generateCandles();
    });
  }

  void _addTrendPoint(Offset position, Size size) {
    final totalCandles =
        existingCandlesCount + int.parse(candlesController.text);
    final existingRatio = existingCandlesCount / totalCandles;

    final x = (position.dx / size.width).clamp(existingRatio, 1.0);
    final y = (position.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      trendPoints.add(math.Point(x, y));
      trendPoints.sort((a, b) => (a.x - b.x).sign.toInt());
    });
  }

  double _interpolateTrendValue(double x) {
    int i = 0;
    while (i < trendPoints.length - 1 && trendPoints[i + 1].x < x) {
      i++;
    }

    if (i >= trendPoints.length - 1) {
      return trendPoints.last.y.toDouble();
    }

    final p1 = trendPoints[i];
    final p2 = trendPoints[i + 1];

    final t = (x - p1.x) / (p2.x - p1.x);
    return p1.y + t * (p2.y - p1.y);
  }
}

class TrendLinePainter extends CustomPainter {
  final List<math.Point> points;
  final List<CandleData> candles;
  final int? selectedPointIndex;
  final int? selectedCandleIndex;
  final TrendlineVisibility visibility;
  final double minPrice;
  final double maxPrice;
  final int existingCandlesCount;
  final int totalExpectedCandles;

  TrendLinePainter({
    required this.points,
    required this.candles,
    required this.visibility,
    required this.minPrice,
    required this.maxPrice,
    required this.existingCandlesCount,
    required this.totalExpectedCandles,
    this.selectedPointIndex,
    this.selectedCandleIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw price grid lines
    _drawPriceGrid(canvas, size);

    // Draw separation line between existing and new candles
    if (existingCandlesCount > 0 &&
        totalExpectedCandles > existingCandlesCount) {
      _drawSeparationLine(canvas, size);
    }

    // Draw trend line if not invisible
    if (visibility != TrendlineVisibility.invisible) {
      final linePaint = Paint()
        ..color = Colors.blue
            .withAlpha(visibility == TrendlineVisibility.translucent ? 77 : 255)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();

      if (points.isNotEmpty) {
        path.moveTo(
          points.first.x * size.width,
          points.first.y * size.height,
        );

        for (var point in points.skip(1)) {
          path.lineTo(
            point.x * size.width,
            point.y * size.height,
          );
        }
      }

      canvas.drawPath(path, linePaint);

      // Draw points
      if (visibility == TrendlineVisibility.visible) {
        final pointPaint = Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.fill;

        for (var i = 0; i < points.length; i++) {
          final point = points[i];
          final isSelected = i == selectedPointIndex;

          pointPaint.color = isSelected ? Colors.red : Colors.blue;

          canvas.drawCircle(
            Offset(point.x * size.width, point.y * size.height),
            isSelected ? 8 : 6,
            pointPaint,
          );
        }
      }
    }

    // Draw candles
    final candleWidth = size.width / (candles.length + 1);

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = candleWidth * (i + 1);
      final isSelected = i == selectedCandleIndex;
      final isExisting = candle.isExisting;

      final yHigh = _priceToY(candle.high, size.height);
      final yLow = _priceToY(candle.low, size.height);
      final yOpen = _priceToY(candle.open, size.height);
      final yClose = _priceToY(candle.close, size.height);

      // Different styling for existing vs new candles
      final baseAlpha = isExisting ? 255 : 180;
      final selectedAlpha = isSelected ? 128 : baseAlpha;

      // Draw wick
      canvas.drawLine(
          Offset(x, yHigh),
          Offset(x, yLow),
          Paint()
            ..color = (candle.close > candle.open ? Colors.green : Colors.red)
                .withAlpha(selectedAlpha));

      // Draw candle body
      final bodyPaint = Paint()
        ..color = (candle.close > candle.open ? Colors.green : Colors.red)
            .withAlpha(selectedAlpha);

      final bodyRect = Rect.fromPoints(
        Offset(x - candleWidth * 0.3, yOpen),
        Offset(x + candleWidth * 0.3, yClose),
      );

      canvas.drawRect(bodyRect, bodyPaint);

      // Draw border for existing candles or selected candles
      if (isExisting || isSelected) {
        canvas.drawRect(
          bodyRect,
          Paint()
            ..color = isSelected ? Colors.blue : Colors.orange
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? 2 : 1,
        );
      }
    }
  }

  void _drawPriceGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw 5 horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height * i) / 4;
      final price = maxPrice - (maxPrice - minPrice) * i / 4;

      // Draw grid line
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw price label
      textPainter.text = TextSpan(
        text: price.toStringAsFixed(2),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - textPainter.height / 2));
    }
  }

  void _drawSeparationLine(Canvas canvas, Size size) {
    if (totalExpectedCandles <= 0 || existingCandlesCount <= 0) return;

    final separationX =
        (existingCandlesCount / totalExpectedCandles) * size.width;

    final separationPaint = Paint()
      ..color = Colors.orange.withAlpha(150)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(separationX, 0),
      Offset(separationX, size.height),
      separationPaint,
    );

    // Add label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Existing | New',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(separationX + 5, 5));
  }

  double _priceToY(double price, double height) {
    return height * (1 - (price - minPrice) / (maxPrice - minPrice));
  }

  @override
  bool shouldRepaint(covariant TrendLinePainter oldDelegate) =>
      points != oldDelegate.points ||
      candles != oldDelegate.candles ||
      selectedPointIndex != oldDelegate.selectedPointIndex ||
      visibility != oldDelegate.visibility ||
      existingCandlesCount != oldDelegate.existingCandlesCount ||
      totalExpectedCandles != oldDelegate.totalExpectedCandles;
}

class VolumePainter extends CustomPainter {
  final List<CandleData> candles;
  final int? selectedVolumeIndex;
  final bool volumeEnabled;
  final int existingCandlesCount;
  final int totalExpectedCandles; // Add this parameter

  VolumePainter({
    required this.candles,
    required this.volumeEnabled,
    required this.existingCandlesCount,
    required this.totalExpectedCandles,
    this.selectedVolumeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || !volumeEnabled) return;

    // Draw separation line
    if (existingCandlesCount > 0 &&
        totalExpectedCandles > existingCandlesCount) {
      final separationX =
          (existingCandlesCount / totalExpectedCandles) * size.width;

      final separationPaint = Paint()
        ..color = Colors.orange.withAlpha(150)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(separationX, 0),
        Offset(separationX, size.height),
        separationPaint,
      );
    }

    // Find max volume for scaling
    double maxVolume = 0;
    for (var candle in candles) {
      if (candle.volume > maxVolume) {
        maxVolume = candle.volume;
      }
    }

    if (maxVolume == 0) return;

    maxVolume *= 1.1; // Add padding

    final candleWidth = size.width / (candles.length + 1);

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = candleWidth * (i + 1);
      final isSelected = i == selectedVolumeIndex;
      final isExisting = candle.isExisting;

      final barHeight = (candle.volume / maxVolume) * size.height;

      final barLeft = x - candleWidth * 0.3;
      final barRight = x + candleWidth * 0.3;
      final barBottom = size.height;
      final barTop = barBottom - barHeight;

      final isGreen = candle.close > candle.open;
      final baseAlpha = isExisting ? 255 : 180;
      final selectedAlpha = isSelected ? 128 : baseAlpha;
      final barColor =
          (isGreen ? Colors.green : Colors.red).withAlpha(selectedAlpha);

      final barRect = Rect.fromLTRB(barLeft, barTop, barRight, barBottom);

      canvas.drawRect(barRect, Paint()..color = barColor);

      // Draw border for existing or selected volume bars
      if (isExisting || isSelected) {
        canvas.drawRect(
          barRect,
          Paint()
            ..color = isSelected ? Colors.blue : Colors.orange
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? 2 : 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VolumePainter oldDelegate) =>
      candles != oldDelegate.candles ||
      selectedVolumeIndex != oldDelegate.selectedVolumeIndex ||
      existingCandlesCount != oldDelegate.existingCandlesCount ||
      totalExpectedCandles != oldDelegate.totalExpectedCandles;
}
