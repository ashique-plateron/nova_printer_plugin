import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nova_printer_plugin/plugin.dart';

import 'method_channel/nova_printer_plugin_platform_interface.dart';

class NovaPrinterPlugin {
  static final EpsonEPOSHelper _eposHelper = EpsonEPOSHelper();

  static bool _isPrinterPlatformSupport({bool throwError = false}) {
    if (Platform.isAndroid) return true;
    if (throwError) {
      throw PlatformException(
        code: "platformNotSupported",
        message: "Device not supported",
      );
    }
    return false;
  }

  static Future<List<Printer>> discoverPrinters({
    Set<ConnectionMode> connectionModes = const {
      ConnectionMode.TCP,
      ConnectionMode.USB,
    },
  }) async {
    final epsonPrinters = await onDiscoverEpsonPrinters(type: connectionModes);
    //HERE WE NEED TO ADD DISCOVERY OF CITIZEN PRINTERS AS WELL

    return [...epsonPrinters];
  }

  static Future<List<Printer>> onDiscoverEpsonPrinters({
    Set<ConnectionMode> type = const {
      ConnectionMode.TCP,
      ConnectionMode.USB,
    },
  }) async {
    try {
      if (!_isPrinterPlatformSupport(throwError: true)) throw Exception();
      List<dynamic> printersFound = [];
      for (var connectionType in type) {
        String tcp = _eposHelper.getPortType(connectionType);
        EpsonPrinterResponse epsonPrinterResponse =
            await _discoverPrintersByType(tcp);
        printersFound.addAll(epsonPrinterResponse.content);
      }
      if (printersFound.isEmpty) throw Exception();
      List<EpsonPrinterModel> map = printersFound.map(
        (e) {
          final modelName = e['model'];
          final modelSeries = _eposHelper.getSeries(modelName);
          String ipAddress = e['ipAddress'] ?? '';
          bool isUsbPrinter = ipAddress.isEmpty;
          String connectionType = _eposHelper.getPortType(
            isUsbPrinter ? ConnectionMode.TCP : ConnectionMode.USB,
          );

          return EpsonPrinterModel(
            ipAddress: e['ipAddress'],
            bdAddress: e['bdAddress'],
            macAddress: e['macAddress'],
            type: connectionType,
            model: modelName,
            series: modelSeries?.id,
            target: e['target'],
          );
        },
      ).toList();

      List<Printer> printers = [];
      for (EpsonPrinterModel element in map) {
        EpsonPrinterModel device = element;
        var json = device.toMap();
        json['manufacturerName'] = ManufactureName.Epson.name;
        json['connectionMode'] = json['type'];
        json['displayName'] = json['model'];
        json['properties'] = {};
        json['properties'] = {...json};

        var printer = Printer.fromJson(json);
        printers.add(printer);
      }
      return printers;
    } catch (e) {
      return [];
    }
  }

  static Future<EpsonPrinterResponse> _discoverPrintersByType(
    String printType,
  ) async {
    String? rawResponseData =
        await NovaPrinterPluginPlatform.instance.onDiscovery(
      printType: printType,
    );
    if (rawResponseData == null) throw Exception();
    final epsonPrinterResponse =
        EpsonPrinterResponse.fromRawJson(rawResponseData);
    if (kDebugMode) print(epsonPrinterResponse);
    return epsonPrinterResponse;
  }

  static Future<dynamic> onPrint({
    required EpsonPrinterModel printer,
    required List<Map<String, dynamic>> commands,
  }) {
    return NovaPrinterPluginPlatform.instance.onPrint(
      printer: printer,
      commands: commands,
    );
  }

  Future<dynamic> getPrinterSetting({
    required EpsonPrinterModel printer,
  }) {
    return NovaPrinterPluginPlatform.instance.getPrinterSetting(
      printer: printer,
    );
  }

  Future<dynamic> setPrinterSetting({
    required EpsonPrinterModel printer,
    String? paperWidth,
    String? printDensity,
    String? printSpeed,
  }) {
    return NovaPrinterPluginPlatform.instance.setPrinterSetting(
      printer: printer,
      paperWidth: paperWidth,
      printDensity: printDensity,
      printSpeed: printSpeed,
    );
  }

  static Future<dynamic> onCitizenPrint({
    required CitizenPrinter printer,
    required List<Map<String, dynamic>> params,
  }) {
    return NovaPrinterPluginPlatform.instance.onCitizenPrint(
      commands: params,
      printer: printer,
    );
  }
}
