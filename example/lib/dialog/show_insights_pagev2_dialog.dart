import 'package:fin_chart/models/insights_v2/content_block.dart';
import 'package:fin_chart/models/insights_v2/image_block.dart';
import 'package:fin_chart/models/insights_v2/text_block.dart';
import 'package:fin_chart/models/insights_v2/video_block.dart';
import 'package:fin_chart/models/tasks/show_insights_v2.task.dart';
import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

Future<ShowInsightsPageV2Task?> showInsightsPageV2Dialog({
  required BuildContext context,
  ShowInsightsPageV2Task? initialTask,
}) {
  return showDialog<ShowInsightsPageV2Task>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: ShowInsightsPageV2Editor(initialTask: initialTask),
    ),
  );
}

class ShowInsightsPageV2Editor extends StatefulWidget {
  final ShowInsightsPageV2Task? initialTask;

  const ShowInsightsPageV2Editor({super.key, this.initialTask});

  @override
  State<ShowInsightsPageV2Editor> createState() =>
      _ShowInsightsPageV2EditorState();
}

class _ShowInsightsPageV2EditorState extends State<ShowInsightsPageV2Editor> {
  late TextEditingController titleController;
  late List<ContentBlock> contentBlocks;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.initialTask?.title ?? '');
    contentBlocks = List<ContentBlock>.from(widget.initialTask?.blocks ?? []);
    for (final block in contentBlocks) {
      _initControllersFor(block);
    }
  }

  void _initControllersFor(ContentBlock block) {
    if (block is TextBlock) {
      controllers['${block.id}_markdown'] =
          TextEditingController(text: block.markdown);
    } else if (block is ImageBlock) {
      controllers['${block.id}_url'] = TextEditingController(text: block.url);
      controllers['${block.id}_alt'] =
          TextEditingController(text: block.alt ?? '');
      controllers['${block.id}_height'] =
          TextEditingController(text: (block.height ?? 0).toString());
      controllers['${block.id}_width'] =
          TextEditingController(text: (block.width ?? 0).toString());
    } else if (block is VideoBlock) {
      controllers['${block.id}_url'] = TextEditingController(text: block.url);
    }
  }

  TextEditingController _ctrl(String key) =>
      controllers[key] ??= TextEditingController();

  void _add(ContentBlock block) {
    setState(() {
      contentBlocks.add(block);
      _initControllersFor(block);
    });
  }

  void _remove(ContentBlock block) {
    setState(() {
      contentBlocks.remove(block);
      if (block is TextBlock) {
        controllers.remove('${block.id}_markdown')?.dispose();
      } else if (block is ImageBlock) {
        controllers.remove('${block.id}_url')?.dispose();
        controllers.remove('${block.id}_alt')?.dispose();
      } else if (block is VideoBlock) {
        controllers.remove('${block.id}_url')?.dispose();
        controllers.remove('${block.id}_thumb')?.dispose();
        controllers.remove('${block.id}_dur')?.dispose();
      }
    });
  }

  ShowInsightsPageV2Task _buildResult() {
    final updatedBlocks = <ContentBlock>[];
    for (final block in contentBlocks) {
      if (block is TextBlock) {
        updatedBlocks.add(TextBlock(
          id: block.id,
          markdown: _ctrl('${block.id}_markdown').text,
        ));
      } else if (block is ImageBlock) {
        updatedBlocks.add(ImageBlock(
          id: block.id,
          url: _ctrl('${block.id}_url').text.trim(),
          alt: _ctrl('${block.id}_alt').text.trim().isEmpty
              ? null
              : _ctrl('${block.id}_alt').text.trim(),
          height: _ctrl('${block.id}_height').text.trim().isEmpty
              ? null
              : double.parse(_ctrl('${block.id}_height').text.trim()),
          width: _ctrl('${block.id}_width').text.trim().isEmpty
              ? null
              : double.parse(_ctrl('${block.id}_width').text.trim()),
        ));
      } else if (block is VideoBlock) {
        updatedBlocks.add(VideoBlock(
          id: block.id,
          url: _ctrl('${block.id}_url').text.trim(),
        ));
      }
    }
    return ShowInsightsPageV2Task(
      title: titleController.text.trim(),
      blocks: updatedBlocks,
      id: widget.initialTask?.id,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 720,
      height: 720,
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(widget.initialTask != null
                ? 'Edit Insights Page V2'
                : 'Add Insights Page V2'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(_buildResult()),
                child: Text(widget.initialTask != null ? 'Update' : 'Create'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: contentBlocks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = contentBlocks.removeAt(oldIndex);
                  contentBlocks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) => _blockCard(contentBlocks[i], i),
            ),
          ),
          _addBar(),
        ],
      ),
    );
  }

  Widget _blockCard(ContentBlock block, int index) {
    final key = ValueKey(block.id);
    final typeLabel = block is TextBlock
        ? 'Text'
        : block is ImageBlock
            ? 'Image'
            : 'Video';
    final typeIcon = block is TextBlock
        ? Icons.text_snippet
        : block is ImageBlock
            ? Icons.image
            : Icons.video_library;
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                    index: index, child: const Icon(Icons.drag_handle)),
                const SizedBox(width: 8),
                Chip(
                    avatar: Icon(typeIcon, size: 16),
                    label: Text('$typeLabel Block')),
                const Spacer(),
                IconButton(
                    onPressed: () => _remove(block),
                    icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            if (block is TextBlock)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownToolbar(
                    controller: _ctrl('${block.id}_markdown'),
                    useIncludedTextField: false,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl('${block.id}_markdown'),
                    minLines: 1,
                    maxLines: 10,
                    decoration: const InputDecoration(
                        hintText: 'Markdown', border: OutlineInputBorder()),
                  )
                ],
              )
            else if (block is ImageBlock)
              Column(
                children: [
                  TextField(
                    controller: _ctrl('${block.id}_url'),
                    decoration: const InputDecoration(
                        hintText: 'Image URL', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl('${block.id}_alt'),
                    decoration: const InputDecoration(
                        hintText: 'Alt text (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl('${block.id}_height'),
                    decoration: const InputDecoration(
                        hintText: 'Height (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl('${block.id}_width'),
                    decoration: const InputDecoration(
                        hintText: 'Width (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  if (_ctrl('${block.id}_url').text.isNotEmpty)
                    SizedBox(
                      height: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _ctrl('${block.id}_url').text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                ],
              )
            else if (block is VideoBlock)
              Column(
                children: [
                  TextField(
                    controller: _ctrl('${block.id}_url'),
                    decoration: const InputDecoration(
                        hintText: 'Video URL', border: OutlineInputBorder()),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _addBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(color: Colors.blueGrey, boxShadow: [
        BoxShadow(
            blurRadius: 8, color: Colors.black.withAlpha((0.05 * 255).round()))
      ]),
      child: Row(
        children: [
          const Text('Add block:', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 10),
          ElevatedButton.icon(
              onPressed: () => _add(TextBlock(markdown: '')),
              icon: const Icon(Icons.text_fields),
              label: const Text('Text')),
          const SizedBox(width: 8),
          ElevatedButton.icon(
              onPressed: () => _add(ImageBlock(url: '', alt: '')),
              icon: const Icon(Icons.image),
              label: const Text('Image')),
          const SizedBox(width: 8),
          ElevatedButton.icon(
              onPressed: () => _add(VideoBlock(url: '')),
              icon: const Icon(Icons.video_library),
              label: const Text('Video')),
        ],
      ),
    );
  }
}
