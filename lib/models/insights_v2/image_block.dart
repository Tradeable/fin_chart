import 'package:fin_chart/models/insights_v2/content_block.dart';

class ImageBlock extends ContentBlock {
  final String url;
  final String? alt;
  final double? height;
  final double? width;

  ImageBlock({super.id, required this.url, this.alt, this.height, this.width});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'image',
        'url': url,
        'alt': alt,
        'height': height,
        'width': width,
      };

  factory ImageBlock.fromJson(Map<String, dynamic> json) => ImageBlock(
      id: json['id'],
      url: json['url'],
      alt: json['alt'],
      height: json['height'].toDouble(),
      width: json['width'].toDouble());
}
