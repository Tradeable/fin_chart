// Add to lib/chart_controller.dart
import 'dart:async';
import 'package:fin_chart/models/layers/layer.dart';

class ChartController {
  final StreamController<ChartEvent> _eventController = StreamController<ChartEvent>.broadcast();
  Stream<ChartEvent> get eventStream => _eventController.stream;
  
  String? _activatedChartId;
  String? get activatedChartId => _activatedChartId;
  
  void setActiveChart(String chartId) {
    if (_activatedChartId != chartId) {
      _activatedChartId = chartId;
      _eventController.add(ChartActivatedEvent(chartId));
    }
  }
  
  void clearActiveChart() {
    _activatedChartId = null;
    _eventController.add(ChartDeactivatedEvent());
  }
  
  void broadcastLayerCreation(Layer layer, String chartId) {
    _eventController.add(LayerCreatedEvent(layer, chartId));
  }
  
  void dispose() {
    _eventController.close();
  }
}

abstract class ChartEvent {}

class ChartActivatedEvent extends ChartEvent {
  final String chartId;
  ChartActivatedEvent(this.chartId);
}

class ChartDeactivatedEvent extends ChartEvent {}

class LayerCreatedEvent extends ChartEvent {
  final Layer layer;
  final String chartId;
  LayerCreatedEvent(this.layer, this.chartId);
}