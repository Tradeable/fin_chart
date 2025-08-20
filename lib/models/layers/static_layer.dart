import 'package:fin_chart/models/layers/layer.dart';
import 'package:flutter/material.dart';

abstract class StaticLayer extends Layer {
  StaticLayer({required super.id, required super.type}) : super(isLocked: true);

  // Override interactive methods to be non-functional
  @override
  Layer? onTapDown({required TapDownDetails details}) {
    // Return null to prevent selection and dragging
    return null;
  }

  @override
  void onScaleUpdate({required ScaleUpdateDetails details}) {
    // Do nothing
  }

  @override
  void onScaleStart({required ScaleStartDetails details}) {
    // Do nothing
  }
}
