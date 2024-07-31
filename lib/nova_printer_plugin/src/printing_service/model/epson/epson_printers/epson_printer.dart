import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/nova_printer_plugin/src/printing_service/queue/printer_queue.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'epson_printer.g.dart';

@JsonSerializable()
class EpsonPrinter extends Printer {
  @override
  int get characterLength => 42;
  EpsonPrinter({
    super.manufacturerName = ManufactureName.Epson,
    super.properties = const {},
    super.refId,
    super.displayName,
    super.aliasName,
    super.restaurantRefId,
    super.connectionMode,
    super.createdDate,
    super.lastModifiedDate,
    super.foundMatch = true,
  });

  factory EpsonPrinter.fromJson(Map<String, dynamic> json) {
    return _$EpsonPrinterFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$EpsonPrinterToJson(this);

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
