import 'package:json_annotation/json_annotation.dart';
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
  Future<PrintResult> print(PrintCommands commands) {
    // TODO: implement print
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement characterLength
  int get characterLength => throw UnimplementedError();

  // List<Map<String, dynamic>> getCitizenCommands(
  //   List<CitizenCommands> commandList,
  // ) {
  //   List<Map<String, dynamic>> commands = [];

  //   for (var element in commandList) {
  //     switch (element.runtimeType) {
  //       case CitizenTextCommands:
  //         var c = (element as CitizenTextCommands);
  //         commands.add({
  //           'type': 'appendText',
  //           'text': c.text,

  //         });
  //         break;

  //       default:
  //         throw 'Invalid Attribute';
  //     }
  //   }

  //   return commands;
  // }
}
