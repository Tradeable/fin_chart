import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

abstract class AxisSettings {
  final TextStyle axisTextStyle;
  final double strokeWidth;
  final Color axisColor;

  const AxisSettings(
      {this.axisTextStyle = const TextStyle(
          color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
      this.strokeWidth = 1,
      this.axisColor = Colors.black});

  Map<String, dynamic> toJson() {
    return {
      'axisTextStyle': {
        'color': colorToJson(axisTextStyle.color),
        'fontSize': axisTextStyle.fontSize,
        'fontWeight': fontWeightToJson(axisTextStyle.fontWeight)
      },
      'strokeWidth': strokeWidth,
      'axisColor': colorToJson(axisColor),
    };
  }

  static TextStyle textStyleFromJson(Map<String, dynamic> json) {
    return TextStyle(
      color: colorFromJson(json['color']),
      fontSize: json['fontSize'].toDouble(),
      fontWeight: fontWeightFromJson(json['fontWeight']),
    );
  }
}
