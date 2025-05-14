import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/utils/data_transformer.dart';
import 'package:flutter/material.dart';

class PreviewScreen extends StatefulWidget {
  final PreviewData previewData;
  final Function(int rowIndex, bool isCallSide)? onBuySellSelected;

  const PreviewScreen({
    super.key,
    required this.previewData,
    this.onBuySellSelected,
  });

  factory PreviewScreen.from(
      {required GlobalKey key,
      required AddOptionChainTask task,
      List<int>? selectedRowIndex,
      List<int>? correctRowIndex,
      Function(int rowIndex, bool isCallSide)? onBuySellSelected,
      required bool isEditorMode}) {
    return PreviewScreen(
      key: key,
      previewData: PreviewData(
          strikePrice: task.strikePrice,
          expiryDate: task.expiryDate,
          optionData: task.data,
          columns: task.columns.where((c) => c.isColumnVisible).toList(),
          visibility: task.visibility,
          settings: task.settings,
          selectedRowIndices: selectedRowIndex ?? [],
          correctRowIndices: correctRowIndex ?? [],
          isEditorMode: isEditorMode),
      onBuySellSelected: onBuySellSelected,
    );
  }

  @override
  State<PreviewScreen> createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  List<int> _selectedRowIndex = [];
  bool _isChecked = false;
  List<int> userSelectedIndex = [];

  @override
  void initState() {
    super.initState();
    _selectedRowIndex = List.from(widget.previewData.selectedRowIndices);
  }

  void chooseRow(int rowIndex) {
    setState(() {
      final maxSelectedRows =
          widget.previewData.settings?.maxSelectableRows ?? 0;
      if (maxSelectedRows == 1) {
        userSelectedIndex = [rowIndex];
      } else if (maxSelectedRows > 1) {
        if (userSelectedIndex.contains(rowIndex)) {
          userSelectedIndex.remove(rowIndex);
        } else if (userSelectedIndex.length < maxSelectedRows) {
          userSelectedIndex.add(rowIndex);
        }
      } else {
        if (!userSelectedIndex.contains(rowIndex)) {
          userSelectedIndex.add(rowIndex);
        }
      }
      _isChecked = true;
    });
  }

