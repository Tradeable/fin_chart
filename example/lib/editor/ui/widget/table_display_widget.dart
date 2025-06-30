import 'package:flutter/material.dart';

class TableDisplayWidget extends StatefulWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final Set<int>? selectedRowIndices;
  final void Function(int rowIdx)? onRowTap;
  final void Function(int rowIdx, bool selected)? onRowSelect;

  const TableDisplayWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.selectedRowIndices,
    this.onRowTap,
    this.onRowSelect,
  });

  @override
  TableDisplayWidgetState createState() => TableDisplayWidgetState();
}

class TableDisplayWidgetState extends State<TableDisplayWidget> {
  Set<int>? highlightSelectedRowIndices;

  void setSelectedRows(Set<int> rowIndices) {
    setState(() {
      highlightSelectedRowIndices = Set<int>.from(rowIndices);
    });
  }

  @override
  void didUpdateWidget(covariant TableDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRowIndices != oldWidget.selectedRowIndices) {
      highlightSelectedRowIndices = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRowIndices =
        highlightSelectedRowIndices ?? widget.selectedRowIndices ?? {};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        showCheckboxColumn: false,
        columns:
            widget.columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: List.generate(widget.rows.length, (rowIdx) {
          final row = widget.rows[rowIdx];
          final isStriped = widget.rows.length >= 6;
          final isSelected = selectedRowIndices.contains(rowIdx);
          final rowColor = isSelected
              ? Colors.lightBlue[100]
              : (isStriped
                  ? (rowIdx % 2 == 0 ? Colors.white : Colors.blueGrey[50])
                  : Colors.white);
          return DataRow(
            color: WidgetStateProperty.all(rowColor),
            cells: row.map((cell) => DataCell(Text(cell))).toList(),
            onSelectChanged: (selected) {
              if (widget.onRowSelect != null) {
                widget.onRowSelect!(rowIdx, !isSelected);
              } else if (widget.onRowTap != null) {
                if (selected == true) {
                  widget.onRowTap!(rowIdx);
                }
              }
            },
            selected: isSelected,
          );
        }),
      ),
    );
  }
}
