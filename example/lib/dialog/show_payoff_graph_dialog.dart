import 'package:fin_chart/fin_chart.dart';
import 'package:flutter/material.dart';

Future<ShowPayOffGraphTask?> showPayOffGraphDialog({
  required BuildContext context,
}) async {
  final quantityController = TextEditingController();
  final spotPriceController = TextEditingController();
  final spotPriceDayDeltaController = TextEditingController();
  final spotPriceDayDeltaPerController = TextEditingController();

  return showDialog<ShowPayOffGraphTask>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Payoff Graph Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: spotPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Spot Price'),
                ),
                TextField(
                  controller: spotPriceDayDeltaController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Spot Price Day Delta'),
                ),
                TextField(
                  controller: spotPriceDayDeltaPerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Spot Price Day Delta %'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (quantityController.text.trim().isEmpty ||
                            spotPriceController.text.trim().isEmpty ||
                            spotPriceDayDeltaController.text.trim().isEmpty ||
                            spotPriceDayDeltaPerController.text.trim().isEmpty)
                          return;

                        final task = ShowPayOffGraphTask(
                          quantity: int.tryParse(quantityController.text) ?? 0,
                          spotPrice:
                              double.tryParse(spotPriceController.text) ?? 0,
                          spotPriceDayDelta: double.tryParse(
                                  spotPriceDayDeltaController.text) ??
                              0,
                          spotPriceDayDeltaPer: double.tryParse(
                                  spotPriceDayDeltaPerController.text) ??
                              0,
                        );

                        Navigator.of(context).pop(task);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
