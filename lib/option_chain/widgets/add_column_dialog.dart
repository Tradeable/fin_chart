import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:flutter/material.dart';

class AddColumnDialog extends StatelessWidget {
  final List<ColumnType> availableTypes;
  final Function(ColumnType) onAdd;

  const AddColumnDialog({
    super.key,
    required this.availableTypes,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    ColumnType? selectedType;

    return AlertDialog(
      title: const Text('Add New Column'),
      content: StatefulBuilder(
        builder: (context, setState) => DropdownButton<ColumnType>(
          value: selectedType,
          hint: const Text('Select column type'),
          onChanged: (ColumnType? newValue) {
            setState(() => selectedType = newValue);
          },
          items: availableTypes.map((ColumnType type) {
            return DropdownMenuItem<ColumnType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (selectedType != null) {
              onAdd(selectedType!);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
