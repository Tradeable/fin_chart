import 'package:flutter/material.dart';
import 'package:fin_chart/models/tasks/show_sidenav.task.dart';
import 'package:markdown_widget/markdown_widget.dart';

class SideNavPanel extends StatelessWidget {
  final List<ShowSideNavTask> tasks;
  final String? expandedId;
  final void Function(String? id) onExpandedChange;
  final Map<String, String?> selectedDescriptions;
  final void Function(String taskId, String? description) onDescriptionSelect;

  const SideNavPanel({
    super.key,
    required this.tasks,
    required this.expandedId,
    required this.onExpandedChange,
    required this.selectedDescriptions,
    required this.onDescriptionSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final String lastId = tasks.last.id;
    final String effectiveExpandedId = expandedId ?? lastId;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...tasks.map((t) {
          final bool isExpanded = effectiveExpandedId == t.id;
          final String? selectedDescription = selectedDescriptions[t.id];
          final Key tileKey =
              ValueKey("${t.id}_${isExpanded ? 'open' : 'closed'}");
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              key: tileKey,
              initiallyExpanded: isExpanded,
              title: Text(t.title),
              onExpansionChanged: (open) {
                if (open) {
                  onExpandedChange(t.id);
                } else {
                  if (effectiveExpandedId == t.id) {
                    onExpandedChange(lastId);
                  }
                }
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                onExpandedChange(t.id);
                                onDescriptionSelect(t.id, t.primaryDescription);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(t.primaryButtonText),
                            ),
                          ),
                          if (t.secondaryButtonText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  onExpandedChange(t.id);
                                  onDescriptionSelect(
                                      t.id, t.secondaryDescription);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                                child: Text(t.secondaryButtonText),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (selectedDescription != null) ...[
                        const SizedBox(height: 12),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: MarkdownWidget(
                                data: selectedDescription,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        })
      ],
    );
  }
}
