import 'package:fin_chart/models/enums/scanner_type.dart';

class ScannerResult {
  final ScannerType scannerType;
  final String label;
  final int targetIndex;
  final List<int> highlightedIndices;
  bool isSelected;

  ScannerResult({
    required this.scannerType,
    required this.label,
    required this.targetIndex,
    required this.highlightedIndices,
    this.isSelected = false,
  });
}
