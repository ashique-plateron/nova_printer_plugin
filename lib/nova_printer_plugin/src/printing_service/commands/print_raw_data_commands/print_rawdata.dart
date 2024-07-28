import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'print_rawdata.g.dart';

@JsonSerializable()
class PrintRawData extends PrintCommands {
  PrintRawData({
    required PrintRawDataAttributes attributes,
    PrintCommandId type = PrintCommandId.PrintRawData,
  }) : super(
          type: type,
          attributes: attributes,
        );
  factory PrintRawData.fromJson(Map<String, dynamic> json) =>
      _$PrintRawDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintRawDataToJson(this);
}

@JsonSerializable()
class PrintRawDataAttributes extends PrintAttributes {
  @JsonKey(fromJson: uint8ListFromJson, toJson: uint8ListToJson)
  final Uint8List? rawData;

  PrintRawDataAttributes({required this.rawData});
  factory PrintRawDataAttributes.fromJson(Map<String, dynamic> json) =>
      _$PrintRawDataAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintRawDataAttributesToJson(this);

  static Uint8List? uint8ListFromJson(dynamic data) {
    if (data is! List<int>) return null;
    Uint8List.fromList(data);
    return null;
  }

  static List<int>? uint8ListToJson(Uint8List? object) {
    if (object == null) return null;
    return object.toList();
  }
}
