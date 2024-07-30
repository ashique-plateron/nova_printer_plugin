// ignore_for_file: must_be_immutable

import 'package:nova_printer_plugin/plugin.dart';

import 'epson/epson_impact_printer/epson_impact_printer.dart';

abstract class Printer {
  String? refId;
  String? displayName;
  bool? foundMatch;
  String? restaurantRefId;
  String? connectionMode;
  Map<String, dynamic> properties;
  DateTime? createdDate;
  DateTime? lastModifiedDate;
  String? aliasName;
  ManufactureName manufacturerName;

  Printer({
    required this.manufacturerName,
    this.refId,
    this.displayName,
    this.aliasName,
    this.restaurantRefId,
    this.connectionMode,
    this.properties = const {},
    this.createdDate,
    this.lastModifiedDate,
    this.foundMatch = true,
  });

  int get characterLength;

  Future<PrintResult> print(List<PrintCommands> commands);

  Map<String, dynamic> toJson();

  factory Printer.fromJson(Map<String, dynamic> json) {
    switch (ManufactureName.fromValue(json['manufacturerName'])) {
      case ManufactureName.Epson:
        String model = json['model'].toString();
        bool isImpactPrinter = model.contains('TM-U220');
        if (isImpactPrinter) return EpsonImpactPrinter.fromJson(json);
        return EpsonPrinter.fromJson(json);
      case ManufactureName.Citizen:
        return CitizenPrinter.fromJson(json);
      case ManufactureName.None:
        throw Exception('Unknown Printer');
    }
  }

  bool get isEpsonPrinter => manufacturerName == ManufactureName.Epson;
  bool get isCitizenPrinter => manufacturerName == ManufactureName.Citizen;

  List<Map<String, dynamic>> getCommands(List<PrintCommands> commandList) {
    List<Map<String, dynamic>> commands = [];
    for (var element in commandList) {
      switch (element.type) {
        case PrintCommandId.PrintText:
          commands.add(getTextCommand(element));
          break;
        case PrintCommandId.AddDivider:
          commands.add(getDividerCommand(element));
          break;
        case PrintCommandId.AddFeedLine:
          commands.add(getFeedLineCommand(element));
          break;
        case PrintCommandId.AddCut:
          commands.add(getCutCommand(element));
          break;
        case PrintCommandId.PrintRawData:
          commands.add(addRawData(element));
          break;
        case PrintCommandId.AddImage:
          commands.add(getAddImageCommand(element));
          break;
        case PrintCommandId.AddTextSmooth:
          commands.add(getAddTextSmoothCommand(element));
          break;
        case PrintCommandId.PrintQRCode:
          commands.add(getPrintQrCommand(element));
          break;
        case PrintCommandId.PrintRowWithColumn:
          commands.add(getRowWith2ColumnCommand(element));
          break;
      }
    }
    return commands;
  }

  //! DONE
  Map<String, dynamic> getTextCommand(PrintCommands element) {
    var attribute = element.attributes as PrintTextAttributes;
    var formattedText = attribute.text.wrapText(characterLength).join('\n');
    var attributeJson = element.attributes.toJson()..['text'] = formattedText;
    var command = element.toJson()..['attributes'] = attributeJson;
    return command;
  }

  //! DONE
  Map<String, dynamic> getDividerCommand(PrintCommands element) {
    var attribute = element.attributes as PrintDividerAttribute;
    var formattedText = '${attribute.symbol * (characterLength - 1)}\n';
    var attributeJson = element.attributes.toJson()..['text'] = formattedText;
    var command = element.toJson()
      ..['type'] = 'printText'
      ..['attributes'] = attributeJson;
    return command;
  }

  //!DONE
  Map<String, dynamic> getFeedLineCommand(PrintCommands element) {
    return element.toJson();
  }

  //!DONE
  Map<String, dynamic> getCutCommand(PrintCommands element) {
    return element.toJson();
  }

  //!DONE
  Map<String, dynamic> addRawData(PrintCommands element) {
    return element.toJson();
  }

  //!DONE
  Map<String, dynamic> getAddTextSmoothCommand(PrintCommands element) {
    return element.toJson();
  }

  //!DONE
  Map<String, dynamic> getAddImageCommand(PrintCommands element) {
    return element.toJson();
  }

  //!DONE
  Map<String, dynamic> getRowWith2ColumnCommand(PrintCommands element) {
    var attribute = element.attributes as RowWith2ColumnAttribute;
    var formattedText = formatColumns(attribute.text, attribute.column2Text);
    var attributeJson = element.attributes.toJson()..['text'] = formattedText;
    var command = element.toJson()
      ..['type'] = 'printText'
      ..['attributes'] = attributeJson;
    return command;
  }

  //!DONE
  Map<String, dynamic> getPrintQrCommand(PrintCommands element) {
    return element.toJson();
  }

  String formatColumns(String col1Text, String col2Text) {
    var col1Width = characterLength - 5;
    var col2Width = 5;
    List<String> col1Lines = col1Text.wrapText(col1Width);
    List<String> col2Lines = col2Text.wrapText(col2Width);

    int maxLines = (col1Lines.length > col2Lines.length)
        ? col1Lines.length
        : col2Lines.length;
    while (col1Lines.length < maxLines) {
      col1Lines.add('');
    }
    while (col2Lines.length < maxLines) {
      col2Lines.add('');
    }

    String formattedOutput = '';
    for (int i = 0; i < maxLines; i++) {
      String col1Line = col1Lines[i].padRight(col1Width);
      String col2Line = col2Lines[i].padLeft(col2Width, ' ');
      String r = col1Line + col2Line;
      formattedOutput += '$r\n';
    }

    return formattedOutput;
  }
}
