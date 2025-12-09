import 'package:fin_chart/models/enums/candle_state.dart';

class ICandle {
  late String id;
  late DateTime date;
  late double open;
  late double high;
  late double low;
  late double close;
  late double volume;
  late String? promptText; // Additional text to display to the user
  late CandleState state;

  ICandle({
    required this.id,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.promptText,
    this.state = CandleState.natural,
  });

  ICandle.fromJson(Map<String, dynamic> candle) {
    id = candle['id'];
    date = DateTime.parse(candle['date']);
    open = candle['open'].toDouble();
    high = candle['high'].toDouble();
    low = candle['low'].toDouble();
    close = candle['close'].toDouble();
    volume = candle['volume'].toDouble();
    promptText = candle['promptText'];
    state = (candle['state'] as String).toCandleState();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'promptText': promptText,
      'state': state.name,
    };
  }
}
