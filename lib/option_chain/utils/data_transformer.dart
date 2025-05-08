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
        case ColumnType.callDelta:
          return data.callDelta.toString();
        case ColumnType.callGamma:
          return data.callGamma.toString();
        case ColumnType.callVega:
          return data.callVega.toString();
        case ColumnType.callTheta:
          return data.callTheta.toString();
        case ColumnType.callIV:
          return data.callIV.toString();
        case ColumnType.putDelta:
          return data.putDelta.toString();
        case ColumnType.putGamma:
          return data.putGamma.toString();
        case ColumnType.putVega:
          return data.putVega.toString();
        case ColumnType.putTheta:
          return data.putTheta.toString();
        case ColumnType.putIV:
          return data.putIV.toString();
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
      case ColumnType.callDelta:
        return data.callDelta.toStringAsFixed(2);
      case ColumnType.callGamma:
        return data.callGamma.toStringAsFixed(2);
      case ColumnType.callVega:
        return data.callVega.toStringAsFixed(2);
      case ColumnType.callTheta:
        return data.callTheta.toStringAsFixed(2);
      case ColumnType.callIV:
        return data.callIV.toStringAsFixed(2);
      case ColumnType.putDelta:
        return data.putDelta.toStringAsFixed(2);
      case ColumnType.putGamma:
        return data.putGamma.toStringAsFixed(2);
      case ColumnType.putVega:
        return data.putVega.toStringAsFixed(2);
      case ColumnType.putTheta:
        return data.putTheta.toStringAsFixed(2);
      case ColumnType.putIV:
        return data.putIV.toStringAsFixed(2);
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
