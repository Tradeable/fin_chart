import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/utils/data_transformer.dart';
import 'package:flutter/material.dart';

class PreviewScreen extends StatefulWidget {
  final PreviewData previewData;

  const PreviewScreen({
    super.key,
    required this.previewData,
  });

  factory PreviewScreen.from({
    required GlobalKey key,
    required AddOptionChainTask task,
    int? selectedRowIndex,
    int? correctRowIndex,
  }) {
    return PreviewScreen(
      key: key,
      previewData: PreviewData(
        optionData: task.data,
        columns: task.columns.where((c) => c.visible).toList(),
        visibility: task.visibility,
        selectedRowIndex: selectedRowIndex,
        correctRowIndex: correctRowIndex,
      ),
    );
  }

  @override
  State<PreviewScreen> createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  int? _selectedRowIndex;
  bool _isChecked = false;
  int? userSelectedIndex;

  @override
  void initState() {
    print(widget.previewData.toJson());

    super.initState();
  }

  void chooseRow(int rowIndex) {
    setState(() {
      userSelectedIndex = rowIndex;
      _isChecked = true;
    });
  }

  int? getCorrectRowIndex() {
    return _selectedRowIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildOptionsTable()),
      ],
    );
  }

  Widget _buildOptionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 12,
          columns: _buildDataColumns(),
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return widget.previewData.columns
        .where((column) => column.visible)
        .map(
          (column) => DataColumn(
            label: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(column.name, overflow: TextOverflow.ellipsis),
            ),
          ),
        )
        .toList();
  }

  List<DataRow> _buildDataRows() {
    return widget.previewData.optionData
        .asMap()
        .entries
        .map(
          (entry) => DataRow(
            color: _getRowColor(entry.key),
            cells: _buildRowCells(entry.key, entry.value),
          ),
        )
        .toList();
  }

  WidgetStateProperty<Color>? _getRowColor(int rowIndex) {
    if (!_isChecked) {
      return rowIndex == _selectedRowIndex
          ? WidgetStateProperty.all(Colors.blue.withAlpha((0.1 * 255).round()))
          : null;
    }
    if (userSelectedIndex == _selectedRowIndex) {
      return rowIndex == userSelectedIndex
          ? WidgetStateProperty.all(Colors.green.withAlpha((0.1 * 255).round()))
          : null;
    } else {
      if (rowIndex == _selectedRowIndex) {
        return WidgetStateProperty.all(
            Colors.red.withAlpha((0.1 * 255).round()));
      } else if (rowIndex == userSelectedIndex) {
        return WidgetStateProperty.all(
            Colors.green.withAlpha((0.1 * 255).round()));
      }
    }
    return null;
  }

  List<DataCell> _buildRowCells(int rowIndex, dynamic data) {
    return widget.previewData.columns
        .where((column) => column.visible)
        .map(
          (column) => DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: InkWell(
                onTap: () => setState(() {
                  _selectedRowIndex = rowIndex;
                  _isChecked = false;
                }),
                child: _buildCellContent(data, column.type),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildCellContent(dynamic data, ColumnType columnType) {
    final text = DataTransformer.getCellText(data, columnType);
    return Text(text, overflow: TextOverflow.ellipsis);
  }
}
