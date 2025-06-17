import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
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
  int? _maxSelectableRows;
  List<BucketRowSelection>? bucketRows;

  PreviewData({
    required this.optionData,
    required this.columns,
    required this.visibility,
    this.selectedRowIndices = const [],
    this.correctRowIndices = const [],
    this.strikePrice,
    this.expiryDate,
    this.settings,
    required this.isEditorMode,
    int? maxSelectableRows,
    this.bucketRows,
  }) : _maxSelectableRows = maxSelectableRows;

  int? get maxSelectableRows {
    if (_maxSelectableRows != null) {
      return _maxSelectableRows;
    }
    return settings?.maxSelectableRows;
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

  factory PreviewData.fromJson(Map<String, dynamic> json) {
    List<BucketRowSelection>? bucketRows;
    
    // Handle both new and legacy formats
    if (json['bucketRows'] != null) {
      if (json['bucketRows'] is List && json['bucketRows'].isNotEmpty) {
        // Check if it's the new format (has 'rowIndex' field)
        if (json['bucketRows'][0] is Map && json['bucketRows'][0].containsKey('rowIndex')) {
          bucketRows = List<BucketRowSelection>.from(
              json['bucketRows'].map((e) => BucketRowSelection.fromJson(e)));
        } else {
          // Legacy format
          final legacyRows = List<Map<int, int>>.from(json['bucketRows'].map((map) =>
              Map<int, int>.from(map.map((k, v) => MapEntry(int.parse(k), v)))));
          bucketRows = legacyRows.map((e) => BucketRowSelection.fromLegacyFormat(e)).toList();
        }
      }
    }

    return PreviewData(
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
      isEditorMode: json['isEditorMode'],
      maxSelectableRows: json['maxSelectableRows'],
      bucketRows: bucketRows,
    );
  }

  Map<String, dynamic> toJson() => {
        'optionData': optionData.map((e) => e.toJson()).toList(),
        'columns': columns.map((e) => e.toJson()).toList(),
        'visibility': visibility.index,
        'selectedRowIndices': selectedRowIndices,
        'correctRowIndices': correctRowIndices,
        'strikePrice': strikePrice,
        'expiryDate': expiryDate?.toIso8601String(),
        'settings': settings != null ? settings!.toJson() : {},
        'isEditorMode': isEditorMode,
        'maxSelectableRows': _maxSelectableRows,
        'bucketRows': bucketRows?.map((e) => e.toJson()).toList(),
      };
}
