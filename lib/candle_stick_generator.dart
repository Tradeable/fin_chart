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
  final bool isAdjusted; // Track if this candle has been manually adjusted
  final double volume; // Added volume

  CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.isAdjusted = false,
    this.volume = 0,
  });

  CandleData copyWith({
    double? open,
    double? high,
    double? low,
    double? close,
    bool? isAdjusted,
    double? volume,
  }) {
    return CandleData(
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      isAdjusted: isAdjusted ?? this.isAdjusted,
      volume: volume ?? this.volume,
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
    };
  }
}

class CandleStickGenerator extends StatefulWidget {
  final Function(List<ICandle> candles) onCandleDataGenerated;
  const CandleStickGenerator({super.key, required this.onCandleDataGenerated});

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
  SelectionType _lastClickedType = SelectionType.candle;

  // Add visibility state
  TrendlineVisibility trendlineVisibility = TrendlineVisibility.visible;

  // Add time interval selection
  TimeInterval selectedTimeInterval = TimeInterval.m15;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));

  List<math.Point> trendPoints = [
    const math.Point(0, 0.5),
    const math.Point(1, 0.5)
  ];
  List<CandleData> candles = [];
  int? selectedPointIndex;
  int? selectedCandleIndex;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
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
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // First check if a volume bar is selected
      if (selectedVolumeIndex != null) {
        _handleVolumeKeyDown(event);
      } else {
        _handleKeyDown(event); // Original handler for candles
      }
    } else if (event is KeyUpEvent) {
      _handleKeyUp(event); // Original handler
    }
  }

  void _saveAdjustment() {
    if (selectedCandleIndex == null) return;

    setState(() {
      candles[selectedCandleIndex!] = candles[selectedCandleIndex!].copyWith(
        isAdjusted: true,
      );
    });
  }

  void _handleVolumeKeyDown(KeyEvent event) {
    if (selectedVolumeIndex == null) return;

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
    return KeyboardListener(
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: candlesController,
                      decoration: const InputDecoration(
                        labelText: 'Count',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      keyboardType: TextInputType.number,
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
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        _selectCandle(
                            details.localPosition, constraints.biggest);
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
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100, // 1/3 of the main chart height
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
                      onPressed:
                          selectedCandleIndex != null ? _saveAdjustment : null,
                      child: const Text('Save Adjustment'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _toggleTrendlineVisibility,
                      child: Text('Trendline: ${trendlineVisibility.label}'),
                    ),
                    const SizedBox(width: 8),
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
    final candleWidth = size.width / (candles.length + 1);
    final x = position.dx;

    final candleIndex = ((x / candleWidth) - 0.5).round() - 1;

    setState(() {
      selectedVolumeIndex = null;

      if (candleIndex >= 0 && candleIndex < candles.length) {
        selectedCandleIndex = candleIndex;
      } else {
        selectedCandleIndex = null;
      }

      _lastClickedType = SelectionType.candle;
    });
  }

  void _selectVolume(Offset position, Size size) {
    final candleWidth = size.width / (candles.length + 1);
    final x = position.dx;

    final volumeIndex = ((x / candleWidth) - 0.5).round() - 1;

    setState(() {
      selectedCandleIndex = null;

      if (volumeIndex >= 0 && volumeIndex < candles.length) {
        selectedVolumeIndex = volumeIndex;
      } else {
        selectedVolumeIndex = null;
      }

      _lastClickedType = SelectionType.volume;
    });
  }

  void _generateCandles() {
    final min = double.parse(minController.text);
    final max = double.parse(maxController.text);
    final volumeMin = double.parse(volumeMinController.text);
    final volumeMax = double.parse(volumeMaxController.text);
    final numCandles = int.parse(candlesController.text);
    final random = math.Random();

    setState(() {
      final newCandles = <CandleData>[];
      double lastClose = (max + min) / 2;

      for (int i = 0; i < numCandles; i++) {
        // If there's an existing adjusted candle at this index, keep it
        if (i < candles.length && candles[i].isAdjusted) {
          newCandles.add(candles[i]);
          continue;
        }

        final x = i / (numCandles - 1);
        final trendValue = 1 - _interpolateTrendValue(x);
        final range = (max - min) * 0.1;

        final open = lastClose + (random.nextDouble() - 0.5) * range * 0.5;
        final targetPrice = min + (max - min) * trendValue;
        final close = targetPrice + (random.nextDouble() - 0.5) * range;

        final high = math.max(open, close) + random.nextDouble() * range * 0.5;
        final low = math.min(open, close) - random.nextDouble() * range * 0.5;

        // Generate random volume
        final volume =
            volumeMin + random.nextDouble() * (volumeMax - volumeMin);

        newCandles.add(CandleData(
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ));

        lastClose = close;
      }

      candles = newCandles;

      // Convert CandleData to ICandle format and pass to callback
      final iCandles = _convertToICandles(candles);
      widget.onCandleDataGenerated(iCandles);
    });
  }

  List<ICandle> _convertToICandles(List<CandleData> candleDataList) {
    final iCandles = <ICandle>[];
    DateTime currentDate = startDate;

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

      // Increment date by selected interval
      currentDate = currentDate.add(selectedTimeInterval.duration);
    }

    return iCandles;
  }

  void _handleDoubleTap(Offset position, Size size) {
    int? nearbyPointIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < trendPoints.length; i++) {
      final point = trendPoints[i];
      final dx = (point.x * size.width) - position.dx;
      final dy = (point.y * size.height) - position.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < 20 && distance < minDistance) {
        // 20 pixels threshold
        minDistance = distance;
        nearbyPointIndex = i;
      }
    }

    setState(() {
      if (nearbyPointIndex != null) {
        // Don't remove first or last point
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
      _generateCandles(); // Regenerate candles after removing point
    });
  }

  void _selectPoint(Offset position, Size size) {
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

    double x = position.dx / size.width;
    double y = position.dy / size.height;

    y = y.clamp(0.0, 1.0).toDouble();

    setState(() {
      if (selectedPointIndex == 0) {
        trendPoints[0] = math.Point(0, y);
      } else if (selectedPointIndex == trendPoints.length - 1) {
        trendPoints[trendPoints.length - 1] = math.Point(1.0, y);
      } else {
        final prevX = trendPoints[selectedPointIndex! - 1].x;
        final nextX = trendPoints[selectedPointIndex! + 1].x;
        x = x.clamp(prevX, nextX).toDouble();
        trendPoints[selectedPointIndex!] = math.Point(x, y);
      }

      _generateCandles();
    });
  }

  void _addTrendPoint(Offset position, Size size) {
    final x = position.dx / size.width;
    final y = position.dy / size.height;

    setState(() {
      trendPoints.add(math.Point(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)));
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

  TrendLinePainter({
    required this.points,
    required this.candles,
    required this.visibility,
    this.selectedPointIndex,
    this.selectedCandleIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

      final yHigh = _priceToY(candle.high, size.height);
      final yLow = _priceToY(candle.low, size.height);
      final yOpen = _priceToY(candle.open, size.height);
      final yClose = _priceToY(candle.close, size.height);

      // Draw wick
      canvas.drawLine(
          Offset(x, yHigh),
          Offset(x, yLow),
          Paint()
            ..color = (candle.close > candle.open ? Colors.green : Colors.red)
                .withAlpha(isSelected ? 128 : 255));

      // Draw candle body
      final bodyPaint = Paint()
        ..color = (candle.close > candle.open ? Colors.green : Colors.red)
            .withAlpha(isSelected ? 128 : 255);

      final bodyRect = Rect.fromPoints(
        Offset(x - candleWidth * 0.3, yOpen),
        Offset(x + candleWidth * 0.3, yClose),
      );

      canvas.drawRect(bodyRect, bodyPaint);

      // Draw blue border for selected candle
      if (isSelected) {
        canvas.drawRect(
          bodyRect,
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  double _priceToY(double price, double height) {
    final min = double.parse(_CandleStickGeneratorState().minController.text);
    final max = double.parse(_CandleStickGeneratorState().maxController.text);
    return height * (1 - (price - min) / (max - min));
  }

  @override
  bool shouldRepaint(covariant TrendLinePainter oldDelegate) =>
      points != oldDelegate.points ||
      candles != oldDelegate.candles ||
      selectedPointIndex != oldDelegate.selectedPointIndex ||
      visibility != oldDelegate.visibility;
}

class VolumePainter extends CustomPainter {
  final List<CandleData> candles;
  final int? selectedVolumeIndex;

  VolumePainter({
    required this.candles,
    this.selectedVolumeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Find max volume for scaling
    double maxVolume = 0;
    for (var candle in candles) {
      if (candle.volume > maxVolume) {
        maxVolume = candle.volume;
      }
    }

    // Add 10% padding to max volume
    maxVolume *= 1.1;

    final candleWidth = size.width / (candles.length + 1);

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = candleWidth * (i + 1);
      final isSelected = i == selectedVolumeIndex;

      // Calculate bar height based on volume relative to max
      final barHeight = (candle.volume / maxVolume) * size.height;

      // Calculate bar position
      final barLeft = x - candleWidth * 0.3;
      final barRight = x + candleWidth * 0.3;
      final barBottom = size.height;
      final barTop = barBottom - barHeight;

      // Draw volume bar with color based on candle
      final isGreen = candle.close > candle.open;
      final barColor = (isGreen ? Colors.green : Colors.red)
          .withAlpha(isSelected ? 128 : 255);

      final barRect = Rect.fromLTRB(barLeft, barTop, barRight, barBottom);

      canvas.drawRect(barRect, Paint()..color = barColor);

      // Draw border for selected volume bar
      if (isSelected) {
        canvas.drawRect(
          barRect,
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VolumePainter oldDelegate) =>
      candles != oldDelegate.candles ||
      selectedVolumeIndex != oldDelegate.selectedVolumeIndex;
}
