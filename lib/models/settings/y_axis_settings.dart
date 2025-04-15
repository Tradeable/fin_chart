import 'package:fin_chart/models/settings/axis_settings.dart';
import 'package:fin_chart/utils/calculations.dart';

enum YAxisPos { left, right }

class YAxisSettings extends AxisSettings {
  final YAxisPos yAxisPos;

  const YAxisSettings(
      {super.axisTextStyle,
      super.axisColor,
      super.strokeWidth,
      this.yAxisPos = YAxisPos.right});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['yAxisPos'] = yAxisPos.name;
    return json;
  }

  factory YAxisSettings.fromJson(Map<String, dynamic> json) {
    return YAxisSettings(
      axisTextStyle: AxisSettings.textStyleFromJson(json['axisTextStyle']),
      strokeWidth: json['strokeWidth'].toDouble(),
      axisColor: colorFromJson(json['axisColor']),
      yAxisPos: YAxisPos.values.firstWhere(
        (pos) => pos.name == json['yAxisPos'],
        orElse: () => YAxisPos.right,
      ),
    );
  }
}
