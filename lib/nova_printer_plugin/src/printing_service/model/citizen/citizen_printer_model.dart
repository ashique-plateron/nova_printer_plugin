import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/nova_printer_plugin/src/printing_service/queue/printer_queue.dart';
import 'package:nova_printer_plugin/plugin.dart';

part 'citizen_printer_model.g.dart';

@JsonSerializable()
class CitizenPrinter extends Printer {
  CitizenPrinter({
    super.manufacturerName = ManufactureName.Citizen,
    super.displayName,
    super.connectionMode,
    super.properties,
    super.refId,
    super.aliasName,
  });

  @override
  Future<PrintResult> print(List<PrintCommands> commands) async {
    try {
      PrinterQueue().addToQueue(() async {
        var printResult = await NovaPrinterPlugin.onCitizenPrint(
          printer: this,
          params: getCommands(commands),
        );
        if (printResult != null) {
          EpsonPrinterResponse r =
              EpsonPrinterResponse.fromRawJson(printResult);
          if (!r.success) return PrintResult.failed;
        }
      });
      return PrintResult.success;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() => _$CitizenPrinterToJson(this);

  @override
  int get characterLength => 33;
}
