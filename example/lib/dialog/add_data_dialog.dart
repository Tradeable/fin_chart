import 'package:fin_chart/fin_chart.dart';
import 'package:fin_chart/models/enums/candle_state.dart';
import 'package:flutter/material.dart';

class AddDataDialog extends StatelessWidget {
  final Function(List<ICandle>) onDataUpdate;
  final List<ICandle>? initialData;

  const AddDataDialog(
      {super.key, required this.onDataUpdate, this.initialData});

  @override
  Widget build(BuildContext context) {
    List<ICandle> iCandleData = [];
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(initialData != null ? "Replace Data" : "Add Data"),
            CandleStickGenerator(
                initialData: initialData,
                onCandleDataGenerated: (data) {
                  iCandleData.clear();
                  iCandleData.addAll(data);
                }),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDataUpdate(iCandleData.map((candle) {
                      candle.state = CandleState.natural;
                      return candle;
                    }).toList());
                  },
                  child: const Text("Submit")),
            )
          ],
        ),
      ),
    );
  }
}
