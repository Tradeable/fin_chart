import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class PreviewData {
  final List<OptionData> optionData;
  final List<ColumnConfig> columns;
  final OptionChainVisibility visibility;
  final int? selectedRowIndex;
  final int? correctRowIndex;
  double? strikePrice;
  DateTime? expiryDate;

  PreviewData(
      {required this.optionData,
      required this.columns,
      required this.visibility,
      this.selectedRowIndex,
      this.correctRowIndex,
      this.strikePrice,
      this.expiryDate});

  factory PreviewData.fromJson(Map<String, dynamic> json) => PreviewData(
      optionData: (json['optionData'] as List)
          .map((e) => OptionData.fromJson(e))
          .toList(),
      columns: (json['columns'] as List)
          .map((e) => ColumnConfig.fromJson(e))
          .toList(),
      visibility: OptionChainVisibility.values[json['visibility'] as int],
      selectedRowIndex: json['selectedRowIndex'] as int?,
      correctRowIndex: json['correctRowIndex'] as int?,
      strikePrice: (json['strikePrice'] as num?)?.toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null);

  Map<String, dynamic> toJson() => {
        'optionData': optionData.map((e) => e.toJson()).toList(),
        'columns': columns.map((e) => e.toJson()).toList(),
        'visibility': visibility.index,
        'selectedRowIndex': selectedRowIndex,
        'correctRowIndex': correctRowIndex,
        'strikePrice': strikePrice,
        'expiryDate': expiryDate?.toIso8601String()
      };
}
