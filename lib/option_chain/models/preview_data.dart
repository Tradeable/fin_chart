import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_settings.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class PreviewData {
  final List<OptionData> optionData;
  final List<ColumnConfig> columns;
  final OptionChainVisibility visibility;
  List<int> selectedRowIndices;
  List<int> correctRowIndices;
  double? strikePrice;
  DateTime? expiryDate;
  OptionChainSettings? settings;
  bool isEditorMode;

  PreviewData(
      {required this.optionData,
      required this.columns,
      required this.visibility,
      this.selectedRowIndices = const [],
      this.correctRowIndices = const [],
      this.strikePrice,
      this.expiryDate,
      this.settings,
      required this.isEditorMode});

  factory PreviewData.fromJson(Map<String, dynamic> json) => PreviewData(
      optionData: (json['optionData'] as List)
          .map((e) => OptionData.fromJson(e))
          .toList(),
      columns: (json['columns'] as List)
          .map((e) => ColumnConfig.fromJson(e))
          .toList(),
      visibility: OptionChainVisibility.values[json['visibility'] as int],
      selectedRowIndices:
          (json['selectedRowIndices'] as List?)?.cast<int>() ?? [],
      correctRowIndices:
          (json['correctRowIndices'] as List?)?.cast<int>() ?? [],
      strikePrice: (json['strikePrice'] as num?)?.toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      settings: json['settings'] != null
          ? OptionChainSettings.fromJson(json['settings'])
          : null,
      isEditorMode: json['isEditorMode']);

  Map<String, dynamic> toJson() => {
        'optionData': optionData.map((e) => e.toJson()).toList(),
        'columns': columns.map((e) => e.toJson()).toList(),
        'visibility': visibility.index,
        'selectedRowIndices': selectedRowIndices,
        'correctRowIndices': correctRowIndices,
        'strikePrice': strikePrice,
        'expiryDate': expiryDate?.toIso8601String(),
        'settings': settings != null ? settings!.toJson() : {},
        'isEditorMode': isEditorMode
      };
}
