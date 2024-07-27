// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'print_commands.g.dart';

class PrintCommands {
  List<PrintCommand> commandList;

  PrintCommands(
    this.commandList,
  );
}

enum PrintCommandType {
  text,
  textStyle,
  feedLine,
  textSize,
  textAlign,
  cut,
  printRawData,
  rowWithTwoColumns,
  divider
}

@JsonSerializable()
class PrintCommand {
  PrintCommandType type;
  @JsonKey(toJson: attributesToJson, fromJson: attributesFromJson)
  PrintCommandAttributes attributes;

  PrintCommand(this.type, this.attributes);

  factory PrintCommand.fromJson(Map<String, dynamic> json) =>
      _$PrintCommandFromJson(json);

  Map<String, dynamic> toJson() => _$PrintCommandToJson(this);

  static PrintCommandAttributes attributesFromJson(Map<String, dynamic> json) {
    if (json.keys.contains('text')) {
      return TextAttribute.fromJson(json);
    } else if (json.keys.contains('bold')) {
      return TextStyleAttribute.fromJson(json);
    } else if (json.keys.contains('noOfLine')) {
      return FeedLineAttribute.fromJson(json);
    } else if (json.keys.contains('height')) {
      return TextSizeAttribute.fromJson(json);
    } else if (json.keys.contains('align')) {
      return TextAlignAttribute.fromJson(json);
    } else if (json.keys.contains('cut')) {
      return CutAttribute.fromJson(json);
    } else if (json.keys.contains('printRawData')) {
      return RawAttribute.fromJson(json);
    } else if (json.keys.contains('column1Text')) {
      return RowWithTwoColumnAttribute.fromJson(json);
    } else if (json.keys.contains('symbol')) {
      return DividerAttribute.fromJson(json);
    } else {
      throw 'Invalid Attributes';
    }
  }

  static Map<String, dynamic> attributesToJson(
      PrintCommandAttributes exercises) {
    switch (exercises.runtimeType) {
      case TextAttribute:
        return (exercises as TextAttribute).toJson();
      case TextStyleAttribute:
        return (exercises as TextStyleAttribute).toJson();
      case FeedLineAttribute:
        return (exercises as FeedLineAttribute).toJson();
      case TextSizeAttribute:
        return (exercises as TextSizeAttribute).toJson();
      case TextAlignAttribute:
        return (exercises as TextAlignAttribute).toJson();
      case CutAttribute:
        return (exercises as CutAttribute).toJson();
      case RawAttribute:
        return (exercises as RawAttribute).toJson();
      case RowWithTwoColumnAttribute:
        return (exercises as RowWithTwoColumnAttribute).toJson();
      case DividerAttribute:
        return (exercises as DividerAttribute).toJson();
      default:
        throw 'Invalid Attribute';
    }
  }
}

@JsonSerializable()
class TextAttribute extends PrintCommandAttributes {
  String text;

  TextAttribute(this.text);

  factory TextAttribute.fromJson(Map<String, dynamic> json) =>
      _$TextAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$TextAttributeToJson(this);
}

@JsonSerializable()
class TextStyleAttribute extends PrintCommandAttributes {
  bool bold;
  bool reverse;
  bool underline;
  EpsonEPOSColor color;

  TextStyleAttribute(this.bold, this.reverse, this.underline, this.color);

  factory TextStyleAttribute.fromJson(Map<String, dynamic> json) =>
      _$TextStyleAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$TextStyleAttributeToJson(this);
}

@JsonSerializable()
class RowWithTwoColumnAttribute extends PrintCommandAttributes {
  String column1Text;
  String column2Text;

  RowWithTwoColumnAttribute(this.column1Text, this.column2Text);

  factory RowWithTwoColumnAttribute.fromJson(Map<String, dynamic> json) =>
      _$RowWithTwoColumnAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$RowWithTwoColumnAttributeToJson(this);
}

@JsonSerializable()
class DividerAttribute extends PrintCommandAttributes {
  String symbol;

  DividerAttribute({this.symbol = '-'});

  factory DividerAttribute.fromJson(Map<String, dynamic> json) =>
      _$DividerAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$DividerAttributeToJson(this);
}

@JsonSerializable()
class FeedLineAttribute extends PrintCommandAttributes {
  int noOfLine;

  FeedLineAttribute(this.noOfLine);

  factory FeedLineAttribute.fromJson(Map<String, dynamic> json) =>
      _$FeedLineAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$FeedLineAttributeToJson(this);
}

@JsonSerializable()
class TextSizeAttribute extends PrintCommandAttributes {
  int height;
  int width;

  TextSizeAttribute(this.height, this.width);

  factory TextSizeAttribute.fromJson(Map<String, dynamic> json) =>
      _$TextSizeAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$TextSizeAttributeToJson(this);
}

@JsonSerializable()
class TextAlignAttribute extends PrintCommandAttributes {
  EpsonEPOSTextAlign align;

  TextAlignAttribute(this.align);

  factory TextAlignAttribute.fromJson(Map<String, dynamic> json) =>
      _$TextAlignAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$TextAlignAttributeToJson(this);
}

@JsonSerializable()
class CutAttribute extends PrintCommandAttributes {
  EpsonEPOSCut cut;

  CutAttribute(this.cut);

  factory CutAttribute.fromJson(Map<String, dynamic> json) =>
      _$CutAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$CutAttributeToJson(this);
}

@JsonSerializable()
class RawAttribute extends PrintCommandAttributes {
  List<int> rawData;

  RawAttribute(this.rawData);

  factory RawAttribute.fromJson(Map<String, dynamic> json) =>
      _$RawAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$RawAttributeToJson(this);
}
