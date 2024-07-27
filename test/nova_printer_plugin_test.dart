// import 'package:flutter_test/flutter_test.dart';
// import 'package:nova_printer_plugin/plugin.dart';
// import 'package:nova_printer_plugin/src/method_channel/nova_printer_plugin_method_channel.dart';
// import 'package:nova_printer_plugin/src/method_channel/nova_printer_plugin_platform_interface.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockNovaPrinterPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements NovaPrinterPluginPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');

//   @override
//   Future onPrint({
//     required EpsonPrinterModel printer,
//     required List<Map<String, dynamic>> commands,
//   }) {
//     // TODO: implement onPrint
//     throw UnimplementedError();
//   }

//   @override
//   Future getPrinterSetting({required EpsonPrinterModel printer}) {
//     // TODO: implement getPrinterSetting
//     throw UnimplementedError();
//   }

//   @override
//   Future onDiscovery({required String printType}) {
//     // TODO: implement onDiscovery
//     throw UnimplementedError();
//   }

//   @override
//   Future setPrinterSetting(
//       {required EpsonPrinterModel printer,
//       String? paperWidth,
//       String? printDensity,
//       String? printSpeed}) {
//     // TODO: implement setPrinterSetting
//     throw UnimplementedError();
//   }
// }

// void main() {
//   final NovaPrinterPluginPlatform initialPlatform =
//       NovaPrinterPluginPlatform.instance;

//   test('$MethodChannelNovaPrinterPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelNovaPrinterPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     MockNovaPrinterPluginPlatform fakePlatform =
//         MockNovaPrinterPluginPlatform();
//     NovaPrinterPluginPlatform.instance = fakePlatform;

//     expect(await NovaPrinterPlugin.onDiscovery(), 'TCP');
//   });
// }
