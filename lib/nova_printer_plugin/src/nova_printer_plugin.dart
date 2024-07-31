import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
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
    List<Printer> printers = [];
    final epsonPrinters = await onDiscoverEpsonPrinters(type: connectionModes);
    printers.addAll(epsonPrinters);
    if (connectionModes.contains(ConnectionMode.USB)) {
      final citizenPrinters = await findCitizenDevice();
      printers.addAll(citizenPrinters);
    }
    return printers;
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
            isUsbPrinter ? ConnectionMode.USB : ConnectionMode.TCP,
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

  static Future<List<Printer>> findCitizenDevice() async {
    List<Printer> printers = [];
    try {
      List<Map<String, dynamic>> discoveredUSBDevices =
          await FlutterUsbPrinter.getUSBDeviceList();

      for (var device in discoveredUSBDevices) {
        var json = device;
        bool isPrinter = (json['productName'] ?? '')
            .toString()
            .toLowerCase()
            .contains('printer');

        var manufacturerIsCitizen =
            ManufactureName.fromValue(json['manufacturer']) ==
                ManufactureName.Citizen;

        bool isCitizenPrinter = manufacturerIsCitizen && isPrinter;
        if (isCitizenPrinter) {
          json['manufacturerName'] = ManufactureName.Citizen.name;
          json['displayName'] = json['productName'];
          json['connectionMode'] = ConnectionMode.USB.value;
          json['properties'] = {
            'deviceName': device['deviceName'],
            'deviceId': device['deviceId'],
            'productName': device['productName'],
            'vid': device['vid'],
            "pid": device['pid'],
            "serial": device['serial'],
            "port": device['port'],
          };
          printers.add(Printer.fromJson(json));
        }
      }
      return printers;
    } on Exception {
      rethrow;
    }
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
