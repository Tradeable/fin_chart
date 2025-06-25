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
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter insights page title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter insights page description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
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
