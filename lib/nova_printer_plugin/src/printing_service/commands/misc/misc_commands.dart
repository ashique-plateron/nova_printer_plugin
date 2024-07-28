import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'misc_commands.g.dart';

@JsonSerializable()
class AddFeedlineCommand extends PrintCommands {
  AddFeedlineCommand({
    FeedlineAttributes? attributes,
    PrintCommandId type = PrintCommandId.AddFeedLine,
  }) : super(
          type: type,
          attributes: attributes ?? FeedlineAttributes(),
        );
  factory AddFeedlineCommand.fromJson(Map<String, dynamic> json) =>
      _$AddFeedlineCommandFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddFeedlineCommandToJson(this);
}

@JsonSerializable()
class FeedlineAttributes extends PrintAttributes {
  final int lines;

  FeedlineAttributes({
    this.lines = 1,
  });
  factory FeedlineAttributes.fromJson(Map<String, dynamic> json) =>
      _$FeedlineAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FeedlineAttributesToJson(this);
}

@JsonSerializable()
class AddCutCommand extends PrintCommands {
  AddCutCommand({
    AddCutAttributes? attributes,
    type = PrintCommandId.AddCut,
  }) : super(
          type: type,
          attributes: attributes ?? AddCutAttributes(),
        );
  factory AddCutCommand.fromJson(Map<String, dynamic> json) =>
      _$AddCutCommandFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddCutCommandToJson(this);
}

@JsonSerializable()
class AddCutAttributes extends PrintAttributes {
  final PrintAddCutType? cutType;

  AddCutAttributes({
    this.cutType = PrintAddCutType.CUT_FEED,
  });
  factory AddCutAttributes.fromJson(Map<String, dynamic> json) =>
      _$AddCutAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddCutAttributesToJson(this);
}

@JsonSerializable()
class AddTextSmoothCommand extends PrintCommands {
  AddTextSmoothCommand({
    AddTextSmoothAttributes? attributes,
    type = PrintCommandId.AddTextSmooth,
  }) : super(
          type: type,
          attributes: attributes ?? AddTextSmoothAttributes(),
        );
  factory AddTextSmoothCommand.fromJson(Map<String, dynamic> json) =>
      _$AddTextSmoothCommandFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddTextSmoothCommandToJson(this);
}

@JsonSerializable()
class AddTextSmoothAttributes extends PrintAttributes {
  final bool addTextSmooth;

  AddTextSmoothAttributes({
    this.addTextSmooth = false,
  });
  factory AddTextSmoothAttributes.fromJson(Map<String, dynamic> json) =>
      _$AddTextSmoothAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddTextSmoothAttributesToJson(this);
}
