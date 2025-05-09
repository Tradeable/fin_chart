import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/models/region/plot_region.dart';
import 'package:fin_chart/models/settings/y_axis_settings.dart';
import 'package:fin_chart/utils/constants.dart';
import 'package:flutter/material.dart';

class PanelPlotRegion extends PlotRegion {
  final Indicator indicator;

  PanelPlotRegion({required this.indicator, required super.yAxisSettings})
      : super(id: indicator.id);

  @override
  void updateRegionProp(
      {required double leftPos,
      required double topPos,
      required double rightPos,
      required double bottomPos,
      required double xStepWidth,
      required double xOffset,
      required double yMinValue,
      required double yMaxValue,
      bool invertYAxis = false}) {
    indicator.updateRegionProp(
        leftPos: leftPos,
        topPos: topPos,
        rightPos: rightPos,
        bottomPos: bottomPos,
        xStepWidth: xStepWidth,
        xOffset: xOffset,
        yMinValue: yMinValue,
        yMaxValue: yMaxValue,
        invertYAxis: invertYAxis);
    super.updateRegionProp(
        leftPos: leftPos,
        topPos: topPos,
        rightPos: rightPos,
        bottomPos: bottomPos,
        xStepWidth: xStepWidth,
        xOffset: xOffset,
        yMinValue: yMinValue,
        yMaxValue: yMaxValue,
        invertYAxis: invertYAxis);
  }

  @override
  void drawBaseLayer(Canvas canvas) {
    indicator.drawIndicator(canvas: canvas);
  }

  @override
  void updateData(List<ICandle> data) {
    indicator.updateData(data);
    yMinValue = indicator.yValues.first;
    yMaxValue = indicator.yValues.last;
  }

  @override
  void drawYAxis(Canvas canvas) {
    // Choose direction based on inversion setting
    Iterable<double> valuesToDraw = invertYAxis
        ? indicator.yValues.reversed // From highest to lowest when inverted
        : indicator.yValues; // From lowest to highest normally

    for (double value in valuesToDraw) {
      double pos = toY(value);

      if (!(value == indicator.yValues.first ||
          value == indicator.yValues.last)) {
        canvas.drawLine(Offset(leftPos, pos), (Offset(rightPos, pos)), Paint());
        final TextPainter text = TextPainter(
          text: TextSpan(
            text: value.toStringAsFixed(2),
            style: yAxisSettings.axisTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        if (yAxisSettings.yAxisPos == YAxisPos.left) {
          text.paint(
              canvas,
              Offset(leftPos - (text.width + yLabelPadding / 2),
                  pos - text.height / 2));
        }
        if (yAxisSettings.yAxisPos == YAxisPos.right) {
          text.paint(canvas,
              Offset(rightPos + yLabelPadding / 2, pos - text.height / 2));
        }
      }
    }

    if (yAxisSettings.yAxisPos == YAxisPos.left) {
      canvas.drawLine(
          Offset(leftPos, topPos),
          Offset(leftPos, bottomPos),
          Paint()
            ..color = yAxisSettings.axisColor
            ..strokeWidth = yAxisSettings.strokeWidth);
    }
    if (yAxisSettings.yAxisPos == YAxisPos.right) {
      canvas.drawLine(
          Offset(rightPos, topPos),
          Offset(rightPos, bottomPos),
          Paint()
            ..color = yAxisSettings.axisColor
            ..strokeWidth = yAxisSettings.strokeWidth);
    }
  }

  @override
  Widget renderIndicatorToolTip(
      {required Indicator? selectedIndicator,
      required Function(Indicator)? onClick,
      required Function()? onSettings,
      required Function()? onDelete}) {
    return Positioned(
        left: leftPos,
        top: topPos + 10,
        child: indicator.indicatorToolTip(
            selectedIndicator: selectedIndicator,
            onClick: onClick,
            onSettings: onSettings,
            onDelete: onDelete));
  }
}
