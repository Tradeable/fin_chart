import 'package:flutter/material.dart';

class TableEditorWidget extends StatefulWidget {
  final List<String>? initialTableTitles;
  final List<String>? initialTableDescriptions;
  final List<List<String>>? initialColumnsList;
  final List<List<List<String>>>? initialRowsList;
  final void Function(List<String> tableTitles, List<String> tableDescriptions, List<List<String>> columnsList, List<List<List<String>>> rowsList, int selectedTableIndex) onChanged;
  final int? initialSelectedTableIndex;

  const TableEditorWidget({
    super.key,
    this.initialTableTitles,
    this.initialTableDescriptions,
    this.initialColumnsList,
    this.initialRowsList,
    required this.onChanged,
    this.initialSelectedTableIndex,
  });

  @override
  State<TableEditorWidget> createState() => _TableEditorWidgetState();
}

class _TableEditorWidgetState extends State<TableEditorWidget> {
  late List<TextEditingController> tableTitleControllers;
  late List<TextEditingController> tableDescriptionControllers;
  late List<List<TextEditingController>> columnControllersList;
  late List<List<List<TextEditingController>>> cellControllersList;
  late List<List<String>> columnsList;
  late List<List<List<String>>> rowsList;
  late int selectedTableIndex;

  @override
  void initState() {
    super.initState();
    final n = widget.initialTableTitles?.length ?? 1;
    tableTitleControllers = List.generate(n, (i) => TextEditingController(text: widget.initialTableTitles != null && i < widget.initialTableTitles!.length ? widget.initialTableTitles![i] : ''));
    tableDescriptionControllers = List.generate(n, (i) => TextEditingController(text: widget.initialTableDescriptions != null && i < widget.initialTableDescriptions!.length ? widget.initialTableDescriptions![i] : ''));
    columnsList = widget.initialColumnsList != null && widget.initialColumnsList!.isNotEmpty ? List.generate(n, (i) => List<String>.from(widget.initialColumnsList![i])) : List.generate(n, (_) => <String>[]);
    rowsList = widget.initialRowsList != null && widget.initialRowsList!.isNotEmpty ? List.generate(n, (i) => widget.initialRowsList![i].map((row) => List<String>.from(row)).toList()) : List.generate(n, (_) => <List<String>>[]);
    columnControllersList = List.generate(n, (i) => List.generate(columnsList[i].length, (j) => TextEditingController(text: columnsList[i][j])));
    cellControllersList = List.generate(n, (i) => List.generate(rowsList[i].length, (rowIdx) => List.generate(columnsList[i].length, (colIdx) => TextEditingController(text: rowsList[i][rowIdx][colIdx]))));
    selectedTableIndex = widget.initialSelectedTableIndex ?? 0;
  }

  void addTable() {
    setState(() {
      tableTitleControllers.add(TextEditingController(text: ''));
      tableDescriptionControllers.add(TextEditingController(text: ''));
      columnsList.add([]);
      rowsList.add([]);
      columnControllersList.add([]);
      cellControllersList.add([]);
      selectedTableIndex = tableTitleControllers.length - 1;
      _notifyChange();
    });
  }

  void removeTable(int idx) {
    setState(() {
      tableTitleControllers.removeAt(idx);
      tableDescriptionControllers.removeAt(idx);
      columnsList.removeAt(idx);
      rowsList.removeAt(idx);
      columnControllersList.removeAt(idx);
      cellControllersList.removeAt(idx);
      if (selectedTableIndex >= tableTitleControllers.length) {
        selectedTableIndex = tableTitleControllers.length - 1;
      }
      _notifyChange();
    });
  }

  void addColumn() {
    setState(() {
      columnsList[selectedTableIndex].add('');
      columnControllersList[selectedTableIndex].add(TextEditingController(text: ''));
      for (int i = 0; i < rowsList[selectedTableIndex].length; i++) {
        rowsList[selectedTableIndex][i].add('');
        cellControllersList[selectedTableIndex][i].add(TextEditingController(text: ''));
      }
      _notifyChange();
    });
  }

