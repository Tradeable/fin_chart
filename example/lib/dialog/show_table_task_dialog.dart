import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/table_task.dart';
import 'package:fin_chart/models/table_model.dart';
import 'package:example/editor/ui/widget/table_editor_widget.dart';

Future<TableTask?> showTableTaskDialog({
  required BuildContext context,
  TableTask? initialTask,
}) async {
  List<TableModel> tables = initialTask?.tables.tables ??
      [TableModel(tableTitle: '', tableDescription: '', columns: [], rows: [])];
  int selectedTableIndex = 0;

  List<String> tableTitles = tables.map((t) => t.tableTitle).toList();
  List<String> tableDescriptions =
      tables.map((t) => t.tableDescription).toList();
  List<List<String>> columnsList =
      tables.map((t) => List<String>.from(t.columns)).toList();
  List<List<List<String>>> rowsList = tables
      .map((t) => t.rows.map((r) => List<String>.from(r)).toList())
      .toList();

  return showDialog<TableTask>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
                initialTask != null ? 'Edit Table Task' : 'Add Table Task'),
            content: SingleChildScrollView(
              child: TableEditorWidget(
                key: ValueKey('table_task_editor'),
                initialTableTitles: tableTitles,
                initialTableDescriptions: tableDescriptions,
                initialColumnsList: columnsList,
                initialRowsList: rowsList,
                initialSelectedTableIndex: selectedTableIndex,
                onChanged: (titles, descriptions, colsList, rowsList_, selIdx) {
                  setState(() {
                    tableTitles = titles;
                    tableDescriptions = descriptions;
                    columnsList = colsList;
                    rowsList = rowsList_;
                    selectedTableIndex = selIdx;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final allTables = List<TableModel>.generate(
                      tableTitles.length,
                      (i) => TableModel(
                            tableTitle: tableTitles[i],
                            tableDescription: tableDescriptions[i],
                            columns: List<String>.from(columnsList[i]),
                            rows: rowsList[i]
                                .map((r) => List<String>.from(r))
                                .toList(),
                          ));
                  Navigator.of(context).pop(
                    TableTask(
                      tables: TablesModel(tables: allTables),
                      id: initialTask?.id,
                    ),
                  );
                },
                child: Text(initialTask != null ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
