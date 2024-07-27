import 'package:nova_printer_plugin/src/printing_service/model/epson/commands/misc/misc_commands.dart';
import 'package:nova_printer_plugin/src/printing_service/model/epson/commands/print_image_commands/print_image.dart';
import 'package:nova_printer_plugin/src/printing_service/model/epson/commands/print_raw_data_commands/print_rawdata.dart';
import 'package:nova_printer_plugin/src/printing_service/model/epson/commands/print_text_commands/print_text.dart';

import 'enum/print_command_enums.dart';

abstract class PrintCommand2 {
  final PrintCommandId type;
  final PrintAttributes attributes;
  PrintCommand2({
    required this.type,
    required this.attributes,
  });
  factory PrintCommand2.fromJson(Map<String, dynamic> json) {
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
