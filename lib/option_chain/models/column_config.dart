enum SelectionMode { entireRow, callOnly, putOnly }

enum ColumnType {
  strike('Strike Price'),
  callOi('OI'),
  callPremium('LTP'),
  putOi('OI'),
  putPremium('LTP'),
  callDelta('Delta'),
  callGamma('Gamma'),
  callVega('Vega'),
  callTheta('Theta'),
  callIV('IV'),
  putDelta('Delta'),
  putGamma('Gamma'),
  putTheta('Theta'),
  putVega('Vega'),
  putIV('IV'),
  callVolume('Volume'),
  putVolume('Volume');

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
            json['selectionMode'] as int? ?? SelectionMode.entireRow.index],
      );

  Map<String, dynamic> toJson() => {
        'columnType': columnType.index,
        'columnTitle': columnTitle,
        'isColumnVisible': isColumnVisible,
        'selectionMode': selectionMode.index,
      };
}
