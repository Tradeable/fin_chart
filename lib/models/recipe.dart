import 'package:fin_chart/models/chart_settings.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/models/i_candle.dart';
import 'package:fin_chart/utils/constants.dart';

class Recipe {
  final List<ICandle> data;
  final List<Task> tasks;
  final ChartSettings chartSettings;
  String version;
  final List<FundamentalEvent> fundamentalEvents;

  Recipe(
      {required this.data,
      required this.tasks,
      required this.chartSettings,
      this.version = packageVersion,
      this.fundamentalEvents = const []});

  Map<String, dynamic> toJson() {
    return {
      'version': packageVersion,
      'data': data.map((candle) => candle.toJson()).toList(),
      'chartSettings': chartSettings.toJson(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'fundamentalEvents': fundamentalEvents.map((event) => event.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      version: json['version'],
      data: (json['data'] as List)
          .map((candle) => ICandle.fromJson(candle))
          .toList(),
      chartSettings: ChartSettings.fromJson(json['chartSettings']),
      tasks:
          (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
      fundamentalEvents: json.containsKey('fundamentalEvents')
          ? (json['fundamentalEvents'] as List)
              .map((event) => FundamentalEvent.fromJson(event))
              .toList()
          : [],
    );
  }
}
