import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class ShowPayOffGraphTask extends Task {
  int quantity;
  double spotPrice;
  double spotPriceDayDelta;
  double spotPriceDayDeltaPer;

  ShowPayOffGraphTask({
    this.quantity = 0,
    this.spotPrice = 0,
    this.spotPriceDayDelta = 0,
    this.spotPriceDayDeltaPer = 0,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.showPayOffGraph,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['quantity'] = quantity;
    data['spotPrice'] = spotPrice;
    data['spotPriceDayDelta'] = spotPriceDayDelta;
    data['spotPriceDayDeltaPer'] = spotPriceDayDeltaPer;
    return data;
  }

  factory ShowPayOffGraphTask.fromJson(Map<String, dynamic> json) {
    return ShowPayOffGraphTask(
      quantity: json['quantity'] ?? 0,
      spotPrice: (json['spotPrice'] ?? 0).toDouble(),
      spotPriceDayDelta: (json['spotPriceDayDelta'] ?? 0).toDouble(),
      spotPriceDayDeltaPer: (json['spotPriceDayDeltaPer'] ?? 0).toDouble(),
    );
  }
}
