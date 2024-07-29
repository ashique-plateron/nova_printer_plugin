import 'package:nova_printer_plugin/plugin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nova_printer_plugin_method_channel.dart';

abstract class NovaPrinterPluginPlatform extends PlatformInterface {
  /// Constructs a NovaPrinterPluginPlatform.
  NovaPrinterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NovaPrinterPluginPlatform _instance = MethodChannelNovaPrinterPlugin();

  /// The default instance of [NovaPrinterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNovaPrinterPlugin].
  static NovaPrinterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NovaPrinterPluginPlatform] when
  /// they register themselves.
  static set instance(NovaPrinterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<dynamic> onDiscovery({required String printType});
  
  Future<dynamic> onPrint({
    required EpsonPrinterModel printer,
    required List<Map<String, dynamic>> commands,
  });

  Future<dynamic> getPrinterSetting({
    required EpsonPrinterModel printer,
  });

  Future<dynamic> setPrinterSetting({
    required EpsonPrinterModel printer,
    String? paperWidth,
    String? printDensity,
    String? printSpeed,
  });

  Future<dynamic> onCitizenPrint({
    required CitizenPrinter printer,
    required List<Map<String, dynamic>> commands,
  });
}
