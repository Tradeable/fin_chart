import 'package:fin_chart/models/insights_v2/content_block.dart';

class TextBlock extends ContentBlock {
  final String markdown;

  TextBlock({super.id, required this.markdown});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'text',
        'markdown': markdown,
      };

  factory TextBlock.fromJson(Map<String, dynamic> json) =>
      TextBlock(id: json['id'], markdown: json['markdown']);
}
