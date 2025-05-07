import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class DataTransformer {
  static String getColumnValuesAsString(
      List<OptionData> optionData, ColumnConfig column) {
    return optionData.map((data) {
      switch (column.type) {
        case ColumnType.strike:
          return data.strike.toString();
        case ColumnType.callOi:
          return data.callOi.toString();
        case ColumnType.callPremium:
          return data.callPremium.toString();
        case ColumnType.putOi:
          return data.putOi.toString();
        case ColumnType.putPremium:
          return data.putPremium.toString();
        case ColumnType.delta:
          return data.delta.toString();
        case ColumnType.gamma:
          return data.gamma.toString();
        case ColumnType.vega:
          return data.vega.toString();
        case ColumnType.theta:
          return data.theta.toString();
        case ColumnType.iv:
          return data.iv.toString();
      }
    }).join(' ');
  }

  static String getCellText(OptionData data, ColumnType columnType) {
    switch (columnType) {
      case ColumnType.strike:
        return data.strike.toStringAsFixed(2);
      case ColumnType.callOi:
        return data.callOi.toString();
      case ColumnType.callPremium:
        return data.callPremium.toStringAsFixed(2);
      case ColumnType.putOi:
        return data.putOi.toString();
      case ColumnType.putPremium:
        return data.putPremium.toStringAsFixed(2);
      case ColumnType.delta:
        return data.delta.toStringAsFixed(2);
      case ColumnType.gamma:
        return data.gamma.toStringAsFixed(2);
      case ColumnType.vega:
        return data.vega.toStringAsFixed(2);
      case ColumnType.theta:
        return data.theta.toStringAsFixed(2);
      case ColumnType.iv:
        return data.iv.toStringAsFixed(2);
    }
  }

  static List<ColumnType> getAvailableColumnTypes(
      List<ColumnConfig> existingColumns) {
    return ColumnType.values
        .where(
          (type) =>
              !existingColumns.any((col) => col.type == type) &&
              type != ColumnType.strike,
        )
        .toList();
  }

  static bool isCallColumn(String columnName) =>
      columnName.toLowerCase().contains('call');

  static bool isPutColumn(String columnName) =>
      columnName.toLowerCase().contains('put');
}
