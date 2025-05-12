import 'package:fin_chart/models/tasks/add_option_chain.task.dart';
import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:fin_chart/option_chain/models/option_data.dart';
import 'package:fin_chart/option_chain/models/preview_data.dart';
import 'package:fin_chart/option_chain/screens/preview_screen.dart';
import 'package:fin_chart/option_chain/utils/data_transformer.dart';
import 'package:fin_chart/option_chain/utils/option_chain_utils.dart';
import 'package:fin_chart/option_chain/widgets/add_column_dialog.dart';
import 'package:fin_chart/option_chain/widgets/edit_cell_dialog.dart';
import 'package:fin_chart/option_chain/widgets/edit_column_dialog.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OptionChainPage extends StatefulWidget {
  final bool isDialog;
  final Function(AddOptionChainTask)? onSave;
  final AddOptionChainTask? initialTask;

  const OptionChainPage({
    super.key,
    this.isDialog = false,
    this.onSave,
    this.initialTask,
  });

  @override
  State<OptionChainPage> createState() => _OptionChainPageState();
}

class _OptionChainPageState extends State<OptionChainPage> {
  late DateTime _expiryDate;
  late OptionChainVisibility _visibility;
  late double _strikePrice;
  late double _minStrike;
  late double _maxStrike;
  late int _interval;
  int? _selectedRowIndex;
  final GlobalKey<PreviewScreenState> _previewKey =
      GlobalKey<PreviewScreenState>();

  late List<ColumnConfig> _columns = [];
  late List<OptionData> _optionData;
  late List<ColumnConfig> _customColumns;

  @override
  void initState() {
    super.initState();
    _expiryDate = widget.initialTask?.expiryDate ??
        DateTime.now().add(const Duration(days: 30));
    _visibility = widget.initialTask?.visibility ?? OptionChainVisibility.both;
    _interval = widget.initialTask?.interval ?? 5;

    _selectedRowIndex = widget.initialTask?.correctRowIndex;
    if (widget.initialTask?.data.isNotEmpty ?? false) {
      final strikes = widget.initialTask!.data.map((d) => d.strike).toList();
      _strikePrice = widget.initialTask!.strikePrice ??
          strikes.reduce((a, b) => a > b ? a : b);
      _minStrike = strikes.reduce((a, b) => a < b ? a : b);
      _maxStrike = _strikePrice;
    } else {
      _strikePrice = 100.0;
      _minStrike = 50.0;
      _maxStrike = 150.0;
    }

    _customColumns = [];
    _updateColumns();
    _optionData = widget.initialTask?.data ?? _generateOptionData();
  }

  List<OptionData> _generateOptionData() {
    return OptionChainUtils.generateOptionData(
      minStrike: _minStrike,
      maxStrike: _maxStrike,
      interval: _interval,
    );
  }

