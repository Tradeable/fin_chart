import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/models/layers/scanner_layer.dart';
import 'package:flutter/material.dart';

abstract class PatternScanner {
  ScannerType get type;
  String get name;
  Color get color;
  List<ScannerLayer> scan(List<ICandle> candles);
}
