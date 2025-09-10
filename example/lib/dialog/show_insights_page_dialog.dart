import 'package:example/editor/ui/widget/markdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/show_insights_page.task.dart';

Future<ShowInsightsPageTask?> showInsightsPageDialog({
  required BuildContext context,
  ShowInsightsPageTask? initialTask,
}) async {
  final TextEditingController titleController = TextEditingController(
    text: initialTask?.title ?? '',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: initialTask?.description ?? '',
  );

  return showDialog<ShowInsightsPageTask>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
            initialTask != null ? 'Edit Insights Page' : 'Add Insights Page'),
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
                        controller: titleController, hint: "Enter title"),
                  )),
              const SizedBox(height: 16),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MarkdownTextField(
                        controller: descriptionController,
                        hint: "Enter description"),
                  )),
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

              if (title.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              Navigator.of(context).pop(
                ShowInsightsPageTask(
                  title: title,
                  description: description,
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
}