  void _updateColumns() {
    setState(() {
      final currentVisibility = <ColumnType, bool>{};
      for (var col in _columns) {
        currentVisibility[col.type] = col.visible;
      }
      if (widget.initialTask != null && _columns.isEmpty) {
        _customColumns = widget.initialTask!.columns.where((col) {
          final defaultTypes = OptionChainUtils.getDefaultColumns(_visibility)
              .map((c) => c.type)
              .toList();
          return !defaultTypes.contains(col.type);
        }).toList();
      }
      _columns = OptionChainUtils.getDefaultColumns(
        _visibility,
        customColumns: _customColumns,
      );

      if (currentVisibility.isNotEmpty) {
        _columns = _columns.map((column) {
          return ColumnConfig(
            type: column.type,
            name: column.name,
            visible: currentVisibility[column.type] ?? column.visible,
          );
        }).toList();
      }

      if (widget.initialTask != null) {
        final taskVisibility = <ColumnType, bool>{};
        for (var col in widget.initialTask!.columns) {
          taskVisibility[col.type] = col.visible;
        }

        if (taskVisibility.isNotEmpty) {
          _columns = _columns.map((column) {
            return ColumnConfig(
              type: column.type,
              name: column.name,
              visible: taskVisibility[column.type] ?? column.visible,
            );
          }).toList();
        }
      }
    });
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() => _expiryDate = picked);
    }
  }

  void _showAddColumnDialog() {
    final availableTypes = DataTransformer.getAvailableColumnTypes(_columns);

    if (availableTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All column types already added')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddColumnDialog(
        availableTypes: availableTypes,
        onAdd: (type) {
          setState(() {
            _customColumns.add(
              ColumnConfig(
                type: type,
                name: type.displayName,
                visible: true,
              ),
            );
            _updateColumns();
          });
        },
      ),
    );
  }

  void _showEditColumnDialog(int columnIndex) {
    showDialog(
      context: context,
      builder: (context) => EditColumnDialog(
        column: _columns[columnIndex],
        initialValues: DataTransformer.getColumnValuesAsString(
            _optionData, _columns[columnIndex]),
        onSave: (newName, values) =>
            _updateColumn(columnIndex, newName, values),
      ),
    );
  }

  void _updateColumn(int columnIndex, String newName, String values) {
    setState(() {
      _columns[columnIndex].name = newName;

      List<String> valueList = values.trim().isEmpty ? [] : values.split('\n');
      int newRowCount = valueList.length;

      if (newRowCount > 0) {
        if (newRowCount != _optionData.length) {
          _optionData = _optionData.sublist(0, newRowCount);
        }

        ColumnType columnType = _columns[columnIndex].type;

        for (int i = 0; i < _optionData.length && i < valueList.length; i++) {
          String value = valueList[i].replaceAll(",", "");
          OptionData data = _optionData[i];
          switch (columnType) {
            case ColumnType.strike:
              data.strike = double.tryParse(value) ?? data.strike;
              break;
            case ColumnType.callOi:
              data.callOi = int.tryParse(value) ?? data.callOi;
              break;
            case ColumnType.callPremium:
              data.callPremium = double.tryParse(value) ?? data.callPremium;
              break;
            case ColumnType.putOi:
              data.putOi = int.tryParse(value) ?? data.putOi;
              break;
            case ColumnType.putPremium:
              data.putPremium = double.tryParse(value) ?? data.putPremium;
              break;
            case ColumnType.callDelta:
              data.callDelta = double.tryParse(value) ?? data.callDelta;
              break;
            case ColumnType.callGamma:
              data.callGamma = double.tryParse(value) ?? data.callGamma;
              break;
            case ColumnType.callVega:
              data.callVega = double.tryParse(value) ?? data.callVega;
              break;
            case ColumnType.callTheta:
              data.callTheta = double.tryParse(value) ?? data.callTheta;
              break;
            case ColumnType.callIV:
              data.callIV = double.tryParse(value) ?? data.callIV;
              break;
            case ColumnType.putDelta:
              data.putDelta = double.tryParse(value) ?? data.putDelta;
              break;
            case ColumnType.putGamma:
              data.putGamma = double.tryParse(value) ?? data.putGamma;
              break;
            case ColumnType.putVega:
              data.putVega = double.tryParse(value) ?? data.putVega;
              break;
            case ColumnType.putTheta:
              data.putTheta = double.tryParse(value) ?? data.putTheta;
              break;
            case ColumnType.putIV:
              data.putIV = double.tryParse(value) ?? data.putIV;
              break;
          }
        }
      }
    });
  }

  void _showEditCellDialog(int columnIndex, int rowIndex) {
    ColumnConfig column = _columns[columnIndex];
    OptionData data = _optionData[rowIndex];
    String initialValue;

    switch (column.type) {
      case ColumnType.strike:
        initialValue = data.strike.toString();
        break;
      case ColumnType.callOi:
        initialValue = data.callOi.toString();
        break;
      case ColumnType.callPremium:
        initialValue = data.callPremium.toString();
        break;
      case ColumnType.putOi:
        initialValue = data.putOi.toString();
        break;
      case ColumnType.putPremium:
        initialValue = data.putPremium.toString();
        break;
      case ColumnType.callDelta:
        initialValue = data.callDelta.toString();
        break;
      case ColumnType.callGamma:
        initialValue = data.callGamma.toString();
        break;
      case ColumnType.callVega:
        initialValue = data.callVega.toString();
        break;
      case ColumnType.callTheta:
        initialValue = data.callTheta.toString();
        break;
      case ColumnType.callIV:
        initialValue = data.callIV.toString();
        break;
      case ColumnType.putDelta:
        initialValue = data.putDelta.toString();
        break;
      case ColumnType.putGamma:
        initialValue = data.putGamma.toString();
        break;
      case ColumnType.putVega:
        initialValue = data.putVega.toString();
        break;
      case ColumnType.putTheta:
        initialValue = data.putTheta.toString();
        break;
      case ColumnType.putIV:
        initialValue = data.putIV.toString();
        break;
    }

    showDialog(
      context: context,
      builder: (context) => EditCellDialog(
        initialValue: initialValue,
        onSave: (value) => _updateCell(columnIndex, rowIndex, value),
      ),
    );
  }

  void _updateCell(int columnIndex, int rowIndex, String value) {
    setState(() {
      ColumnType columnType = _columns[columnIndex].type;
      OptionData data = _optionData[rowIndex];

      switch (columnType) {
        case ColumnType.strike:
          data.strike = double.tryParse(value) ?? data.strike;
          break;
        case ColumnType.callOi:
          data.callOi = int.tryParse(value) ?? data.callOi;
          break;
        case ColumnType.callPremium:
          data.callPremium = double.tryParse(value) ?? data.callPremium;
          break;
        case ColumnType.putOi:
          data.putOi = int.tryParse(value) ?? data.putOi;
          break;
        case ColumnType.putPremium:
          data.putPremium = double.tryParse(value) ?? data.putPremium;
          break;
        case ColumnType.callDelta:
          data.callDelta = double.tryParse(value) ?? data.callDelta;
          break;
        case ColumnType.callGamma:
          data.callGamma = double.tryParse(value) ?? data.callGamma;
          break;
        case ColumnType.callVega:
          data.callVega = double.tryParse(value) ?? data.callVega;
          break;
        case ColumnType.callTheta:
          data.callTheta = double.tryParse(value) ?? data.callTheta;
          break;
        case ColumnType.callIV:
          data.callIV = double.tryParse(value) ?? data.callIV;
          break;
        case ColumnType.putDelta:
          data.putDelta = double.tryParse(value) ?? data.putDelta;
          break;
        case ColumnType.putGamma:
          data.putGamma = double.tryParse(value) ?? data.putGamma;
          break;
        case ColumnType.putVega:
          data.putVega = double.tryParse(value) ?? data.putVega;
          break;
        case ColumnType.putTheta:
          data.putTheta = double.tryParse(value) ?? data.putTheta;
          break;
        case ColumnType.putIV:
          data.putIV = double.tryParse(value) ?? data.putIV;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDialog) {
      return _buildDialogContent();
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigurationCard(),
            const SizedBox(height: 24),
            _buildTableCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: 800,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfigurationCard(),
                    const SizedBox(height: 24),
                    _buildTableCard(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final task = AddOptionChainTask(
                        strikePrice: _strikePrice,
                        columns: _columns,
                        data: _optionData,
                        visibility: _visibility,
                        expiryDate: _expiryDate,
                        interval: _interval,
                        optionChainId: generateV4());
                    if (widget.onSave != null) {
                      widget.onSave!(task);
                    }
                    Navigator.pop(context, task);
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options Chain Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildExpiryDateRow(),
            const SizedBox(height: 8),
            _buildVisibilityRow(),
            const SizedBox(height: 8),
            _buildStrikePriceRow(),
            const SizedBox(height: 8),
            _buildIntervalRow(),
            const SizedBox(height: 16),
            _buildColumnsRow(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDateRow() {
    return Row(
      children: [
        const Text('Expiry Date: '),
        TextButton(
          onPressed: () => _selectExpiryDate(context),
          child: Text(DateFormat('dd MMM yyyy').format(_expiryDate)),
        ),
      ],
    );
  }

  Widget _buildVisibilityRow() {
    return Row(
      children: [
        const Text('Option Chain Visibility: '),
        DropdownButton<OptionChainVisibility>(
          value: _visibility,
          onChanged: (OptionChainVisibility? newValue) {
            setState(() {
              _visibility = newValue!;
              _updateColumns();
            });
          },
          items: OptionChainVisibility.values.map((value) {
            return DropdownMenuItem<OptionChainVisibility>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStrikePriceRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Strike Price'),
            initialValue: _strikePrice.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _strikePrice = double.tryParse(value) ?? _strikePrice;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Min Strike'),
            initialValue: _minStrike.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _minStrike = double.tryParse(value) ?? _minStrike;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Max Strike'),
            initialValue: _maxStrike.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _maxStrike = double.tryParse(value) ?? _maxStrike;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Interval'),
            value: _interval,
            onChanged: (int? newValue) {
              setState(() => _interval = newValue!);
            },
            items: [5, 10, 50].map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnsRow() {
    return Wrap(
      spacing: 8,
      children: [
        const Text('Columns: '),
        ..._columns.map((column) {
          return FilterChip(
            label: Text(column.name),
            selected: column.visible,
            onSelected: (bool selected) {
              setState(() => column.visible = selected);
            },
            onDeleted: () {
              setState(() {
                _columns.remove(column);
                _customColumns.removeWhere(
                  (c) => c.type == column.type,
                );
              });
            },
          );
        }),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddColumnDialog,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _optionData = _generateOptionData();
          });
        },
        child: const Text('Generate Data'),
      ),
    );
  }

  Widget _buildTableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Options Chain Table',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionsTable(),
            if (!widget.isDialog) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedRowIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a row first'),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PreviewScreen(
                        key: _previewKey,
                        previewData: PreviewData(
                          strikePrice: _strikePrice,
                          expiryDate: _expiryDate,
                          optionData: _optionData,
                          columns: _columns.where((c) => c.visible).toList(),
                          visibility: _visibility,
                          correctRowIndex: _selectedRowIndex,
                        ),
                      );
                    }),
                  );
                },
                child: const Text('Preview Table'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _buildDataColumns(),
        rows: _buildDataRows(),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return _columns.map((column) {
      return DataColumn(
        label: Row(
          children: [
            Text(column.name),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () {
                int columnIndex = _columns.indexOf(column);
                _showEditColumnDialog(columnIndex);
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  List<DataRow> _buildDataRows() {
    return _optionData.asMap().entries.map((entry) {
      int rowIndex = entry.key;
      OptionData data = entry.value;
      return DataRow(
        color: rowIndex == _selectedRowIndex
            ? WidgetStateProperty.all(
                Colors.blue..withAlpha((0.1 * 255).round()))
            : null,
        cells: _columns.map((column) {
          return DataCell(
            InkWell(
              onTap: () => setState(() => _selectedRowIndex = rowIndex),
              onDoubleTap: () {
                int columnIndex = _columns.indexOf(column);
                _showEditCellDialog(columnIndex, rowIndex);
              },
              child: Text(DataTransformer.getCellText(data, column.type)),
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}
