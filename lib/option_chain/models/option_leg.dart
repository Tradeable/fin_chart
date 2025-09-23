// Enum for option types
enum OptionType { call, put }

// Enum for position types
enum PositionType { buy, sell }

class OptionLeg {
  final String symbol;
  final double strike;
  final PositionType type;
  final OptionType optionType;
  final DateTime expiry;
  final int quantity;
  final double premium;
  final int? rowIndex;
  final int? side;

  OptionLeg({
    required this.symbol,
    required this.strike,
    required this.type,
    required this.optionType,
    required this.expiry,
    required this.quantity,
    required this.premium,
    this.rowIndex,
    this.side,
  });

  static PositionType parsePositionType(String type) {
    return type.toLowerCase() == 'buy' ? PositionType.buy : PositionType.sell;
  }

  static OptionType parseOptionType(String type) {
    return type.toLowerCase() == 'call' ? OptionType.call : OptionType.put;
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'strike': strike,
      'type': type.name,
      'optionType': optionType.name,
      'expiry': expiry.toIso8601String(),
      'quantity': quantity,
      'premium': premium,
      'rowIndex': rowIndex,
      'side': side,
    };
  }

  factory OptionLeg.fromJson(Map<String, dynamic> json) {
    return OptionLeg(
      symbol: json['symbol'],
      strike: json['strike'].toDouble(),
      type: parsePositionType(json['type']),
      optionType: parseOptionType(json['optionType']),
      expiry: DateTime.parse(json['expiry']),
      quantity: json['quantity'],
      premium: json['premium'].toDouble(),
      rowIndex: json['rowIndex'],
      side: json['side'],
    );
  }

  Map<int, int> toLegacyFormat() {
    return {rowIndex ?? 0: side ?? 0};
  }

  factory OptionLeg.fromLegacyFormat(Map<int, int> legacy, {bool isBuy = true, String symbol = '', DateTime? expiry, double strike = 0.0, double premium = 0.0}) {
    return OptionLeg(
      symbol: symbol,
      strike: strike,
      type: isBuy ? PositionType.buy : PositionType.sell,
      optionType: legacy.values.first == 0 ? OptionType.call : OptionType.put,
      expiry: expiry ?? DateTime.now(),
      quantity: 1,
      premium: premium,
      rowIndex: legacy.keys.first,
      side: legacy.values.first,
    );
  }
}
