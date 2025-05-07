import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class PreviewData {
  final List<OptionData> optionData;
  final List<ColumnConfig> columns;
  final OptionChainVisibility visibility;
  final int? selectedRowIndex;
  final int? correctRowIndex;

  PreviewData({
    required this.optionData,
    required this.columns,
    required this.visibility,
    this.selectedRowIndex,
    this.correctRowIndex,
  });

  factory PreviewData.fromJson(Map<String, dynamic> json) => PreviewData(
        optionData: (json['optionData'] as List)
            .map((data) => OptionData.fromJson(data))
            .toList(),
        columns: (json['columns'] as List)
            .map((col) => ColumnConfig.fromJson(col))
            .toList(),
        visibility: OptionChainVisibility.values[json['visibility'] as int],
        selectedRowIndex: json['selectedRowIndex'] as int?,
        correctRowIndex: json['correctRowIndex'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'optionData': optionData.map((data) => data.toJson()).toList(),
        'columns': columns.map((col) => col.toJson()).toList(),
        'visibility': visibility.index,
        'selectedRowIndex': selectedRowIndex,
        'correctRowIndex': correctRowIndex,
      };
}
