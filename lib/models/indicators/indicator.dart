import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/region/region_prop.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

enum IndicatorType {
  rsi,
  macd,
  sma,
  ema,
  bollingerBand,
  stochastic,
  mfi,
  adx,
  atr
}

enum DisplayMode { main, panel }

abstract class Indicator with RegionProp {
  final String id;
  final IndicatorType type;
  final DisplayMode displayMode;
  late List<double> yValues;
  late Size yLabelSize;

  Indicator(
      {required this.id,
      required this.type,
      required this.displayMode,
      double yMinValue = 0,
      double yMaxValue = 1}) {
    this.yMinValue = yMinValue;
    this.yMaxValue = yMaxValue;
    yValues = generateNiceAxisValues(yMinValue, yMaxValue);
    this.yMinValue = yValues.first;
    this.yMaxValue = yValues.last;
  }

  calculateYValueRange(List<ICandle> data) {}

  updateData(List<ICandle> data);

  drawIndicator({required Canvas canvas});

  showIndicatorSettings(
      {required BuildContext context, required Function(Indicator) onUpdate});

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    child ?? Text(type.name.toUpperCase()),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: onSettings,
                      icon: const Icon(
                        Icons.settings,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_rounded,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Text(
                  type.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ));
  }

  factory Indicator.fromJson({required Map<String, dynamic> json}) {
    IndicatorType type = json['type'].toString().toIndicatorType()!;
    switch (type) {
      case IndicatorType.rsi:
        return Rsi.fromJson(json);
      case IndicatorType.macd:
        return Macd.fromJson(json);
      case IndicatorType.sma:
        return Sma.fromJson(json);
      case IndicatorType.ema:
        return Ema.fromJson(json);
      case IndicatorType.bollingerBand:
        return BollingerBands.fromJson(json);
      case IndicatorType.stochastic:
        return Stochastic.fromJson(json);
      case IndicatorType.atr:
        return Atr.fromJson(json);
      case IndicatorType.mfi:
        return Mfi.fromJson(json);
      case IndicatorType.adx:
        return Adx.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'displayMode': displayMode.name,
    };
  }
}

extension IndicatorTypeParsingExtension on String {
  IndicatorType? toIndicatorType({bool ignoreCase = true}) {
    final input = ignoreCase ? toLowerCase() : this;

    for (final type in IndicatorType.values) {
      final typeName = type.toString().split('.').last;
      final compareValue = ignoreCase ? typeName.toLowerCase() : typeName;

      if (input == compareValue) {
        return type;
      }
    }

    return null;
  }
}
