import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/layers/layer.dart';
import 'package:fin_chart/models/region/region_prop.dart';
import 'package:fin_chart/models/settings/y_axis_settings.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

abstract class PlotRegion with RegionProp {
  final String id;
  final YAxisSettings yAxisSettings;
  final List<Layer> layers;
  late Size yLabelSize;
  late List<double> yValues;
  bool isSelected = false;

  PlotRegion(
      {required this.id,
      required this.yAxisSettings,
      List<Layer>? layers,
      double yMinValue = 0,
      double yMaxValue = 1})
      : layers = layers ?? [] {
    this.yMinValue = yMinValue;
    this.yMaxValue = yMaxValue;
    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    this.yMinValue = yValues.first;
    this.yMaxValue = yValues.last;
    yLabelSize = getLargetRnderBoxSizeForList(
        yValues.map((v) => v.toString()).toList(), yAxisSettings.axisTextStyle);
  }

  PlotRegion? isRegionReadyForResize(Offset selectedPoint) {
    if (isPointOnLine(selectedPoint, Offset(leftPos, bottomPos),
            Offset(rightPos, bottomPos), tolerance: 3) ||
        isPointOnLine(
            selectedPoint, Offset(leftPos, topPos), Offset(rightPos, topPos),
            tolerance: 3)) {
      return this;
    } else {
      return null;
    }
  }

  Widget renderIndicatorToolTip(
      {required Indicator? selectedIndicator,
      required Function(Indicator)? onClick,
      required Function()? onSettings,
      required Function()? onDelete});

  PlotRegion? regionSelect(Offset selectedPoint) {
    if (isPointNearRectFromDiagonalVertices(
        selectedPoint, Offset(leftPos, topPos), Offset(rightPos, bottomPos),
        tolerance: 0)) {
      isSelected = true;
      return this;
    } else {
      isSelected = false;
      return null;
    }
  }

  Offset getRealCoordinates(Offset selectedPoint) {
    return toReal(selectedPoint);
  }

  void addLayer(Layer layer) {
    layers.add(layer);
  }

  void drawAxisValue(Canvas canvas) {
    for (final layer in layers) {
      layer.updateRegionProp(
          leftPos: leftPos,
          topPos: topPos,
          rightPos: rightPos,
          bottomPos: bottomPos,
          xStepWidth: xStepWidth,
          xOffset: xOffset,
          yMinValue: yMinValue,
          yMaxValue: yMaxValue);
      if (yAxisSettings.yAxisPos == YAxisPos.left) {
        layer.drawLeftAxisValues(canvas: canvas);
      } else if (yAxisSettings.yAxisPos == YAxisPos.right) {
        layer.drawRightAxisValues(canvas: canvas);
      }
    }
  }

  void drawYAxis(Canvas canvas);

  void drawLayers(Canvas canvas) {
    for (final layer in layers) {
      layer.drawLayer(canvas: canvas);
    }
  }

  void drawBaseLayer(Canvas canvas);

  void updateData(List<ICandle> data);
}
