import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'citizen_printer.g.dart';

@JsonSerializable()
class CitizenPrinter extends Printer {
  CitizenPrinter({
    super.manufacturerName = ManufactureName.Citizen,
    super.displayName,
    super.connectionMode,
    super.properties = const {},
    super.refId,
    super.aliasName,
    super.createdDate,
    super.lastModifiedDate,
    super.foundMatch = true,
    super.restaurantRefId,
  });

  @override
  int get characterLength => 46;

  factory CitizenPrinter.fromJson(Map<String, dynamic> json) =>
      _$CitizenPrinterFromJson(json);

  @override
  Future<PrintResult> print(List<PrintCommands> commands) async {
    try {
      var printResult = await NovaPrinterPlugin.onCitizenPrint(
        printer: this,
        params: getCommands(commands),
      );
      return PrintResult.success;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() => _$CitizenPrinterToJson(this);
}
