import 'package:flutter/material.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

class MarkdownTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const MarkdownTextField(
      {super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownToolbar(
          controller: controller,
          useIncludedTextField: false,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: 10,
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.sentences,
        )
      ],
    );
  }
}
