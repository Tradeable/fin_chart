import 'package:fin_chart/models/settings/axis_settings.dart';
import 'package:fin_chart/utils/calculations.dart';

enum XAxisPos { top, bottom }

class XAxisSettings extends AxisSettings {
  final XAxisPos xAxisPos;

  const XAxisSettings(
      {super.axisTextStyle,
      super.axisColor,
      super.strokeWidth,
      this.xAxisPos = XAxisPos.bottom});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['xAxisPos'] = xAxisPos.name;
    return json;
  }

  factory XAxisSettings.fromJson(Map<String, dynamic> json) {
    return XAxisSettings(
      axisTextStyle: AxisSettings.textStyleFromJson(json['axisTextStyle']),
      strokeWidth: json['strokeWidth'].toDouble(),
      axisColor: colorFromJson(json['axisColor']),
      xAxisPos: XAxisPos.values.firstWhere(
        (pos) => pos.name == json['xAxisPos'],
        orElse: () => XAxisPos.bottom,
      ),
    );
  }
}
