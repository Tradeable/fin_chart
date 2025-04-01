import 'package:fin_chart/chart_painter.dart';
import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/chart_settings.dart';
import 'package:fin_chart/models/enums/data_fit_type.dart';
import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/recipe.dart';
import 'package:fin_chart/models/region/main_plot_region.dart';
import 'package:fin_chart/models/region/panel_plot_region.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/models/settings/x_axis_settings.dart';
// import 'package:fin_chart/ui/add_event_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:fin_chart/utils/constants.dart';
import 'package:flutter/material.dart';

import 'models/settings/y_axis_settings.dart';

class Chart extends StatefulWidget {
  final EdgeInsets? padding;
  final DataFit dataFit;
  final YAxisSettings? yAxisSettings;
  final XAxisSettings? xAxisSettings;
  final List<ICandle> candles;
  final Function(Offset, Offset)? onInteraction;
  final Function(PlotRegion region, Layer layer)? onLayerSelect;
  final Function(PlotRegion region)? onRegionSelect;
  final Function(Indicator indicator)? onIndicatorSelect;
  final Recipe? recipe;
  // final List<FundamentalEvent> fundamentalEvents;

  const Chart({
    super.key,
    required this.candles,
    this.padding = const EdgeInsets.all(8),
    this.dataFit = DataFit.adaptiveWidth,
    this.onInteraction,
    this.onLayerSelect,
    this.onRegionSelect,
    this.onIndicatorSelect,
    this.yAxisSettings = const YAxisSettings(),
    this.xAxisSettings = const XAxisSettings(),
    this.recipe,
    // this.fundamentalEvents = const [],
  });

  factory Chart.from(
      {required GlobalKey key,
      required Recipe recipe,
      Function(Offset, Offset)? onInteraction,
      Function(PlotRegion region, Layer layer)? onLayerSelect,
      final Function(PlotRegion region)? onRegionSelect,
      final Function(Indicator indicator)? onIndicatorSelect}) {
    return Chart(
      key: key,
      candles: recipe.data,
      padding: const EdgeInsets.all(8),
      dataFit: recipe.chartSettings.dataFit,
      onInteraction: onInteraction,
      onLayerSelect: onLayerSelect,
      onRegionSelect: onRegionSelect,
      onIndicatorSelect: onIndicatorSelect,
      yAxisSettings: recipe.chartSettings.yAxisSettings,
      xAxisSettings: recipe.chartSettings.xAxisSettings,
      recipe: recipe,
      // fundamentalEvents: recipe.fundamentalEvents, 
    );
  }

  @override
  State<Chart> createState() => ChartState();
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  double leftPos = 0;
  double topPos = 0;
  double rightPos = 0;
  double bottomPos = 0;

  double xOffset = 0;

  double horizontalScale = 1;
  double previousHorizontalScale = 1.0;
  Offset? lastFocalPoint;

  double yLabelWidth = 21;
  double xLabelHeight = 21;

  double yMinValue = 0;
  double yMaxValue = 1;
  double xStepWidth = candleWidth * 2;

  late AnimationController _swipeAnimationController;
  double _swipeVelocity = 0;
  bool _isAnimating = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  List<PlotRegion> regions = [];

  Layer? selectedLayer;
  bool isLayerGettingAdded = false;

  List<ICandle> currentData = [];
  List<PlotRegion> selectedRegionForResize = [];
  PlotRegion? selectedRegion;
  Indicator? selectedIndicator;

  bool isInit = true;

  Offset layerToolBoxOffset = Offset.zero;


  bool isUserInteracting = false;
  
