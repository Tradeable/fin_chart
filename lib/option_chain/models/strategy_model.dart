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

  OptionLeg({
    required this.symbol,
    required this.strike,
    required this.type,
    required this.optionType,
    required this.expiry,
    required this.quantity,
    required this.premium,
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
      'premium': premium
    };
  }
}
