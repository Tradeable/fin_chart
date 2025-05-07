import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';

class OptionChainUtils {
  static List<ColumnConfig> getDefaultColumns(
    OptionChainVisibility visibility, {
    List<ColumnConfig> customColumns = const [],
  }) {
    List<ColumnConfig> leftColumns = [];
    List<ColumnConfig> rightColumns = [];
    List<ColumnConfig> greekColumns = [];

    void addGreek(ColumnType type) {
      if (customColumns.any((c) => c.type == type)) {
        greekColumns.add(customColumns.firstWhere((c) => c.type == type));
      }
    }

    if (visibility == OptionChainVisibility.both) {
      leftColumns = [
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
      ];
      rightColumns = [
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
      ];
    } else if (visibility == OptionChainVisibility.call) {
      leftColumns = [
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
      ];
    } else {
      leftColumns = [
        ColumnConfig(
          type: ColumnType.putOi,
          name: ColumnType.putOi.displayName,
          visible: true,
        ),
        ColumnConfig(
          type: ColumnType.putPremium,
          name: ColumnType.putPremium.displayName,
          visible: true,
        ),
      ];
    }

    for (var greek in [ColumnType.delta, ColumnType.gamma, ColumnType.vega]) {
      addGreek(greek);
    }

    return [
      ...leftColumns,
      ColumnConfig(
        type: ColumnType.strike,
        name: ColumnType.strike.displayName,
        visible: true,
      ),
      ...rightColumns,
      ...greekColumns,
      ...customColumns.where(
        (c) =>
            c.type != ColumnType.delta &&
            c.type != ColumnType.gamma &&
            c.type != ColumnType.vega,
      ),
    ];
  }

  static List<OptionData> generateOptionData({
    required double minStrike,
    required double maxStrike,
    required int interval,
  }) {
    List<OptionData> newData = [];
    double currentStrike = minStrike;
    while (currentStrike <= maxStrike) {
      int i = newData.length;
      newData.add(
        OptionData(
          strike: currentStrike,
          callOi: 1000 + i * 500,
          callPremium: 5.0 + i * 0.5,
          putOi: 800 + i * 400,
          putPremium: 4.0 + i * 0.4,
          delta: 0.5 + (i * 0.05),
          gamma: 0.1 + (i * 0.01),
          vega: 0.3 + (i * 0.03),
        ),
      );
      currentStrike += interval.toDouble();
    }
    return newData;
  }
}
