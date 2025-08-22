import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/scanners/scanner_result.dart';
import 'package:flutter/material.dart';

Future<void> showScannersDialog({
  required BuildContext context,
  required Set<ScannerType> visibleScannerTypes,
  required Map<ScannerType, List<ScannerResult>> generatedScanners,
  required Function(ScannerType) onToggle,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      // Use a StatefulBuilder to allow the dialog's content to update
      // without rebuilding the entire page.
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            title: const Text('Manage Scanners'),
            content: SizedBox(
              width: 350, // Give the dialog a consistent width
              child: ListView.builder(
                shrinkWrap: true,
                // Build the list directly from all possible ScannerType values
                itemCount: ScannerType.values.length,
                itemBuilder: (context, index) {
                  final scannerType = ScannerType.values.elementAt(index);
                  // Get the scanner instance to access its properties (like its name)
                  final scanner = scannerType.instance;
                  final bool isVisible =
                      visibleScannerTypes.contains(scannerType);
                  final bool hasBeenRun =
                      generatedScanners.containsKey(scannerType);
                  final int foundCount =
                      hasBeenRun ? generatedScanners[scannerType]!.length : 0;

                  return SwitchListTile(
                    title: Text(scanner.name),
                    subtitle: Text(
                        hasBeenRun ? "$foundCount found" : "Tap to run scan"),
                    value: isVisible,
                    onChanged: (bool value) {
                      // Call the toggle function passed from the EditorPage
                      onToggle(scannerType);

                      // This tells the dialog specifically to rebuild its own state
                      dialogSetState(() {});
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}
