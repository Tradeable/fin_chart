import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

class ScannerSelectionDialog extends StatelessWidget {
  final Function(ScannerType) onScannerSelected;

  const ScannerSelectionDialog({
    super.key,
    required this.onScannerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a Scanner Pattern'),
      content: SizedBox(
        width: 350,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: ScannerType.values.length,
          itemBuilder: (context, index) {
            final scannerType = ScannerType.values.elementAt(index);
            final scanner = scannerType.instance;
            return ListTile(
              title: Text(scanner.name),
              onTap: () {
                onScannerSelected(scannerType);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
