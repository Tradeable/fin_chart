import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/option_leg.dart';
import 'package:fin_chart/utils/calculations.dart';

class ChooseBucketRowsTask extends Task {
  String optionChainId;
  List<OptionLeg>? bucketRows;
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
          ? List<OptionLeg>.from(
              json['bucketRows'].map((e) => OptionLeg.fromJson(e)))
          : null,
      maxSelectableRows: json['maxSelectableRows'],
    );
  }

  List<Map<int, int>>? getLegacyBucketRows() {
    return bucketRows?.map((e) => e.toLegacyFormat()).toList();
  }

  void setLegacyBucketRows(List<Map<int, int>>? legacyRows, {String symbol = '', DateTime? expiry, List<double>? strikes, List<double>? callPremiums, List<double>? putPremiums}) {
    if (legacyRows != null) {
      bucketRows = legacyRows.map((e) {
        final rowIndex = e.keys.first;
        final side = e.values.first;
        final strike = strikes != null && rowIndex < strikes.length ? strikes[rowIndex] : 0.0;
        final premium = side == 0 && callPremiums != null && rowIndex < callPremiums.length ? 
            callPremiums[rowIndex] : 
            (side == 1 && putPremiums != null && rowIndex < putPremiums.length ? putPremiums[rowIndex] : 0.0);
        
        return OptionLeg.fromLegacyFormat(
          e, 
          symbol: symbol, 
          expiry: expiry, 
          strike: strike, 
          premium: premium
        );
      }).toList();
    } else {
      bucketRows = null;
    }
  }
} 