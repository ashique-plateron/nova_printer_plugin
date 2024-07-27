import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'print_qr_command.g.dart';

@JsonSerializable()
class PrintQRCommand extends PrintCommand2 {
  PrintQRCommand({
    required PrintQRAttributes attributes,
    PrintCommandId type = PrintCommandId.PrintQRCode,
  }) : super(
          type: type,
          attributes: attributes,
        );
  factory PrintQRCommand.fromJson(Map<String, dynamic> json) =>
      _$PrintQRCommandFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintQRCommandToJson(this);
}

@JsonSerializable()
class PrintQRAttributes extends PrintAttributes {
  final String data;
  final int size;
  final QRCorrectionLevel correctionLevel;
  final PrintAlign alignment;

  PrintQRAttributes({
    required this.data,
    this.size = 3,
    this.correctionLevel = QRCorrectionLevel.LOW,
    this.alignment = PrintAlign.LEFT,
  });

  factory PrintQRAttributes.fromJson(Map<String, dynamic> json) =>
      _$PrintQRAttributesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PrintQRAttributesToJson(this);
}
