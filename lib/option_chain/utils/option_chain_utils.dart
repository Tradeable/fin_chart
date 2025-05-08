import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class OptionChainUtils {
  static List<ColumnConfig> getDefaultColumns(
    OptionChainVisibility visibility, {
    List<ColumnConfig> customColumns = const [],
  }) {
    final callColumns = <ColumnConfig>[];
    final putColumns = <ColumnConfig>[];

    void addColumnIfExists(List<ColumnConfig> target, ColumnType type) {
      final column = customColumns.firstWhereOrNull((c) => c.type == type);
      if (column != null) {
        target.add(column);
      }
    }

    void addCallColumns() {
      callColumns.addAll([
        ColumnConfig(
          type: ColumnType.callOi,
          name: ColumnType.callOi.displayName,
          visible: true,
        ),
        ColumnConfig(
          type: ColumnType.callPremium,
          name: ColumnType.callPremium.displayName,
          visible: true,
        ),
      ]);

      for (final type in [
        ColumnType.callDelta,
        ColumnType.callGamma,
        ColumnType.callVega,
        ColumnType.callTheta,
        ColumnType.callIV,
      ]) {
        addColumnIfExists(callColumns, type);
      }
    }

    void addPutColumns() {
      putColumns.addAll([
        ColumnConfig(
          type: ColumnType.putPremium,
          name: ColumnType.putPremium.displayName,
          visible: true,
        ),
        ColumnConfig(
          type: ColumnType.putOi,
          name: ColumnType.putOi.displayName,
          visible: true,
        ),
      ]);

      for (final type in [
        ColumnType.putDelta,
        ColumnType.putGamma,
        ColumnType.putVega,
        ColumnType.putTheta,
        ColumnType.putIV,
      ]) {
        addColumnIfExists(putColumns, type);
      }
    }

    switch (visibility) {
      case OptionChainVisibility.both:
        addCallColumns();
        addPutColumns();
        break;
      case OptionChainVisibility.call:
        addCallColumns();
        break;
      case OptionChainVisibility.put:
        addPutColumns();
        break;
    }

    final strikeColumn = ColumnConfig(
      type: ColumnType.strike,
      name: ColumnType.strike.displayName,
      visible: true,
    );

    return [
      ...callColumns,
      strikeColumn,
      ...putColumns,
    ];
  }

  static List<OptionData> generateOptionData({
    required double minStrike,
    required double maxStrike,
    required int interval,
  }) {
    final newData = <OptionData>[];
    final strikeCount = ((maxStrike - minStrike) / interval).ceil() + 1;

    for (var i = 0; i < strikeCount; i++) {
      final currentStrike = minStrike + (i * interval);
      newData.add(
        OptionData(
          strike: currentStrike,
          callOi: 1000 + i * 500,
          callPremium: 5.0 + i * 0.5,
          putOi: 800 + i * 400,
          putPremium: 4.0 + i * 0.4,
          callDelta: 0.5 + (i * 0.05),
          callGamma: 0.1 + (i * 0.01),
          callVega: 0.3 + (i * 0.03),
          callTheta: -0.2 - (i * 0.02),
          callIV: 20.0 + (i * 0.5),
          putDelta: -0.5 - (i * 0.05),
          putGamma: 0.1 + (i * 0.01),
          putVega: 0.3 + (i * 0.03),
          putTheta: -0.2 - (i * 0.02),
          putIV: 20.0 + (i * 0.5),
        ),
      );
    }

    return newData;
  }
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
