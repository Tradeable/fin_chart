import 'package:fin_chart/models/enums/candle_state.dart';
import 'dart:math' as math;

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
    open = candle['open'];
    high = candle['high'];
    low = candle['low'];
    close = candle['close'];
    volume = candle['volume'];
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

  ICandle mergeWith(ICandle other) {
    // Keep the original ID and date
    return ICandle(
      id: id,
      date: date,
      // For OHLC:
      // - Keep the original open
      // - Take the highest high
      // - Take the lowest low
      // - Use the latest close
      open: open,
      high: math.max(high, other.high),
      low: math.min(low, other.low),
      close: other.close,
      // Add up the volume
      volume: volume + other.volume,
      promptText: promptText,
      state: state,
    );
  }
}
