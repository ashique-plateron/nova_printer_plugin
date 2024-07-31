import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/nova_printer_plugin/src/printing_service/queue/printer_queue.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'epson_impact_printer.g.dart';

@JsonSerializable()
class EpsonImpactPrinter extends Printer {
  @JsonKey(includeFromJson: false)
  @override
  int get characterLength => 33;

  EpsonImpactPrinter({
    super.manufacturerName = ManufactureName.Epson,
    super.refId,
    super.displayName,
    super.aliasName,
    super.restaurantRefId,
    super.connectionMode,
    super.createdDate,
    super.lastModifiedDate,
    super.foundMatch = true,
    super.properties = const {},
  });

  factory EpsonImpactPrinter.fromJson(Map<String, dynamic> json) {
    return _$EpsonImpactPrinterFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$EpsonImpactPrinterToJson(this);

  @override
  Future<PrintResult> print(List<PrintCommands> commands) async {
    var printer = EpsonPrinterModel.fromMap(Map.from(properties));
    try {
      PrinterQueue().addToQueue(
        () async {
          var printResult = await NovaPrinterPlugin.onPrint(
            printer: printer,
            commands: getCommands(commands),
          );
          if (printResult != null) {
            PrinterResponse r = PrinterResponse.fromRawJson(printResult);
            return r.success ? PrintResult.success : PrintResult.failed;
          }
        },
      );
      return PrintResult.inQueue;
    } catch (e) {
      rethrow;
    }
  }
}
