import 'package:fin_chart/option_chain/models/column_config.dart';
import 'package:flutter/material.dart';

class EditColumnDialog extends StatelessWidget {
  final ColumnConfig column;
  final String initialValues;
  final Function(String, String) onSave;

  const EditColumnDialog({
    super.key,
    required this.column,
    required this.initialValues,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: column.name);
    final valuesController = TextEditingController(text: initialValues);

    return AlertDialog(
      title: Text('Edit Column ${column.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: valuesController,
            decoration: const InputDecoration(
              labelText: 'Enter values separated by new line',
              hintText: 'Enter values separated by new line',
            ),
            maxLines: null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onSave(nameController.text, valuesController.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
