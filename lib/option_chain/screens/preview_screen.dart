import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/models/tasks/choose_bucket_rows_task.dart';
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
      required bool isEditorMode,
      int? maxSelectableRows}) {
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
          isEditorMode: isEditorMode,
          maxSelectableRows: maxSelectableRows),
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
  List<Map<int, int>> correctBucketIndexes = [];
  Map<int, bool> bucketSelections = {};
  Map<int, bool> bucketCallSelections = {};
  Map<int, bool> bucketPutSelections = {};
  Map<int, bool> callBuySelections = {};
  Map<int, bool> callSellSelections = {};
  Map<int, bool> putBuySelections = {};
  Map<int, bool> putSellSelections = {};

  @override
  void initState() {
    super.initState();
    _selectedRowIndex = List.from(widget.previewData.selectedRowIndices);

    if (widget.previewData.bucketRows != null) {
      for (var bucketRow in widget.previewData.bucketRows!) {
        final rowIndex = bucketRow.rowIndex;
        final side = bucketRow.side;
        final isBuy = bucketRow.isBuy;

        if (side == 0) {
          bucketCallSelections[rowIndex] = true;
          bucketSelections[rowIndex] = true;
          if (isBuy) {
            callBuySelections[rowIndex] = true;
          } else {
            callSellSelections[rowIndex] = true;
          }
        } else {
          bucketPutSelections[rowIndex] = true;
          bucketSelections[rowIndex] = true;
          if (isBuy) {
            putBuySelections[rowIndex] = true;
          } else {
            putSellSelections[rowIndex] = true;
          }
        }
      }
    }
  }

  void chooseRow(int rowIndex) {
    setState(() {
      final maxSelectedRows = widget.previewData.maxSelectableRows;

      if (maxSelectedRows == null || maxSelectedRows == 0) {
        if (!userSelectedIndex.contains(rowIndex)) {
          userSelectedIndex.add(rowIndex);
        }
      } else {
        if (userSelectedIndex.contains(rowIndex)) {
          userSelectedIndex.remove(rowIndex);
        } else if (userSelectedIndex.length < maxSelectedRows) {
          userSelectedIndex.add(rowIndex);
        }
      }
      _isChecked = true;
    });
  }

  void chooseBucketRows(List<BucketRowSelection> bucketRows) {
    setState(() {
      correctBucketIndexes = bucketRows.map((e) => e.toLegacyFormat()).toList();
      for (var bucketRow in bucketRows) {
        final rowIndex = bucketRow.rowIndex;
        final side = bucketRow.side;
        final isBuy = bucketRow.isBuy;

        if (side == 0) {
          bucketCallSelections[rowIndex] = true;
          if (isBuy) {
            callBuySelections[rowIndex] = true;
          } else {
            callSellSelections[rowIndex] = true;
          }
        } else {
          bucketPutSelections[rowIndex] = true;
          if (isBuy) {
            putBuySelections[rowIndex] = true;
          } else {
            putSellSelections[rowIndex] = true;
          }
        }
        bucketSelections[rowIndex] = true;
      }
      _isChecked = true;
    });
  }

  List<int>? getCorrectRowIndex() {
    final selectionMode =
        widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;
    if (selectionMode == SelectionMode.bucketRow) {
      return bucketSelections.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
    }
    return _selectedRowIndex;
  }

  List<BucketRowSelection>? getBucketRows() {
    final selectionMode =
        widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;
    if (selectionMode == SelectionMode.bucketRow) {
      List<BucketRowSelection> bucketRows = [];
      
      // Handle call side selections (left side of strike)
      callBuySelections.forEach((rowIndex, isSelected) {
        if (isSelected) {
          bucketRows.add(BucketRowSelection(
            rowIndex: rowIndex,
            side: 0, // 0 for call side
            isBuy: true,
          ));
        }
      });
      callSellSelections.forEach((rowIndex, isSelected) {
        if (isSelected) {
          bucketRows.add(BucketRowSelection(
            rowIndex: rowIndex,
            side: 0, // 0 for call side
            isBuy: false,
          ));
        }
      });
      
      // Handle put side selections (right side of strike)
      putBuySelections.forEach((rowIndex, isSelected) {
        if (isSelected) {
          bucketRows.add(BucketRowSelection(
            rowIndex: rowIndex,
            side: 1, // 1 for put side
            isBuy: true,
          ));
        }
      });
      putSellSelections.forEach((rowIndex, isSelected) {
        if (isSelected) {
          bucketRows.add(BucketRowSelection(
            rowIndex: rowIndex,
            side: 1, // 1 for put side
            isBuy: false,
          ));
        }
      });

      return bucketRows;
    }
    return null;
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
    final selectionMode =
        widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;

    return widget.previewData.optionData.asMap().entries.map((entry) {
      final rowIndex = entry.key;
      final rowColor = selectionMode == SelectionMode.entireRow
          ? _getRowColor(rowIndex, strikeColumnIndex)
          : null;

      return DataRow(
        color: rowColor,
        cells: _buildRowCells(rowIndex, entry.value, strikeColumnIndex),
      );
    }).toList();
  }

  WidgetStateProperty<Color>? _getRowColor(
      int rowIndex, int? strikeColumnIndex) {
    if (_selectedRowIndex.contains(rowIndex) ||
        userSelectedIndex.contains(rowIndex)) {
      if (userSelectedIndex.contains(rowIndex)) {
        return WidgetStateProperty.all(
            Colors.green.withAlpha((0.2 * 255).round()));
      } else if (_selectedRowIndex.contains(rowIndex)) {
        if (_isChecked &&
            !widget.previewData.correctRowIndices.contains(rowIndex)) {
          return WidgetStateProperty.all(
              Colors.red.withAlpha((0.2 * 255).round()));
        } else {
          return WidgetStateProperty.all(
              Colors.blue.withAlpha((0.2 * 255).round()));
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
      bool isSelectable = _isCellSelectable(
        actualColumnIndex: columnIndex,
        strikeColumnIndex: strikeColumnIndex,
        selectionMode: selectionMode,
      );

      cellColor = _getCellColor(
        rowIndex: rowIndex,
        actualColumnIndex: columnIndex,
        strikeColumnIndex: strikeColumnIndex,
        strikePrice: strikePrice,
        currentRowStrike: currentRowStrike,
        selectionMode: selectionMode,
      );

      if (column.columnType == ColumnType.strike && cellColor == null) {
        cellColor = Colors.grey.shade200;
      }

      return DataCell(
        Container(
          color: cellColor,
          width: 100,
          alignment: Alignment.center,
          child: InkWell(
            onTap: isSelectable
                ? () {
                    if (selectionMode == SelectionMode.bucketRow) {
                      _handleBucketCellTap(
                          rowIndex, columnIndex, strikeColumnIndex);
                    } else {
                      _handleCellTap(rowIndex);
                    }
                  }
                : null,
            child: _buildCellContent(rowIndex, data, column.columnType),
          ),
        ),
      );
    }).toList();
  }

  Color? _getCellColor({
    required int rowIndex,
    required int actualColumnIndex,
    required int? strikeColumnIndex,
    required double? strikePrice,
    required double currentRowStrike,
    required SelectionMode selectionMode,
  }) {
    Color? cellColor;

    if (selectionMode == SelectionMode.bucketRow && strikeColumnIndex != null) {
      if (actualColumnIndex < strikeColumnIndex) {
        if (callBuySelections[rowIndex] == true) {
          return Colors.green.withAlpha((0.2 * 255).round());
        } else if (callSellSelections[rowIndex] == true) {
          return Colors.red.withAlpha((0.2 * 255).round());
        }
      } else if (actualColumnIndex > strikeColumnIndex) {
        if (putBuySelections[rowIndex] == true) {
          return Colors.green.withAlpha((0.2 * 255).round());
        } else if (putSellSelections[rowIndex] == true) {
          return Colors.red.withAlpha((0.2 * 255).round());
        }
      }
    }

    if (strikePrice != null && strikeColumnIndex != null) {
      if (currentRowStrike < strikePrice &&
          actualColumnIndex < strikeColumnIndex) {
        cellColor = Colors.blue.withAlpha((0.1 * 255).round());
      } else if (currentRowStrike > strikePrice &&
          actualColumnIndex > strikeColumnIndex) {
        cellColor = Colors.red.withAlpha((0.1 * 255).round());
      }
    }

    if (selectionMode == SelectionMode.bucketRow) {
      if (!_isChecked) {
        if (bucketSelections.containsKey(rowIndex)) {
          if (actualColumnIndex < strikeColumnIndex! &&
              bucketCallSelections.containsKey(rowIndex)) {
            cellColor = Colors.blue.withAlpha((0.4 * 255).round());
          } else if (actualColumnIndex > strikeColumnIndex &&
              bucketPutSelections.containsKey(rowIndex)) {
            cellColor = Colors.blue.withAlpha((0.4 * 255).round());
          }
        }
      } else {
        bool isCorrect = false;
        for (var correct in correctBucketIndexes) {
          if (correct.containsKey(rowIndex)) {
            final correctSide = correct[rowIndex];
            if (strikeColumnIndex != null) {
              if (actualColumnIndex < strikeColumnIndex &&
                  correctSide == 0 &&
                  bucketCallSelections.containsKey(rowIndex)) {
                isCorrect = true;
              } else if (actualColumnIndex > strikeColumnIndex &&
                  correctSide == 1 &&
                  bucketPutSelections.containsKey(rowIndex)) {
                isCorrect = true;
              }
            }
            break;
          }
        }

        if (strikeColumnIndex != null) {
          if (actualColumnIndex < strikeColumnIndex &&
              bucketCallSelections.containsKey(rowIndex)) {
            cellColor = isCorrect
                ? Colors.green.withAlpha((0.4 * 255).round())
                : Colors.red.withAlpha((0.4 * 255).round());
          } else if (actualColumnIndex > strikeColumnIndex &&
              bucketPutSelections.containsKey(rowIndex)) {
            cellColor = isCorrect
                ? Colors.green.withAlpha((0.4 * 255).round())
                : Colors.red.withAlpha((0.4 * 255).round());
          }
        }
      }
    } else if (selectionMode == SelectionMode.entireRow) {
      bool shouldHighlight = false;
      if (selectionMode == SelectionMode.callOnly) {
        shouldHighlight =
            strikeColumnIndex != null && actualColumnIndex <= strikeColumnIndex;
      } else if (selectionMode == SelectionMode.putOnly) {
        shouldHighlight =
            strikeColumnIndex != null && actualColumnIndex >= strikeColumnIndex;
      } else {
        shouldHighlight = true;
      }

      if (shouldHighlight) {
        if (userSelectedIndex.contains(rowIndex)) {
          cellColor = Colors.green.withAlpha((0.2 * 255).round());
        } else if (_selectedRowIndex.contains(rowIndex)) {
          if (_isChecked &&
              !widget.previewData.correctRowIndices.contains(rowIndex)) {
            cellColor = Colors.red.withAlpha((0.2 * 255).round());
          } else {
            cellColor = Colors.blue.withAlpha((0.2 * 255).round());
          }
        }
      }
    }

    return cellColor;
  }

  bool _isCellSelectable({
    required int actualColumnIndex,
    required int? strikeColumnIndex,
    required SelectionMode selectionMode,
  }) {
    switch (selectionMode) {
      case SelectionMode.callOnly:
        return strikeColumnIndex != null &&
            actualColumnIndex <= strikeColumnIndex;
      case SelectionMode.putOnly:
        return strikeColumnIndex != null &&
            actualColumnIndex >= strikeColumnIndex;
      case SelectionMode.entireRow:
        return true;
      case SelectionMode.bucketRow:
        return strikeColumnIndex != null &&
            actualColumnIndex != strikeColumnIndex;
    }
  }

  void _handleBucketCellTap(
      int rowIndex, int columnIndex, int? strikeColumnIndex) {
    if (strikeColumnIndex == null) return;

    setState(() {
      final maxSelectedRows = widget.previewData.maxSelectableRows;

      if (columnIndex < strikeColumnIndex) {
        if (bucketCallSelections.containsKey(rowIndex)) {
          bucketCallSelections.remove(rowIndex);
          if (!bucketPutSelections.containsKey(rowIndex)) {
            bucketSelections.remove(rowIndex);
          }
        } else {
          if (maxSelectedRows == 1) {
            bucketCallSelections.clear();
            bucketPutSelections.clear();
            bucketSelections.clear();
            bucketCallSelections[rowIndex] = true;
            bucketSelections[rowIndex] = true;
          } else if (maxSelectedRows != null && maxSelectedRows > 1) {
            if (bucketSelections.length < maxSelectedRows) {
              bucketCallSelections[rowIndex] = true;
              bucketSelections[rowIndex] = true;
            }
          } else {
            bucketCallSelections[rowIndex] = true;
            bucketSelections[rowIndex] = true;
          }
        }
      } else if (columnIndex > strikeColumnIndex) {
        if (bucketPutSelections.containsKey(rowIndex)) {
          bucketPutSelections.remove(rowIndex);
          if (!bucketCallSelections.containsKey(rowIndex)) {
            bucketSelections.remove(rowIndex);
          }
        } else {
          if (maxSelectedRows == 1) {
            bucketCallSelections.clear();
            bucketPutSelections.clear();
            bucketSelections.clear();
            bucketPutSelections[rowIndex] = true;
            bucketSelections[rowIndex] = true;
          } else if (maxSelectedRows != null && maxSelectedRows > 1) {
            if (bucketSelections.length < maxSelectedRows) {
              bucketPutSelections[rowIndex] = true;
              bucketSelections[rowIndex] = true;
            }
          } else {
            bucketPutSelections[rowIndex] = true;
            bucketSelections[rowIndex] = true;
          }
        }
      }
      _isChecked = false;
    });
  }

  Widget _buildCellContent(
      int rowIndex, OptionData data, ColumnType columnType) {
    final text = DataTransformer.getCellText(data, columnType);
    final strikeColumnIndex = _getStrikeColumnIndex();

    if (!widget.previewData.isEditorMode &&
        widget.previewData.settings?.isBuySellVisible == true &&
        (columnType == ColumnType.callPremium ||
            columnType == ColumnType.putPremium)) {
      final columnIndex = widget.previewData.columns
          .indexWhere((col) => col.columnType == columnType);

      final isCallSide =
          strikeColumnIndex != null && columnIndex < strikeColumnIndex;

      final buySelections = isCallSide ? callBuySelections : putBuySelections;
      final sellSelections =
          isCallSide ? callSellSelections : putSellSelections;

      final isBuySelected = buySelections[rowIndex] ?? false;
      final isSellSelected = sellSelections[rowIndex] ?? false;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(text, overflow: TextOverflow.ellipsis),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      if (isBuySelected) {
                        buySelections.remove(rowIndex);
                      } else {
                        buySelections[rowIndex] = true;
                        sellSelections.remove(rowIndex);
                        if (isCallSide) {
                          bucketCallSelections[rowIndex] = true;
                          bucketSelections[rowIndex] = true;
                        } else {
                          bucketPutSelections[rowIndex] = true;
                          bucketSelections[rowIndex] = true;
                        }
                      }
                      widget.onBuySellSelected?.call(rowIndex, true);
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 12),
                      decoration: BoxDecoration(
                          color: isBuySelected
                              ? Colors.green.shade700
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('Buy',
                          style: TextStyle(
                              fontSize: 10,
                              color: isBuySelected
                                  ? Colors.white
                                  : Colors.black)))),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isSellSelected) {
                      sellSelections.remove(rowIndex);
                    } else {
                      sellSelections[rowIndex] = true;
                      buySelections.remove(rowIndex);
                      if (isCallSide) {
                        bucketCallSelections[rowIndex] = true;
                        bucketSelections[rowIndex] = true;
                      } else {
                        bucketPutSelections[rowIndex] = true;
                        bucketSelections[rowIndex] = true;
                      }
                    }
                    widget.onBuySellSelected?.call(rowIndex, false);
                  });
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    decoration: BoxDecoration(
                        color:
                            isSellSelected ? Colors.red.shade700 : Colors.red,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('Sell',
                        style: TextStyle(
                            fontSize: 10,
                            color:
                                isSellSelected ? Colors.white : Colors.black))),
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
      final selectionMode =
          widget.previewData.settings?.selectionMode ?? SelectionMode.entireRow;
      final maxSelectedRows = widget.previewData.maxSelectableRows;

      if (selectionMode == SelectionMode.bucketRow) {
        return;
      }

      if (maxSelectedRows == 1) {
        if (_selectedRowIndex.contains(rowIndex)) {
          _selectedRowIndex.remove(rowIndex);
        } else {
          _selectedRowIndex = [rowIndex];
        }
      } else if (maxSelectedRows != null && maxSelectedRows > 1) {
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

  void setBuySellSelections(List<BucketRowSelection> bucketRows) {
    setState(() {
      bucketCallSelections.clear();
      bucketPutSelections.clear();
      callBuySelections.clear();
      callSellSelections.clear();
      putBuySelections.clear();
      putSellSelections.clear();

      for (var bucketRow in bucketRows) {
        final rowIndex = bucketRow.rowIndex;
        final side = bucketRow.side;
        final isBuy = bucketRow.isBuy;

        if (side == 0) {
          bucketCallSelections[rowIndex] = true;
          bucketSelections[rowIndex] = true;
          if (isBuy) {
            callBuySelections[rowIndex] = true;
          } else {
            callSellSelections[rowIndex] = true;
          }
        } else {
          bucketPutSelections[rowIndex] = true;
          bucketSelections[rowIndex] = true;
          if (isBuy) {
            putBuySelections[rowIndex] = true;
          } else {
            putSellSelections[rowIndex] = true;
          }
        }
      }

      correctBucketIndexes = bucketRows.map((e) => e.toLegacyFormat()).toList();
      _isChecked = true;
    });
  }

  void clearBucketSelections() {
    setState(() {
      bucketCallSelections.clear();
      bucketPutSelections.clear();
      callBuySelections.clear();
      callSellSelections.clear();
      putBuySelections.clear();
      putSellSelections.clear();
      bucketSelections.clear();
      correctBucketIndexes = [];
      _isChecked = false;
    });
  }
}