  List<int>? getCorrectRowIndex() => _selectedRowIndex;

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
          columnSpacing: 0,
          horizontalMargin: 0,
          columns: _buildDataColumns(),
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return widget.previewData.columns
        .where((column) => column.isColumnVisible)
        .map((column) => DataColumn(
              label: Container(
                width: 100,
                alignment: Alignment.center,
                child: Text(
                  column.columnTitle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ))
        .toList();
  }

  List<DataRow> _buildDataRows() {
    final strikeColumnIndex = _getStrikeColumnIndex();
    return widget.previewData.optionData.asMap().entries.map((entry) {
      final rowIndex = entry.key;
      return DataRow(
        color: _getRowColor(rowIndex, strikeColumnIndex),
        cells: _buildRowCells(rowIndex, entry.value, strikeColumnIndex),
      );
    }).toList();
  }

  WidgetStateProperty<Color>? _getRowColor(
      int rowIndex, int? strikeColumnIndex) {
    final selectionMode =
        widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;
    if (widget.previewData.visibility == OptionChainVisibility.both) {
      if (!_isChecked) {
        if (_selectedRowIndex.contains(rowIndex)) {
          if (selectionMode == SelectionMode.entireRow) {
            return WidgetStateProperty.all(
                Colors.blue.withAlpha((0.1 * 255).round()));
          }
        }
        return null;
      }
      if (userSelectedIndex.contains(rowIndex)) {
        if (selectionMode == SelectionMode.entireRow) {
          return WidgetStateProperty.all(
              Colors.green.withAlpha((0.1 * 255).round()));
        }
      } else {
        if (_selectedRowIndex.contains(rowIndex)) {
          if (selectionMode == SelectionMode.entireRow) {
            return WidgetStateProperty.all(
                Colors.red.withAlpha((0.4 * 255).round()));
          }
        } else if (userSelectedIndex.contains(rowIndex)) {
          if (selectionMode == SelectionMode.entireRow) {
            return WidgetStateProperty.all(
                Colors.green.withAlpha((0.4 * 255).round()));
          }
        }
      }
    }
    return null;
  }

  List<DataCell> _buildRowCells(
      int rowIndex, OptionData data, int? strikeColumnIndex) {
    final strikePrice = widget.previewData.strikePrice;
    final currentRowStrike = data.strike;
    final selectionMode =
        widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;

    return widget.previewData.columns
        .where((column) => column.isColumnVisible)
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final columnIndex = entry.key;
      final column = entry.value;

      Color? cellColor;
      bool isSelectable = true;

      if (strikePrice != null && strikeColumnIndex != null) {
        if (currentRowStrike < strikePrice && columnIndex < strikeColumnIndex) {
          cellColor = Colors.blue.withAlpha((0.1 * 255).round());
        } else if (currentRowStrike > strikePrice &&
            columnIndex > strikeColumnIndex) {
          cellColor = Colors.red.withAlpha((0.1 * 255).round());
        }
      }

      if (_selectedRowIndex.contains(rowIndex) ||
          userSelectedIndex.contains(rowIndex)) {
        bool shouldHighlight = false;
        if (selectionMode == SelectionMode.callOnly) {
          shouldHighlight =
              strikeColumnIndex != null && columnIndex <= strikeColumnIndex;
        } else if (selectionMode == SelectionMode.putOnly) {
          shouldHighlight =
              strikeColumnIndex != null && columnIndex >= strikeColumnIndex;
        } else {
          shouldHighlight = true;
        }
        if (shouldHighlight) {
          if (userSelectedIndex.contains(rowIndex)) {
            cellColor = Colors.green.withAlpha((0.1 * 255).round());
          } else if (_selectedRowIndex.contains(rowIndex)) {
            if (_isChecked &&
                !widget.previewData.correctRowIndices.contains(rowIndex)) {
              cellColor = Colors.red.withAlpha((0.4 * 255).round());
            } else {
              cellColor = Colors.blue.withAlpha((0.4 * 255).round());
            }
          }
        }
      }

      switch (selectionMode) {
        case SelectionMode.callOnly:
          isSelectable =
              strikeColumnIndex != null && columnIndex <= strikeColumnIndex;
          break;
        case SelectionMode.putOnly:
          isSelectable =
              strikeColumnIndex != null && columnIndex >= strikeColumnIndex;
          break;
        case SelectionMode.entireRow:
          isSelectable = true;
          break;
      }

      return DataCell(
        Container(
          color: cellColor,
          width: 100,
          alignment: Alignment.center,
          child: InkWell(
            onTap: isSelectable ? () => _handleCellTap(rowIndex) : null,
            child: _buildCellContent(rowIndex, data, column.columnType),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCellContent(
      int rowIndex, OptionData data, ColumnType columnType) {
    final text = DataTransformer.getCellText(data, columnType);

    if (!widget.previewData.isEditorMode &&
        widget.previewData.settings?.isBuySellVisible == true &&
        (columnType == ColumnType.callPremium ||
            columnType == ColumnType.putPremium)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(text, overflow: TextOverflow.ellipsis),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => widget.onBuySellSelected?.call(rowIndex, true),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Buy', style: TextStyle(fontSize: 10))),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => widget.onBuySellSelected?.call(rowIndex, false),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Sell', style: TextStyle(fontSize: 10))),
              ),
            ],
          ),
        ],
      );
    }
    return Text(text,
        overflow: TextOverflow.ellipsis, textAlign: TextAlign.center);
  }

  void _handleCellTap(int rowIndex) {
    setState(() {
      final maxSelectedRows =
          widget.previewData.settings?.maxSelectableRows ?? 0;
      if (maxSelectedRows == 1) {
        if (_selectedRowIndex.contains(rowIndex)) {
          _selectedRowIndex.remove(rowIndex);
        } else {
          _selectedRowIndex = [rowIndex];
        }
      } else if (maxSelectedRows > 1) {
        if (_selectedRowIndex.contains(rowIndex)) {
          _selectedRowIndex.remove(rowIndex);
        } else if (_selectedRowIndex.length < maxSelectedRows) {
          _selectedRowIndex.add(rowIndex);
        }
      } else {
        if (_selectedRowIndex.contains(rowIndex)) {
          _selectedRowIndex.remove(rowIndex);
        } else {
          _selectedRowIndex.add(rowIndex);
        }
      }
      _isChecked = false;
    });
  }

  int? _getStrikeColumnIndex() {
    final visibleColumns =
        widget.previewData.columns.where((c) => c.isColumnVisible).toList();
    for (int i = 0; i < visibleColumns.length; i++) {
      if (visibleColumns[i].columnType == ColumnType.strike) {
        return i;
      }
    }
    return null;
  }
}
