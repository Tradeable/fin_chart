import 'package:example/editor/ui/widget/markdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/show_popup.task.dart';

Future<ShowPopupTask?> showPopupDialog({
  required BuildContext context,
  ShowPopupTask? initialTask,
}) async {
  final TextEditingController titleController = TextEditingController(
    text: initialTask?.title ?? '',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: initialTask?.description ?? '',
  );
  final TextEditingController buttonTextController = TextEditingController(
    text: initialTask?.buttonText ?? 'Continue',
  );

  final List<String> quickButtonOptions = [
    'Continue',
    'Next',
    'Got it',
    'Understood',
    'Let\'s go',
    'Okay',
    'Done'
  ];

  return showDialog<ShowPopupTask>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(initialTask != null ? 'Edit Popup' : 'Add Popup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MarkdownTextField(
                        controller: titleController, hint: "Enter Popup title"),
                  )),
              const SizedBox(height: 16),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MarkdownTextField(
                        controller: descriptionController,
                        hint: "Enter Popup description"),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: buttonTextController,
                decoration: const InputDecoration(
                  labelText: 'Button Text',
                  hintText: 'Enter button text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              const Text('Quick Button Options:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickButtonOptions.map((option) {
                  return ActionChip(
                    label: Text(option),
                    onPressed: () {
                      buttonTextController.text = option;
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final buttonText = buttonTextController.text.trim();

              if (title.isEmpty || description.isEmpty || buttonText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              Navigator.of(context).pop(
                ShowPopupTask(
                  title: title,
                  description: description,
                  buttonText: buttonText,
                ),
              );
            },
            child: Text(initialTask != null ? 'Update' : 'Create'),
          ),
        ],
      );
    },
  );
}
