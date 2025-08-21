import 'package:fin_chart/models/insights_v2/content_block.dart';

class ImageBlock extends ContentBlock {
  final String url;
  final String? alt;

  ImageBlock({super.id, required this.url, this.alt});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'image',
        'url': url,
        'alt': alt,
      };

  factory ImageBlock.fromJson(Map<String, dynamic> json) =>
      ImageBlock(id: json['id'], url: json['url'], alt: json['alt']);
}
