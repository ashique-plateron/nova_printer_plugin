import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'print_image.g.dart';

@JsonSerializable()
class PrintImage extends PrintCommands {
  PrintImage({
    required PrintImageAttributes attributes,
    PrintCommandId type = PrintCommandId.AddImage,
  }) : super(
          type: type,
          attributes: attributes,
        );
  factory PrintImage.fromJson(Map<String, dynamic> json) =>
      _$PrintImageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintImageToJson(this);
}

@JsonSerializable()
class PrintImageAttributes extends PrintAttributes {
  final List<int> bitmap;
  final int? posX;
  final int? posY;
  final int? height;
  final int? width;
  final ImageColorMode? mode;
  final ImageHalfTone? halftone;
  final double brightness;
  final int? compress;

  PrintImageAttributes({
    required this.bitmap,
    this.brightness = 1.0,
    this.compress,
    this.width,
    this.height,
    this.posX,
    this.posY,
    this.mode,
    this.halftone,
  });
  factory PrintImageAttributes.fromJson(Map<String, dynamic> json) =>
      _$PrintImageAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintImageAttributesToJson(this);
}
