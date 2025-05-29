import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/show_bottom_sheet.task.dart';

Future<ShowBottomSheetTask?> showBottomSheetDialog({
  required BuildContext context,
  ShowBottomSheetTask? initialTask,
}) async {
  final TextEditingController titleController = TextEditingController(
    text: initialTask?.title ?? '',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: initialTask?.description ?? '',
  );
  bool showImage = initialTask?.showImage ?? false;
  final TextEditingController primaryButtonTextController =
      TextEditingController(
    text: initialTask?.primaryButtonText ?? '',
  );
  final TextEditingController secondaryButtonTextController =
      TextEditingController(
    text: initialTask?.secondaryButtonText ?? '',
  );

  return showDialog<ShowBottomSheetTask>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(initialTask != null ? 'Edit Dialog' : 'Add Dialog'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter title',
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
                      hintText: 'Enter description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: showImage,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null) showImage = value;
                          });
                        },
                      ),
                      const Text('Show Image'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: primaryButtonTextController,
                    decoration: const InputDecoration(
                      labelText: 'Primary Button Text',
                      hintText: 'Enter text for primary button',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: secondaryButtonTextController,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Button Text (Optional)',
                      hintText: 'Enter text for secondary button',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final description = descriptionController.text.trim();
                          final primaryButtonText =
                              primaryButtonTextController.text.trim();
                          final secondaryButtonText =
                              secondaryButtonTextController.text.trim();

                          if (title.isEmpty ||
                              description.isEmpty ||
                              primaryButtonText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill in title, description, and primary button text')),
                            );
                            return;
                          }

                          Navigator.of(context).pop(
                            ShowBottomSheetTask(
                              title: title,
                              description: description,
                              showImage: showImage,
                              primaryButtonText: primaryButtonText,
                              secondaryButtonText:
                                  secondaryButtonText.isNotEmpty
                                      ? secondaryButtonText
                                      : null,
                            ),
                          );
                        },
                        child: Text(initialTask != null ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
