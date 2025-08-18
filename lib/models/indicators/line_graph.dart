import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/indicators/indicator.dart';
import 'package:fin_chart/ui/indicator_settings/line_graph_settings_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class LineGraph extends Indicator {
  Color lineColor;
  double strokeWidth;

  final List<ICandle> candles = [];

  LineGraph({
    this.lineColor = Colors.blue,
    this.strokeWidth = 2.0,
  }) : super(
            id: 'line_graph_main', // Fixed ID
            type: IndicatorType.lineGraph,
            displayMode: DisplayMode.main);

  LineGraph._({
    required super.id,
    required super.type,
    required super.displayMode,
    this.lineColor = Colors.blue,
    this.strokeWidth = 2.0,
  });

  @override
  drawIndicator({required Canvas canvas}) {
    if (candles.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(toX(0), toY(candles[0].close));

    for (int i = 1; i < candles.length; i++) {
      path.lineTo(toX(i.toDouble()), toY(candles[i].close));
    }

    canvas.drawPath(path, paint);
  }

  @override
  updateData(List<ICandle> data) {
    if (data.isEmpty) return;
    candles.clear();
    candles.addAll(data);
  }

  @override
  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) => LineGraphSettingsDialog(
        indicator: this,
        onUpdate: onUpdate as Function(LineGraph),
      ),
    );
  }

  @override
  Widget indicatorToolTip(
      {Widget? child,
      required Indicator? selectedIndicator,
      required Function(Indicator)? onClick,
      required Function()? onSettings,
      required Function()? onDelete}) {
    return InkWell(
        onTap: () {
          onClick?.call(this);
        },
        child: selectedIndicator == this
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Line Graph"),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: onSettings,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                    ),
                    // No delete or lock button for this special indicator
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  "Line Graph",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ));
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['lineColor'] = colorToJson(lineColor);
    json['strokeWidth'] = strokeWidth;
    return json;
  }

  factory LineGraph.fromJson(Map<String, dynamic> json) {
    return LineGraph._(
      id: json['id'],
      type: IndicatorType.lineGraph,
      displayMode: DisplayMode.main,
      lineColor: json['lineColor'] != null
          ? colorFromJson(json['lineColor'])
          : Colors.blue,
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
    );
  }
}
