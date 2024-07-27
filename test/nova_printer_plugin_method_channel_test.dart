import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_printer_plugin/src/method_channel/nova_printer_plugin_method_channel.dart';

void main() {
  MethodChannelNovaPrinterPlugin platform = MethodChannelNovaPrinterPlugin();
  const MethodChannel channel = MethodChannel('nova_printer_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {});
}