  FundamentalEvent? selectedEvent;
  // List<FundamentalEvent> fundamentalEvents = [];
  bool isWaitingForEventPosition = false;
  double? eventSelectionPosition;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _initializeFromFactory();
    } else {
      _initializeDefault();
    }
    _initializeControllers();
  }

  void _initializeDefault() {
    currentData.addAll(widget.candles);
    regions.add(MainPlotRegion(
      candles: currentData,
      yAxisSettings: widget.yAxisSettings!,
      // fundamentalEvents: fundamentalEvents,
    ));
  }

  void _initializeFromFactory() {
    Recipe recipe = widget.recipe!;

    (double, double) range = findMinMaxWithPercentage(recipe.data);

    List<double> yValues = generateNiceAxisValues(range.$1, range.$2);

    yMinValue = yValues.first;
    yMaxValue = yValues.last;

    regions.add(MainPlotRegion(
        id: recipe.chartSettings.mainPlotRegionId,
        candles: currentData,
        // fundamentalEvents: recipe.fundamentalEvents ?? [],
        yAxisSettings: widget.yAxisSettings!,
        yMinValue: yMinValue,
        yMaxValue: yMaxValue));

       (regions[0] as MainPlotRegion).updateFundamentalEvents(recipe.fundamentalEvents ?? []);
  }

  void _initializeControllers() {
    xStepWidth = candleWidth * 2;
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_handleSwipeAnimation);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void addIndicator(Indicator indicator) {
    setState(() {
      if (indicator.displayMode == DisplayMode.panel) {
        PanelPlotRegion region = PanelPlotRegion(
            indicator: indicator, yAxisSettings: widget.yAxisSettings!);

        double addRegionWeight = 1 / (regions.length + 1);
        double multiplier = 1 - addRegionWeight;

        _updateRegionBounds(multiplier);

        if (widget.recipe != null) {
          indicator.calculateYValueRange(widget.recipe!.data);
        }

        region.updateData(currentData);

        region.updateRegionProp(
            leftPos: leftPos,
            topPos: topPos + (bottomPos - topPos) * multiplier,
            rightPos: rightPos,
            bottomPos: bottomPos,
            xStepWidth: xStepWidth,
            xOffset: xOffset,
            yMinValue: indicator.yMinValue,
            yMaxValue: indicator.yMaxValue);

        regions.add(region);
      } else if (indicator.displayMode == DisplayMode.main) {
        for (PlotRegion region in regions) {
          if (region is MainPlotRegion) {
            region.indicators.add(indicator);
            region.updateData(currentData);
          }
        }
      }
    });
  }

  void removeIndicator(Indicator indicator) {
    setState(() {
      if (indicator.displayMode == DisplayMode.panel) {
        regions.removeWhere((region) =>
            region is PanelPlotRegion && (region).indicator == indicator);

        double multiplier = 1 +
            ((indicator.bottomPos - indicator.topPos) /
                (indicator.topPos - topPos + bottomPos - indicator.bottomPos));
        _updateRegionBounds(multiplier);
      } else if (indicator.displayMode == DisplayMode.main) {
        for (PlotRegion region in regions) {
          if (region is MainPlotRegion) {
            region.indicators.removeWhere((i) => i == indicator);
          }
        }
      }
      selectedIndicator = null;
    });
  }

  void updateLayerGettingAddedState(LayerType layerType) {
    setState(() {
      isLayerGettingAdded = true;
      selectedLayer?.isSelected = false;
      selectedLayer = null;
    });
  }

  void addLayerUsingTool(Layer layer) {
    setState(() {
      selectedLayer = layer;
      selectedRegion?.addLayer(layer);
      isLayerGettingAdded = false;
    });
  }

  void addLayerAtRegion(String regionId, Layer layer) {
    setState(() {
      regions
          .firstWhere((region) => region.id == regionId,
              orElse: () => regions[0])
          .addLayer(layer);
      isLayerGettingAdded = false;
    });
  }

  void addData(List<ICandle> newData, {List<FundamentalEvent>? newEvents}) {
    setState(() {
      currentData.addAll(newData);
      for (int i = 0; i < regions.length; i++) {
        regions[i].updateData(currentData);
        if (regions[i] is MainPlotRegion &&
            newEvents != null &&
            newEvents.isNotEmpty) {
          (regions[i] as MainPlotRegion).updateFundamentalEvents(newEvents);
        }
      }
    });
  }

  // void addEvent(FundamentalEvent event) {
  //   setState(() {
  //     for (int i = 0; i < regions.length; i++) {
  //       if (regions[i] is MainPlotRegion) {
  //         (regions[i] as MainPlotRegion).updateFundamentalEvents([event]);
  //       }
  //     }
  //   });
  // }

  void addFundamentalEvents(List<FundamentalEvent> newEvents) {
    setState(() {
      for (int i = 0; i < regions.length; i++) {
        if (regions[i] is MainPlotRegion) {
          (regions[i] as MainPlotRegion).updateFundamentalEvents(newEvents);
        }
      }
      if (!isUserInteracting) {
        xOffset = _getMaxLeftOffset();
      }
    });
  }

  void addFundamentalEvent(FundamentalEvent event) {
    setState(() {
      for (int i = 0; i < regions.length; i++) {
        if (regions[i] is MainPlotRegion) {
          (regions[i] as MainPlotRegion).updateFundamentalEvents([event]);
          break;
        }
      }
      isWaitingForEventPosition = false;
    });
  }

  Future<bool> addDataWithAnimation(
      List<ICandle> newData, Duration durationPerCandle) async {
    for (ICandle iCandle in newData) {
      setState(() {
        currentData.add(iCandle);
        for (int i = 0; i < regions.length; i++) {
          regions[i].updateData(currentData);
        }
      });
      await Future.delayed(durationPerCandle).then((value) {
        if (!isUserInteracting) {
          setState(() {
            xOffset = _getMaxLeftOffset();
          });
        }
      });
    }
    return true;
  }

  void removeLayerById(String layerId) {
    setState(() {
      for (PlotRegion region in regions) {
        region.layers.removeWhere((layer) => layer.id == layerId);
      }
      selectedLayer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: widget.padding,
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxHeight != 0) {
            _recalculate(constraints);
          }
          return Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onDoubleTap: _onDoubleTap,
                  onScaleStart: _onScaleStart,
                  onScaleEnd: _onScaleEnd,
                  onScaleUpdate: (details) =>
                      _onScaleUpdate(details, constraints),
                  child: CustomPaint(
                    painter: ChartPainter(
                        regions: regions,
                        xAxisSettings: widget.xAxisSettings!,
                        xOffset: xOffset,
                        xStepWidth: xStepWidth,
                        dataLength: currentData.length,
                        leftPos: leftPos,
                        topPos: topPos,
                        rightPos: rightPos,
                        bottomPos: bottomPos,
                        data: currentData,
                        selectedLayer: selectedLayer,
                        animationValue: _animation.value,
                        eventSelectionPosition: eventSelectionPosition,),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
              ...regions.map((region) => region.renderIndicatorToolTip(
                  selectedIndicator:
                      widget.recipe != null ? null : selectedIndicator,
                  onClick: (indicator) {
                    widget.onIndicatorSelect?.call(indicator);
                    setState(() {
                      selectedIndicator = indicator;
                    });
                  },
                  onSettings: () {
                    selectedIndicator?.showIndicatorSettings(
                        context: context,
                        onUpdate: (indicator) {
                          setState(() {
                            selectedIndicator = indicator;
                          });
                        });
                  },
                  onDelete: () {
                    removeIndicator(selectedIndicator!);
                  })),
              if (widget.recipe == null)
                selectedLayer == null
                    ? Container()
                    : Positioned(
                        left: layerToolBoxOffset.dx,
                        top: layerToolBoxOffset.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              layerToolBoxOffset += details.delta;
                            });
                          },
                          child: selectedLayer?.layerToolTip(
                                  child: Text(selectedLayer?.type.name ?? ""),
                                  onSettings: () {
                                    selectedLayer?.showSettingsDialog(context,
                                        (layer) {
                                      setState(() {
                                        selectedLayer = layer;
                                      });
                                    });
                                  },
                                  onLockUpdate: () {
                                    setState(() {
                                      if (selectedLayer!.isLocked) {
                                        selectedLayer?.isLocked = false;
                                      } else {
                                        selectedLayer?.isLocked = true;
                                        selectedLayer?.isSelected = false;
                                        selectedLayer = null;
                                      }
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      removeLayerById(selectedLayer!.id);
                                      selectedLayer == null;
                                    });
                                  }) ??
                              Container(),
                        ),
                      ),
            ],
          );
        }));
  }

  void _handleSwipeAnimation() {
    if (!_isAnimating) return;

    setState(() {
      final double progress = _swipeAnimationController.value;
      final double dampedVelocity =
          _swipeVelocity * (1 - progress) * (1 - progress); // Add extra damping
      xOffset = (xOffset + dampedVelocity).clamp(_getMaxLeftOffset(), 0);

      if (progress >= 1.0) {
        _isAnimating = false;
        _swipeVelocity = 0;
      }
    });
  }

  double _getMaxLeftOffset() {
    if (currentData.isEmpty) return 0;

    double lastCandlePosition =
        xStepWidth / 2 + (currentData.length - 1) * xStepWidth;

    if (lastCandlePosition < (rightPos - leftPos) * 0.8) {
      return 0;
    } else {
      return -lastCandlePosition + (rightPos - leftPos) * 0.8;
    }
  }

  _updateRegionBounds(double multiplier) {
    double totalHeight = (bottomPos - topPos) * multiplier;
    double tempTopPos = topPos;
    for (int i = 0; i < regions.length; i++) {
      double height = totalHeight *
          (regions[i].bottomPos - regions[i].topPos) /
          (bottomPos - topPos);

      regions[i].updateRegionProp(
          leftPos: leftPos,
          topPos: tempTopPos,
          rightPos: rightPos,
          bottomPos: tempTopPos + height,
          xStepWidth: xStepWidth,
          xOffset: xOffset,
          yMinValue: regions[i].yMinValue,
          yMaxValue: regions[i].yMaxValue);
      tempTopPos = tempTopPos + height;
    }
  }

  _recalculate(BoxConstraints constraints) {
    for (PlotRegion region in regions) {
      if (region.yLabelSize.width > yLabelWidth) {
        yLabelWidth = region.yLabelSize.width;
      }
    }

    if (widget.yAxisSettings!.yAxisPos == YAxisPos.left) {
      leftPos = yLabelWidth + yLabelPadding;
      rightPos = constraints.maxWidth - yLabelPadding;
    }

    if (widget.xAxisSettings!.xAxisPos == XAxisPos.top) {
      topPos = xLabelHeight + xLabelPadding;
      bottomPos = constraints.maxHeight - xLabelPadding;
    }

    if (widget.yAxisSettings!.yAxisPos == YAxisPos.right) {
      leftPos = yLabelPadding;
      rightPos = constraints.maxWidth - (yLabelWidth + yLabelPadding);
    }

    if (widget.xAxisSettings!.xAxisPos == XAxisPos.bottom) {
      topPos = xLabelPadding;
      bottomPos = constraints.maxHeight - (xLabelHeight + xLabelPadding);
    }

    switch (widget.dataFit) {
      case DataFit.fixedWidth:
        xStepWidth =
            ((rightPos - leftPos) / currentData.length) * horizontalScale;
        break;
      case DataFit.adaptiveWidth:
        xStepWidth = candleWidth * 2 * horizontalScale;
        break;
    }

    if (isInit) {
      regions[0].updateRegionProp(
          leftPos: leftPos,
          topPos: topPos,
          rightPos: rightPos,
          bottomPos: bottomPos,
          xStepWidth: xStepWidth,
          xOffset: xOffset,
          yMinValue: regions[0].yMinValue,
          yMaxValue: regions[0].yMaxValue);
    }

    isInit = false;

    _updateRegionBounds(1);
  }

  _handleSwipeEnd(ScaleEndDetails details) {
    // Calculate velocity and start animation
    _swipeVelocity = details.velocity.pixelsPerSecond.dx *
        0.1; // Reduce velocity sensitivity
    if (_swipeVelocity.abs() > 100) {
      // Increase threshold for animation
      _isAnimating = true;
      _swipeAnimationController.forward(from: 0);
    }
  }

  _onDoubleTap() {
    setState(() {
      horizontalScale = 1;
      previousHorizontalScale = 1;
      //xStepWidth = candleWidth * 2;
      xOffset = 0;
      _isAnimating = false;
      _swipeVelocity = 0;
      layerToolBoxOffset = Offset.zero;
    });
  }

  _onTapDown(TapDownDetails details) {
    setState(() {
      isUserInteracting = true;

      // // Handle event position selection mode
      // if (isWaitingForEventPosition) {
      //   // Get the clicked candle
      //   int candleIndex =
      //       ((details.localPosition.dx - leftPos - xOffset - xStepWidth / 2) /
      //               xStepWidth)
      //           .round();

      //   // Check if index is valid
      //   if (candleIndex >= 0 && candleIndex < currentData.length) {
      //     // Calculate the exact x position using the same formula as used in RegionProp
      //     eventSelectionPosition =
      //         leftPos + xOffset + xStepWidth / 2 + candleIndex * xStepWidth;
      //     DateTime candleDate = currentData[candleIndex].date;

      //     // Show the dialog
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AddEventDialog(
      //           onEventAdded: (event) {
      //             setState(() {
      //               // Find the MainPlotRegion and add the event directly to it
      //               for (PlotRegion region in regions) {
      //                 if (region is MainPlotRegion) {
      //                   region.updateFundamentalEvents([event]);
      //                 }
      //               }
      //               // Clear the selection position when done
      //               isWaitingForEventPosition = false;
      //               eventSelectionPosition = null;
      //             });
      //           },
      //           preSelectedDate: candleDate,
      //         );
      //       },
      //     ).then((_) {
      //       // Clear the selection position when dialog is closed
      //       setState(() {
      //         isWaitingForEventPosition = false;
      //         eventSelectionPosition = null;
      //       });
      //     });
      //   }
      //   return;
      // }

      // Handle fundamental events through the main plot region
      for (PlotRegion region in regions) {
        if (region is MainPlotRegion) {
          region.handleEventTap(details.localPosition);
        }
      }

      selectedEvent = null;
      selectedIndicator = null;

      for (PlotRegion region in regions) {
        if (selectedRegionForResize.length < 2) {
          if (region.isRegionReadyForResize(details.localPosition) != null) {
            selectedRegionForResize.add(region);
          }
        }
      }

      if (selectedRegionForResize.length == 2) {
        selectedLayer?.isSelected = false;
        selectedLayer = null;
        return;
      }

      selectedLayer = null;
      selectedRegion = null;
      for (PlotRegion region in regions) {
        selectedRegion ??= region.regionSelect(details.localPosition);

        if (selectedRegion != null) {
          widget.onRegionSelect?.call(selectedRegion!);
          if (isLayerGettingAdded || isWaitingForEventPosition) {
            widget.onInteraction?.call(
                selectedRegion!.getRealCoordinates(details.localPosition),
                details.localPosition);
          } else {
            for (Layer layer in region.layers) {
              if (selectedLayer == null) {
                selectedLayer = layer.onTapDown(details: details);
                if (selectedLayer != null && selectedRegion != null) {
                  widget.onLayerSelect?.call(selectedRegion!, selectedLayer!);
                }
              } else {
                layer.isSelected = false;
              }
            }
          }
        }
      }
    });
  }

  _onTapUp(TapUpDetails details) {
    setState(() {
      isUserInteracting = false;
    });
  }

  _onScaleStart(ScaleStartDetails details) {
    setState(() {
      _isAnimating = false;
      isUserInteracting = true;
      if (details.pointerCount == 2) {
        previousHorizontalScale = horizontalScale;
        lastFocalPoint = details.focalPoint;
      }
    });
  }

  _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      lastFocalPoint = null;
      isUserInteracting = false;
      _handleSwipeEnd(details);
      selectedRegionForResize.clear();
    });
  }

  _onScaleUpdate(ScaleUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      if (details.pointerCount == 1) {
        if (isLayerGettingAdded && selectedRegion != null) {
          widget.onInteraction?.call(
              selectedRegion!.getRealCoordinates(details.localFocalPoint),
              details.localFocalPoint);
        } else if (selectedLayer == null) {
          if (selectedRegionForResize.length == 2) {
            selectedRegionForResize[0].updateRegionProp(
                leftPos: leftPos,
                topPos: selectedRegionForResize[0].topPos,
                rightPos: rightPos,
                bottomPos: selectedRegionForResize[0].bottomPos +
                    details.focalPointDelta.dy,
                xStepWidth: xStepWidth,
                xOffset: xOffset,
                yMinValue: selectedRegionForResize[0].yMinValue,
                yMaxValue: selectedRegionForResize[0].yMaxValue);

            selectedRegionForResize[1].updateRegionProp(
                leftPos: leftPos,
                topPos: selectedRegionForResize[1].topPos +
                    details.focalPointDelta.dy,
                rightPos: rightPos,
                bottomPos: selectedRegionForResize[1].bottomPos,
                xStepWidth: xStepWidth,
                xOffset: xOffset,
                yMinValue: selectedRegionForResize[1].yMinValue,
                yMaxValue: selectedRegionForResize[1].yMaxValue);
          } else {
            _isAnimating = false;
            xOffset = (xOffset + details.focalPointDelta.dx)
                .clamp(_getMaxLeftOffset(), 0);
          }
        } else {
          selectedLayer?.onScaleUpdate(details: details);
        }
      }
      if (details.pointerCount == 2) {
        final newScale =
            (previousHorizontalScale * details.scale).clamp(0.0, 150.0);
        if (lastFocalPoint != null) {
          final focalPointRatio = lastFocalPoint!.dx / constraints.maxWidth;
          final scaleDiff = newScale - horizontalScale;
          final offsetAdjustment = scaleDiff *
              (candleWidth * 2) *
              currentData.length *
              focalPointRatio;
          xOffset = (xOffset - offsetAdjustment).clamp(_getMaxLeftOffset(), 0);
        }

        horizontalScale = newScale;
        lastFocalPoint = details.localFocalPoint;
        xStepWidth = candleWidth * horizontalScale;
      }
    });
  }

  ChartSettings getChartSettings() {
    return ChartSettings(
        dataFit: widget.dataFit,
        yAxisSettings: widget.yAxisSettings!,
        xAxisSettings: widget.xAxisSettings!,
        mainPlotRegionId:
            regions.firstWhere((region) => region is MainPlotRegion).id);
  }
}