  void removeColumn(int colIdx) {
    setState(() {
      columnsList[selectedTableIndex].removeAt(colIdx);
      columnControllersList[selectedTableIndex].removeAt(colIdx);
      for (int i = 0; i < rowsList[selectedTableIndex].length; i++) {
        rowsList[selectedTableIndex][i].removeAt(colIdx);
        cellControllersList[selectedTableIndex][i].removeAt(colIdx);
      }
      _notifyChange();
    });
  }

  void addRow() {
    setState(() {
      rowsList[selectedTableIndex].add(List.generate(columnsList[selectedTableIndex].length, (_) => ''));
      cellControllersList[selectedTableIndex].add(List.generate(columnsList[selectedTableIndex].length, (_) => TextEditingController(text: '')));
      _notifyChange();
    });
  }

  void removeRow(int rowIdx) {
    setState(() {
      rowsList[selectedTableIndex].removeAt(rowIdx);
      cellControllersList[selectedTableIndex].removeAt(rowIdx);
      _notifyChange();
    });
  }

  void _notifyChange() {
    widget.onChanged(
      tableTitleControllers.map((c) => c.text).toList(),
      tableDescriptionControllers.map((c) => c.text).toList(),
      List<List<String>>.generate(columnsList.length, (i) => columnControllersList[i].map((c) => c.text).toList()),
      List<List<List<String>>>.generate(rowsList.length, (i) => cellControllersList[i].map((rowCtrls) => rowCtrls.map((c) => c.text).toList()).toList()),
      selectedTableIndex,
    );
  }

  Color? _getRowColor(int rowIdx) {
    if (rowsList[selectedTableIndex].length < 6) {
      return Colors.white;
    } else {
      return rowIdx % 2 == 0 ? Colors.white : Colors.blueGrey[50];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tableTitleControllers.length > 1)
          Row(
            children: [
              const Text('Tables:'),
              const SizedBox(width: 8),
              ...List.generate(tableTitleControllers.length, (idx) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FilterChip(
                      label: Text('Table ${idx + 1}'),
                      selected: selectedTableIndex == idx,
                      onSelected: (_) {
                        setState(() {
                          selectedTableIndex = idx;
                        });
                      },
                      deleteIcon: tableTitleControllers.length > 1 ? const Icon(Icons.close, size: 16) : null,
                      onDeleted: tableTitleControllers.length > 1
                          ? () {
                              removeTable(idx);
                            }
                          : null,
                    ),
                  )),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Table'),
                onPressed: addTable,
              ),
            ],
          ),
        if (tableTitleControllers.length == 1)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Table'),
              onPressed: addTable,
            ),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: tableTitleControllers[selectedTableIndex],
          decoration: InputDecoration(
            labelText: 'Table Title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: tableDescriptionControllers[selectedTableIndex],
          decoration: InputDecoration(
            labelText: 'Table Description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Column'),
              onPressed: addColumn,
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Row'),
              onPressed: addRow,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columns: [
                ...List.generate(columnsList[selectedTableIndex].length, (colIdx) {
                  return DataColumn(
                    label: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: columnControllersList[selectedTableIndex][colIdx],
                            decoration: InputDecoration(
                              labelText: 'Column ${colIdx + 1}',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              setState(() {
                                columnsList[selectedTableIndex][colIdx] = val;
                                _notifyChange();
                              });
                            },
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(32, 32),
                              padding: EdgeInsets.zero),
                          onPressed: () => removeColumn(colIdx),
                          child: const Icon(Icons.remove_circle_outline,
                              size: 18, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  );
                }),
                const DataColumn(label: SizedBox(width: 32)),
              ],
              rows: List.generate(rowsList[selectedTableIndex].length, (rowIdx) {
                return DataRow(
                  color: WidgetStateProperty.all(_getRowColor(rowIdx)),
                  cells: [
                    ...List.generate(columnsList[selectedTableIndex].length, (colIdx) {
                      return DataCell(
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: cellControllersList[selectedTableIndex][rowIdx][colIdx],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                            ),
                            onChanged: (val) {
                              setState(() {
                                rowsList[selectedTableIndex][rowIdx][colIdx] = val;
                                _notifyChange();
                              });
                            },
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero),
                        onPressed: () => removeRow(rowIdx),
                        child: const Icon(Icons.remove_circle_outline,
                            size: 18, color: Colors.redAccent),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
