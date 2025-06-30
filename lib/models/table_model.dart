class TableModel {
  String tableTitle;
  String tableDescription;
  List<String> columns;
  List<List<String>> rows;

  TableModel({
    required this.tableTitle,
    required this.tableDescription,
    required this.columns,
    required this.rows,
  });

  Map<String, dynamic> toJson() => {
        'tableTitle': tableTitle,
        'tableDescription': tableDescription,
        'columns': columns,
        'rows': rows,
      };

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
        tableTitle: json['tableTitle'] ?? '',
        tableDescription: json['tableDescription'] ?? '',
        columns: List<String>.from(json['columns'] ?? []),
        rows: (json['rows'] as List<dynamic>? ?? [])
            .map((row) => List<String>.from(row))
            .toList(),
      );
}

class TablesModel {
  List<TableModel> tables;
  TablesModel({required this.tables});

  Map<String, dynamic> toJson() => {
        'tables': tables.map((t) => t.toJson()).toList(),
      };

  factory TablesModel.fromJson(Map<String, dynamic> json) => TablesModel(
        tables: (json['tables'] as List<dynamic>? ?? [])
            .map((t) => TableModel.fromJson(t))
            .toList(),
      );
} 