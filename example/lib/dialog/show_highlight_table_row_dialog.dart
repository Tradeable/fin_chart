import 'package:flutter/material.dart';
import 'package:fin_chart/models/table_model.dart';
import 'package:example/editor/ui/widget/table_display_widget.dart';

class TableRowSelection {
  final Map<int, Set<int>> selectedRows = {};

  bool get hasSelection => selectedRows.values.any((set) => set.isNotEmpty);

  void toggle(int tableIdx, int rowIdx) {
    final set = selectedRows.putIfAbsent(tableIdx, () => <int>{});
    if (set.contains(rowIdx)) {
      set.remove(rowIdx);
    } else {
      set.add(rowIdx);
    }
  }

  void clear() {
    selectedRows.clear();
  }
}

Future<Map<int, Set<int>>?> showHighlightTableRowDialog({
  required BuildContext context,
  required String tableTaskId,
  required List<TableModel> tables,
  Map<int, Set<int>>? initialSelection,
}) async {
  final selection = TableRowSelection();
  if (initialSelection != null) {
    selection.selectedRows.addAll(initialSelection);
  }

  return showDialog<Map<int, Set<int>>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Highlight Table Rows'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tap any row in any table to select/deselect. You can select multiple rows.'),
                    const SizedBox(height: 16),
                    ...tables.asMap().entries.map((entry) {
                      final tIdx = entry.key;
                      final table = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (table.tableTitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                table.tableTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          if (table.tableDescription.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                table.tableDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          TableDisplayWidget(
                            columns: table.columns,
                            rows: table.rows,
                            selectedRowIndices: selection.selectedRows[tIdx] ?? {},
                            onRowSelect: (rowIdx, selected) {
                              setState(() {
                                selection.toggle(tIdx, rowIdx);
                              });
                            },
                            key: ValueKey('table_preview_$tIdx'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: selection.hasSelection
                    ? () {
                        // Return a deep copy to avoid mutation bugs
                        final result = selection.selectedRows.map((k, v) => MapEntry(k, Set<int>.from(v)));
                        Navigator.of(context).pop(result);
                      }
                    : null,
                child: const Text('Highlight'),
              ),
            ],
          );
        },
      );
    },
  );
}
