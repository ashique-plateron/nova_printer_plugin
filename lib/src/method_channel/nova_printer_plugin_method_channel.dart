import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nova_printer_plugin/src/printing_service/helpers/epson_epos.dart';

import 'nova_printer_plugin_platform_interface.dart';

/// An implementation of [NovaPrinterPluginPlatform] that uses method channels.
class MethodChannelNovaPrinterPlugin extends NovaPrinterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nova_printer_plugin');

  @override
  Future onDiscovery({required String printType}) async {
    final result =
        await methodChannel.invokeMethod('onDiscovery', {'type': printType});
    return result;
  }

  @override
  Future<dynamic> onPrint({
    required EpsonPrinterModel printer,
    required List<Map<String, dynamic>> commands,
  }) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "commands": commands,
      "target": printer.target
    };
    final result = await methodChannel.invokeMethod('onPrint', params);
    return result;
  }

  @override
  Future setPrinterSetting({
    required EpsonPrinterModel printer,
    String? paperWidth,
    String? printDensity,
    String? printSpeed,
  }) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "target": printer.target,
      "paper_width": paperWidth,
      "print_density": printDensity,
      "print_speed": printSpeed,
    };
    final result =
        await methodChannel.invokeMethod('setPrinterSetting', params);
    return result;
  }

  @override
  Future<dynamic> getPrinterSetting({
    required EpsonPrinterModel printer,
  }) async {
    final Map<String, dynamic> params = {
      "type": printer.type,
      "series": printer.series,
      "target": printer.target
    };
    final result =
        await methodChannel.invokeMethod('getPrinterSetting', params);
    return result;
  }

  @override
  Future onCitizenPrint({
    required Map<String, dynamic> params,
  }) async {
    final result = await methodChannel.invokeMethod(
      'onCitizenPrint',
      params,
    );
    return result;
  }
}
