import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class DataTransformer {
  static String getColumnValuesAsString(
      List<OptionData> optionData, ColumnConfig column) {
    return optionData.map((data) {
      switch (column.columnType) {
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
        case ColumnType.callVolume:
          return data.callVolume.toString();
        case ColumnType.putVolume:
          return data.putVolume.toString();
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
      case ColumnType.callVolume:
        return data.callVolume.toStringAsFixed(2);
      case ColumnType.putVolume:
        return data.putVolume.toStringAsFixed(2);
    }
  }

  static List<ColumnType> getAvailableColumnTypes(
      List<ColumnConfig> existingColumns, OptionChainVisibility visibility) {
    var allTypes =
        ColumnType.values.where((type) => type != ColumnType.strike).toList();
    var availableTypes = allTypes.where((type) {
      bool exists = existingColumns.any((col) {
        var colType = col.columnType;
        if (visibility == OptionChainVisibility.both) {
          return type == colType ||
              (isCallColumn(type.name) &&
                  isPutColumn(colType.name) &&
                  type.displayName == colType.displayName) ||
              (isPutColumn(type.name) &&
                  isCallColumn(colType.name) &&
                  type.displayName == colType.displayName);
        }
        return type == colType;
      });
      return !exists;
    }).toList();
    if (visibility == OptionChainVisibility.both) {
      var finalTypes = availableTypes.where((type) {
        bool hasOpposite = availableTypes.any((otherType) =>
            otherType != type &&
            ((isCallColumn(type.name) &&
                    isPutColumn(otherType.name) &&
                    type.displayName == otherType.displayName) ||
                (isPutColumn(type.name) &&
                    isCallColumn(otherType.name) &&
                    type.displayName == otherType.displayName)));

        if (hasOpposite) {
          return isCallColumn(type.name);
        }
        if (isCallColumn(type.name)) {
          return !existingColumns.any((col) =>
              isPutColumn(col.columnType.name) &&
              col.columnType.displayName == type.displayName);
        } else if (isPutColumn(type.name)) {
          return !existingColumns.any((col) =>
              isCallColumn(col.columnType.name) &&
              col.columnType.displayName == type.displayName);
        }

        return true;
      }).toList();
      return finalTypes;
    }

    var visibilityFilteredTypes = availableTypes.where((type) {
      bool matchesVisibility = true;
      if (visibility == OptionChainVisibility.call) {
        matchesVisibility = isCallColumn(type.name);
      } else if (visibility == OptionChainVisibility.put) {
        matchesVisibility = isPutColumn(type.name);
      }
      return matchesVisibility;
    }).toList();
    return visibilityFilteredTypes;
  }

  static bool isCallColumn(String columnName) =>
      columnName.toLowerCase().startsWith('call');

  static bool isPutColumn(String columnName) =>
      columnName.toLowerCase().startsWith('put');

  static ColumnType getOppositeColumnType(ColumnType type) {
    final typeName = type.name;
    if (isCallColumn(typeName)) {
      final putName = typeName.replaceFirst('call', 'put');
      return ColumnType.values.firstWhere(
        (t) => t.name == putName,
        orElse: () => type,
      );
    } else if (isPutColumn(typeName)) {
      final callName = typeName.replaceFirst('put', 'call');
      return ColumnType.values.firstWhere(
        (t) => t.name == callName,
        orElse: () => type,
      );
    }
    return type;
  }

  static bool isOppositeColumn(ColumnType type1, ColumnType type2) {
    return (isCallColumn(type1.name) && isPutColumn(type2.name)) ||
        (isPutColumn(type1.name) && isCallColumn(type2.name));
  }
}
