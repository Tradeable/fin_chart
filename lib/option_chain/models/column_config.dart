enum SelectionMode { entireRow, callOnly, putOnly }

enum ColumnType {
  strike('Strike Price'),
  callOi('Call OI'),
  callPremium('Call Premium'),
  putOi('Put OI'),
  putPremium('Put Premium'),
  callDelta('Call Delta'),
  callGamma('Call Gamma'),
  callVega('Call Vega'),
  callTheta('Call Theta'),
  callIV('Call IV'),
  putDelta('Put Delta'),
  putGamma('Put Gamma'),
  putTheta('Put Theta'),
  putVega('Put Vega'),
  putIV('Put IV'),
  callVolume('Call Volume'),
  putVolume('Put Volume');

  final String displayName;

  const ColumnType(this.displayName);

  @override
  String toString() => displayName;
}

class ColumnConfig {
  ColumnType columnType;
  String columnTitle;
  bool isColumnVisible;
  SelectionMode selectionMode;

  ColumnConfig({
    required this.columnType,
    required this.columnTitle,
    this.isColumnVisible = true,
    this.selectionMode = SelectionMode.entireRow,
  });

  factory ColumnConfig.fromJson(Map<String, dynamic> json) => ColumnConfig(
        columnType: ColumnType.values[json['columnType'] as int],
        columnTitle: json['columnTitle'] as String,
        isColumnVisible: json['isColumnVisible'] as bool,
        selectionMode: SelectionMode.values[
            json['selectionMode'] as int? ?? SelectionMode.entireRow as int],
      );

  Map<String, dynamic> toJson() => {
        'columnType': columnType.index,
        'columnTitle': columnTitle,
        'isColumnVisible': isColumnVisible,
        'selectionMode': selectionMode.index,
      };
}
