import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nova_printer_plugin/src/method_channel/nova_printer_plugin_platform_interface.dart';

import 'src/printing_service/helpers/epson_epos.dart';

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

  static Future<List<EpsonPrinterModel>> onDiscovery({
    EpsonEPOSPortType type = EpsonEPOSPortType.TCP,
  }) async {
    try {
      if (!_isPrinterPlatformSupport(throwError: true)) throw Exception();
      String printType = _eposHelper.getPortType(type);
      String? rawResponseData =
          await NovaPrinterPluginPlatform.instance.onDiscovery(
        printType: printType,
      );
      if (rawResponseData == null) throw Exception();
      final epsonPrinterResponse =
          EpsonPrinterResponse.fromRawJson(rawResponseData);
      if (kDebugMode) print(epsonPrinterResponse);

      List<dynamic> printers = epsonPrinterResponse.content ?? [];

      if (printers.isEmpty) throw Exception();

      List<EpsonPrinterModel> map = printers.map(
        (e) {
          final modelName = e['model'];
          final modelSeries = _eposHelper.getSeries(modelName);
          return EpsonPrinterModel(
            ipAddress: e['ipAddress'],
            bdAddress: e['bdAddress'],
            macAddress: e['macAddress'],
            type: printType,
            model: modelName,
            series: modelSeries?.id,
            target: e['target'],
          );
        },
      ).toList();
      return map;
    } catch (e) {
      return [];
    }
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
    required Map<String,dynamic> params,
  }) {
    return NovaPrinterPluginPlatform.instance.onCitizenPrint(params: params);
  }
}
