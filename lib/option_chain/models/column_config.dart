enum ColumnType {
  strike('Strike Price'),
  callOi('Call OI'),
  callPremium('Call Premium'),
  putOi('Put OI'),
  putPremium('Put Premium'),
  delta('Delta'),
  gamma('Gamma'),
  vega('Vega'),
  theta('Theta'),
  iv('IV');

  final String displayName;

  const ColumnType(this.displayName);

  @override
  String toString() => displayName;
}

class ColumnConfig {
  ColumnType type;
  String name;
  bool visible;

  ColumnConfig({
    required this.type,
    required this.name,
    required this.visible,
  });

  factory ColumnConfig.fromJson(Map<String, dynamic> json) => ColumnConfig(
        type: ColumnType.values[json['type'] as int],
        name: json['name'] as String,
        visible: json['visible'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'name': name,
        'visible': visible,
      };
}
