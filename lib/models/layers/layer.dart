import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/layer_type.dart';
import 'package:fin_chart/models/layers/arrow.dart';
import 'package:fin_chart/models/layers/circular_area.dart';
import 'package:fin_chart/models/layers/crosshair.dart';
import 'package:fin_chart/models/layers/horizontal_line.dart';
import 'package:fin_chart/models/layers/label.dart';
import 'package:fin_chart/models/layers/rect_area.dart';
import 'package:fin_chart/models/layers/trend_line.dart';
import 'package:fin_chart/models/region/region_prop.dart';
import 'package:flutter/material.dart';

abstract class Layer with RegionProp {
  final String id;
  final LayerType type;
  bool isLocked = false;
  bool isSelected = false;

  Layer({required this.id, required this.type, required this.isLocked});

  Layer.fromTool({required this.id, required this.type});

  factory Layer.fromJson({required Map<String, dynamic> json}) {
    switch ((json['type'] as String).toLayerType()) {
      case LayerType.circularArea:
        return CircularArea.fromJson(json: json);
      case LayerType.label:
        return Label.fromJson(json: json);
      case LayerType.horizontalLine:
        return HorizontalLine.fromJson(json: json);
      case LayerType.horizontalBand:
        return HorizontalBand.fromJson(json: json);
      case LayerType.trendLine:
        return TrendLine.fromJson(json: json);
      case LayerType.rectArea:
        return RectArea.fromJson(json: json);
      case LayerType.arrow:
        return Arrow.fromJson(json: json);
      case LayerType.verticalLine:
        return VerticalLine.fromJson(json: json);
      case LayerType.parallelChannel:
        return ParallelChannel.fromJson(json: json);
      case LayerType.crosshair:
        return Crosshair.fromJson(json: json);
      default:
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'isLocked': isLocked,
      'isSelectd': isSelected
    };
  }

  void drawLayer({required Canvas canvas});

  void drawRightAxisValues({required Canvas canvas}) {}

  void drawLeftAxisValues({required Canvas canvas}) {}

  void drawBottomAxisValues({required Canvas canvas}) {}

  void drawTopAxisValues({required Canvas canvas}) {}

  Layer? onTapDown({required TapDownDetails details}) {
    return null;
  }

  void onScaleUpdate({required ScaleUpdateDetails details}) {}

  void onScaleStart({required ScaleStartDetails details}) {}

  void onUpdateData({required List<ICandle> data}) {}

  void onAimationUpdate(
      {required Canvas canvas, required double animationValue}) {}

  void showSettingsDialog(BuildContext context, Function(Layer) onUpdate) {}

  Widget layerToolTip(
      {Widget? child,
      required Function()? onSettings,
      required Function()? onLockUpdate,
      required Function()? onDelete}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.drag_indicator,
            color: Colors.grey,
          ),
          child ??
              const SizedBox(
                width: 0,
                height: 0,
              ),
          IconButton(onPressed: onSettings, icon: const Icon(Icons.settings)),
          IconButton(
              onPressed: onLockUpdate,
              icon: isLocked
                  ? const Icon(Icons.lock_outline_rounded)
                  : const Icon(Icons.lock_open_rounded)),
          IconButton(
              onPressed: onDelete, icon: const Icon(Icons.delete_rounded))
        ],
      ),
    );
  }
}
