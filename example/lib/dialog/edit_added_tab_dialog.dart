import 'package:fin_chart/fin_chart.dart';
import 'package:flutter/material.dart';

Future<AddTabTask?> editTabDialog({
  required BuildContext context,
  required AddTabTask task,
}) async {
  final TextEditingController controller =
      TextEditingController(text: task.tabTitle);

  return showDialog<AddTabTask>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Tab Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Tab Title'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final updatedTitle = controller.text.trim();
                      if (updatedTitle.isEmpty) return;
                      Navigator.of(context).pop(AddTabTask(
                          taskId: task.taskId, tabTitle: updatedTitle));
                    },
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
