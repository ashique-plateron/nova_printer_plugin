import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'print_text.g.dart';

@JsonSerializable()
class PrintTextCommand extends PrintCommand2 {
  PrintTextCommand({
    required PrintTextAttributes attributes,
    PrintCommandId type = PrintCommandId.PrintText,
  }) : super(type: type, attributes: attributes);
  factory PrintTextCommand.fromJson(Map<String, dynamic> json) =>
      _$PrintTextCommandFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintTextCommandToJson(this);
}

@JsonSerializable()
class PrintTextAttributes extends PrintAttributes {
  final String text;
  final PrintAlign alignment;
  final PrintFont fontType;
  Map<String, int>? size;
  PrintTextStyle? style;
  final bool smoothenText;

  PrintTextAttributes({
    required this.text,
    this.size,
    this.style,
    this.alignment = PrintAlign.LEFT,
    this.fontType = PrintFont.FONT_A,
    this.smoothenText = true,
  }) {
    size ??= {'height': 1, 'width': 1};
    style ??= PrintTextStyle();
  }

  factory PrintTextAttributes.fromJson(Map<String, dynamic> json) =>
      _$PrintTextAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintTextAttributesToJson(this);
}

@JsonSerializable()
class PrintTextStyle {
  final bool reverse;
  final bool underline;
  @JsonKey(name: 'em')
  final bool bold;
  final PrintColor color;

  PrintTextStyle({
    this.reverse = false,
    this.underline = false,
    this.bold = false,
    this.color = PrintColor.COLOR_1,
  });
  factory PrintTextStyle.fromJson(Map<String, dynamic> json) =>
      _$PrintTextStyleFromJson(json);

  Map<String, dynamic> toJson() => _$PrintTextStyleToJson(this);
}

@JsonSerializable()
class PrintDividerAttribute extends PrintTextAttributes {
  String symbol;

  PrintDividerAttribute({
    this.symbol = '-',
    super.style,
    super.size,
    super.alignment = PrintAlign.CENTRE,
  }) : super(text: symbol);

  factory PrintDividerAttribute.fromJson(Map<String, dynamic> json) =>
      _$PrintDividerAttributeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintDividerAttributeToJson(this);
}

@JsonSerializable()
class RowWith2ColumnAttribute extends PrintTextAttributes {
  final String column2Text;

  RowWith2ColumnAttribute({
    required super.text,
    required this.column2Text,
  });

  factory RowWith2ColumnAttribute.fromJson(Map<String, dynamic> json) =>
      _$RowWith2ColumnAttributeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RowWith2ColumnAttributeToJson(this);
}
