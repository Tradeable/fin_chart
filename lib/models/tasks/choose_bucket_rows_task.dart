import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/utils/calculations.dart';

class BucketRowSelection {
  final int rowIndex;
  final int side; // 0 for call, 1 for put
  final bool isBuy; // true for buy, false for sell

  BucketRowSelection({
    required this.rowIndex,
    required this.side,
    required this.isBuy,
  });

  Map<String, dynamic> toJson() {
    return {
      'rowIndex': rowIndex,
      'side': side,
      'isBuy': isBuy,
    };
  }

  factory BucketRowSelection.fromJson(Map<String, dynamic> json) {
    return BucketRowSelection(
      rowIndex: json['rowIndex'],
      side: json['side'],
      isBuy: json['isBuy'],
    );
  }

  // For backward compatibility
  Map<int, int> toLegacyFormat() {
    return {rowIndex: side};
  }

  factory BucketRowSelection.fromLegacyFormat(Map<int, int> legacy, {bool isBuy = true}) {
    return BucketRowSelection(
      rowIndex: legacy.keys.first,
      side: legacy.values.first,
      isBuy: isBuy,
    );
  }
}

class ChooseBucketRowsTask extends Task {
  String optionChainId;
  List<BucketRowSelection>? bucketRows;
  int? maxSelectableRows;

  ChooseBucketRowsTask({
    required this.optionChainId,
    this.bucketRows,
    this.maxSelectableRows,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.chooseBucketRows,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    if (bucketRows != null) {
      data['bucketRows'] = bucketRows!.map((e) => e.toJson()).toList();
    }
    data['maxSelectableRows'] = maxSelectableRows;
    return data;
  }

  factory ChooseBucketRowsTask.fromJson(Map<String, dynamic> json) {
    return ChooseBucketRowsTask(
      optionChainId: json['optionChainId'],
      bucketRows: json['bucketRows'] != null
          ? List<BucketRowSelection>.from(
              json['bucketRows'].map((e) => BucketRowSelection.fromJson(e)))
          : null,
      maxSelectableRows: json['maxSelectableRows'],
    );
  }

  // For backward compatibility
  List<Map<int, int>>? getLegacyBucketRows() {
    return bucketRows?.map((e) => e.toLegacyFormat()).toList();
  }

  // For backward compatibility
  void setLegacyBucketRows(List<Map<int, int>>? legacyRows) {
    if (legacyRows != null) {
      bucketRows = legacyRows.map((e) => BucketRowSelection.fromLegacyFormat(e)).toList();
    } else {
      bucketRows = null;
    }
  }
} 