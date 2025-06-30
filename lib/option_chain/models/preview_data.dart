import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_chain_settings.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/option_leg.dart';

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
  List<OptionLeg>? bucketRows;

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

  List<Map<int, int>>? getLegacyBucketRows() {
    return bucketRows?.map((e) => e.toLegacyFormat()).toList();
  }

  void setLegacyBucketRows(List<Map<int, int>>? legacyRows) {
    if (legacyRows != null) {
      final symbol = optionData.isNotEmpty ? 
          (strikePrice != null ? '${strikePrice}_${expiryDate?.millisecondsSinceEpoch}' : '') : '';
      final expiry = expiryDate ?? DateTime.now();
      
      bucketRows = legacyRows.map((e) {
        final rowIndex = e.keys.first;
        final side = e.values.first;
        final strike = rowIndex < optionData.length ? optionData[rowIndex].strike : 0.0;
        final premium = side == 0 && rowIndex < optionData.length ? 
            optionData[rowIndex].callPremium : 
            (side == 1 && rowIndex < optionData.length ? optionData[rowIndex].putPremium : 0.0);
        
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

  factory PreviewData.fromJson(Map<String, dynamic> json) {
    List<OptionLeg>? bucketRows;
    
    if (json['bucketRows'] != null) {
      if (json['bucketRows'] is List && json['bucketRows'].isNotEmpty) {
        if (json['bucketRows'][0] is Map && json['bucketRows'][0].containsKey('rowIndex')) {
          bucketRows = List<OptionLeg>.from(
              json['bucketRows'].map((e) => OptionLeg.fromJson(e)));
        } else {
          final legacyRows = List<Map<int, int>>.from(json['bucketRows'].map((map) =>
              Map<int, int>.from(map.map((k, v) => MapEntry(int.parse(k), v)))));
          
          final optionData = (json['optionData'] as List)
              .map((e) => OptionData.fromJson(e))
              .toList();
          final strikePrice = (json['strikePrice'] as num?)?.toDouble();
          final expiryDate = json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null;
          
          final symbol = optionData.isNotEmpty ? 
              (strikePrice != null ? '${strikePrice}_${expiryDate?.millisecondsSinceEpoch}' : '') : '';
          final expiry = expiryDate ?? DateTime.now();
          
          bucketRows = legacyRows.map((e) {
            final rowIndex = e.keys.first;
            final side = e.values.first;
            final strike = rowIndex < optionData.length ? optionData[rowIndex].strike : 0.0;
            final premium = side == 0 && rowIndex < optionData.length ? 
                optionData[rowIndex].callPremium : 
                (side == 1 && rowIndex < optionData.length ? optionData[rowIndex].putPremium : 0.0);
            
            return OptionLeg.fromLegacyFormat(
              e, 
              symbol: symbol, 
              expiry: expiry, 
              strike: strike, 
              premium: premium
            );
          }).toList();
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
