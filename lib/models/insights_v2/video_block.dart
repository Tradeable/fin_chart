import 'package:fin_chart/models/insights_v2/content_block.dart';

class VideoBlock extends ContentBlock {
  final String url;

  VideoBlock({super.id, required this.url});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'video',
        'url': url,
      };

  factory VideoBlock.fromJson(Map<String, dynamic> json) => VideoBlock(
        id: json['id'],
        url: json['url'],
      );
}
