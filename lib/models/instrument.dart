import 'package:fin_chart/models/i_candle.dart';

class Instrument {
  String? name;
  List<ICandle> data = [];

  Instrument();

  addData(List<ICandle> newData) {
    //add try catch if there is overlap or gap
    data.addAll(newData);
  }

  updateData(List<ICandle> updatedData) {
    data.clear();
    data.addAll(updatedData);
  }
}
