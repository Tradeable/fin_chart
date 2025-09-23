import 'package:fin_chart/models/enums/action_type.dart';
import 'package:fin_chart/models/enums/task_type.dart';
import 'package:fin_chart/models/tasks/task.dart';
import 'package:fin_chart/option_chain/models/option_leg.dart';
import 'package:fin_chart/utils/calculations.dart';

class HighlightCorrectOptionChainValueTask extends Task {
  String optionChainId;
  List<int> correctRowIndex;
  List<OptionLeg>? bucketRows;

  HighlightCorrectOptionChainValueTask({
    required this.optionChainId,
    required this.correctRowIndex,
    this.bucketRows,
  }) : super(
          id: generateV4(),
          actionType: ActionType.empty,
          taskType: TaskType.highlightCorrectOptionChainValue,
        );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['optionChainId'] = optionChainId;
    data['correctRowIndex'] = correctRowIndex;
    if (bucketRows != null) {
      data['bucketRows'] = bucketRows!.map((e) => e.toJson()).toList();
    }
    return data;
  }

  factory HighlightCorrectOptionChainValueTask.fromJson(
      Map<String, dynamic> json) {
    List<OptionLeg>? bucketRows;
    
    if (json['bucketRows'] != null) {
      if (json['bucketRows'] is List && json['bucketRows'].isNotEmpty) {
        if (json['bucketRows'][0] is Map && json['bucketRows'][0].containsKey('rowIndex')) {
          bucketRows = List<OptionLeg>.from(
              json['bucketRows'].map((e) => OptionLeg.fromJson(e)));
        } else {
          final legacyRows = List<Map<int, int>>.from(json['bucketRows'].map((map) =>
              Map<int, int>.from(map.map((k, v) => MapEntry(int.parse(k), v)))));
          bucketRows = legacyRows.map((e) => OptionLeg.fromLegacyFormat(e)).toList();
        }
      }
    }

    return HighlightCorrectOptionChainValueTask(
      optionChainId: json['optionChainId'],
      correctRowIndex: json['correctRowIndex'] is List
          ? List<int>.from(json['correctRowIndex'])
          : json['correctRowIndex'] is int
              ? [json['correctRowIndex']]
              : [],
      bucketRows: bucketRows,
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
