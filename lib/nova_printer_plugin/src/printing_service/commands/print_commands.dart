import 'package:nova_printer_plugin/plugin.dart';

abstract class PrintCommands {
  final PrintCommandId type;
  final PrintAttributes attributes;
  PrintCommands({
    required this.type,
    required this.attributes,
  });
  factory PrintCommands.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case PrintCommandId.PrintRawData:
        return PrintRawData.fromJson(json);
      case PrintCommandId.PrintText:
        return PrintTextCommand.fromJson(json);
      case PrintCommandId.AddImage:
        return PrintImage.fromJson(json);
      case PrintCommandId.AddFeedLine:
        return AddFeedlineCommand.fromJson(json);
      case PrintCommandId.AddCut:
        return AddCutCommand.fromJson(json);
      case PrintCommandId.AddTextSmooth:
        return AddTextSmoothCommand.fromJson(json);
      default:
        throw Exception("UNKNOWN COMMAND TYPE");
    }
  }

  Map<String, dynamic> toJson();
}

abstract class PrintAttributes {
  Map<String, dynamic> toJson();
}
