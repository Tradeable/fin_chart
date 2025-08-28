import 'package:fin_chart/models/insights_v2/image_block.dart';
import 'package:fin_chart/models/insights_v2/text_block.dart';
import 'package:fin_chart/models/insights_v2/video_block.dart';
import 'package:fin_chart/utils/calculations.dart';

abstract class ContentBlock {
  final String id;

  ContentBlock({String? id}) : id = id ?? generateV4();

  Map<String, dynamic> toJson();

  static ContentBlock fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return TextBlock.fromJson(json);
      case 'image':
        return ImageBlock.fromJson(json);
      case 'video':
        return VideoBlock.fromJson(json);
      default:
        throw Exception('Unknown block type: ${json['type']}');
    }
  }
}
