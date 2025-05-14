import 'package:fin_chart/option_chain/models/column_config.dart';

class OptionChainSettings {
  SelectionMode selectionMode;
  int? maxSelectableRows;
  bool? isMultiRowSelectable;
  bool? isBuySellVisible;

  OptionChainSettings(
      {this.selectionMode = SelectionMode.entireRow,
      this.maxSelectableRows,
      this.isMultiRowSelectable = false,
      this.isBuySellVisible = false});

  factory OptionChainSettings.fromJson(Map<String, dynamic> json) {
    return OptionChainSettings(
        selectionMode: SelectionMode.values.firstWhere(
            (v) => v.name == json['selectionMode'],
            orElse: () => SelectionMode.entireRow),
        maxSelectableRows: json['maxSelectableRows'],
        isMultiRowSelectable: json['isMultiRowSelectable'],
        isBuySellVisible: json['isBuySellVisible']);
  }

  Map<String, dynamic> toJson() {
    return {
      'selectionMode': selectionMode.name,
      'maxSelectableRows': maxSelectableRows,
      'isMultiRowSelectable': isMultiRowSelectable,
      'isBuySellVisible': isBuySellVisible
    };
  }
}
