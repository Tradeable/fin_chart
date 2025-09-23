import 'package:example/editor/ui/widget/markdown_textfield.dart';
import 'package:fin_chart/fin_chart.dart';
import 'package:flutter/material.dart';

Future<ShowSideNavTask?> showSideNavDialog({
  required BuildContext context,
  ShowSideNavTask? initialTask,
}) async {
  final TextEditingController titleController =
      TextEditingController(text: initialTask?.title ?? '');
  final TextEditingController primaryDescriptionController =
      TextEditingController(text: initialTask?.primaryDescription ?? '');
  final TextEditingController secondaryDescriptionController =
      TextEditingController(text: initialTask?.secondaryDescription ?? '');
  final TextEditingController primaryBtnController =
      TextEditingController(text: initialTask?.primaryButtonText ?? '');
  final TextEditingController secondaryBtnController =
      TextEditingController(text: initialTask?.secondaryButtonText ?? '');

  return showDialog<ShowSideNavTask>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Side Nav'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: primaryBtnController,
                      decoration: const InputDecoration(
                        labelText: 'Primary Button Text',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.touch_app),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownTextField(
                        controller: primaryDescriptionController,
                        hint: "Primary Description"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secondary Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: secondaryBtnController,
                      decoration: const InputDecoration(
                        labelText: 'Secondary Button Text',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.touch_app),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownTextField(
                        controller: secondaryDescriptionController,
                        hint: "Primary Description"),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final primaryDesc = primaryDescriptionController.text.trim();
              final secondaryDesc = secondaryDescriptionController.text.trim();
              final primary = primaryBtnController.text.trim();
              final secondary = secondaryBtnController.text.trim();

              if (title.isEmpty || primaryDesc.isEmpty || primary.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              Navigator.of(context).pop(ShowSideNavTask(
                title: title,
                primaryButtonText: primary,
                secondaryButtonText: secondary.isNotEmpty ? secondary : '',
                primaryDescription: primaryDesc,
                secondaryDescription:
                    secondaryDesc.isNotEmpty ? secondaryDesc : '',
              ));
            },
            child: Text(initialTask != null ? 'Update' : 'Create'),
          ),
        ],
      );
    },
  );
}
