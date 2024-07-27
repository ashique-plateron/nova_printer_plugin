import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova_printer_plugin/plugin.dart';
import 'package:nova_printer_plugin_example/citizen_printer_model.dart';
import 'package:usb_serial_for_android/usb_serial_for_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Printer> printers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () async {
                    discoverPrinter();
                  },
                  child: const Text('DISCOVER'),
                ),
                const SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (context, index) {
                      Printer printer = printers[index];
                      return Row(
                        children: [
                          Text(printer.manufacturerName.name +
                              (" ${printer.properties['model'] ?? ''}")),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              printData(printer: printer);
                            },
                            child: const Text('Print'),
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> discoverPrinter() async {
    List<EpsonPrinterModel> epsonPrinters = [];
    epsonPrinters = await NovaPrinterPlugin.onDiscovery(
      type: EpsonEPOSPortType.USB,
    );
    printers.clear();

    for (EpsonPrinterModel element in epsonPrinters) {
      EpsonPrinterModel device = element;
      var json = device.toMap();
      json['properties'] = {};
      json['properties'].putIfAbsent('epson', () => device.toMap());
      var printer = Printer.fromJson(json);
      printers.add(printer);
    }
    await findCitizenDevice();
    setState(() {});
  }

  Future<void> printData({required Printer printer}) async {
    var imageData = await rootBundle.load('assets/test_print.jpg');
    var b = imageData.buffer.asUint8List();
    switch (printer.manufacturerName) {
      case ManufactureName.Epson:
        var epsonPrinter = EpsonPrinterModel.fromMap(
          Map.from(printer.properties),
        );
        await NovaPrinterPlugin.onPrint(
          printer: epsonPrinter,
          commands: printer.getCommands2(
            [
              // AddTextSmoothCommand(
              //   attributes: AddTextSmoothAttributes(
              //     addTextSmooth: true,
              //   ),
              // ),
              // PrintTextCommand(
              //   attributes: PrintTextAttributes(
              //     fontType: PrintFont.FONT_B,
              //     text:
              //         '''123456789012345678901231234567890123456789012312345678901234567890123123456789012345678901231234567890123456789012312345678901234567890123123456789012345678901231234567890123456789012312345678901234567890123''',
              //     style: PrintTextStyle(bold: false),
              //     size: {
              //       'width': 2,
              //       'height': 2,
              //     },
              //   ),
              // ),
              // PrintImage(
              //   attributes: PrintImageAttributes(
              //     // width: 500,
              //     // height: 400,
              //     // posX: 50,
              //     // posY: 50,
              //     bitmap: b,
              //   ),
              // ),
              // PrintTextCommand(
              //   type: PrintCommandId.AddDivider,
              //   attributes: PrintDividerAttribute(
              //     symbol: '-',
              //     style: PrintTextStyle(bold: false),
              //     size: {
              //       'width': 2,
              //       'height': 2,
              //     },
              //   ),
              // ),
              AddFeedlineCommand(
                attributes: FeedlineAttributes(lines: 10),
              ),
              // PrintRawData(
              //   attributes: PrintRawDataAttributes(
              //     rawData: Uint8List.fromList([0, 2, 5, 7]),
              //   ),
              // ),

              // AddCutCommand(),
            ],
          ),
        );
        break;
      case ManufactureName.Citizen:
        await NovaPrinterPlugin.onCitizenPrint(
          params: {
            "connectionType": 3,
            "address": null,
            // "commands": (printer as CitizenPrinter).getCitizenCommands([
            // CitizenTextCommands(
            //   text: "CITIZEN TEST PRINT",
            //   reverse: true,
            //   alignment: CitizenTextAlignment.CENTRE,
            //   width: CitizenConsts.CMP_TXT_2WIDTH,
            // ),
            // ])
          },
        );
        break;
      default:
    }
  }

  Future<void> findCitizenDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();

    for (var device in devices) {
      ManufactureName manufacturer =
          ManufactureName.fromValue(device.manufacturerName?.trim());
      bool isCitizenPrinter = manufacturer == ManufactureName.Citizen &&
          (device.productName?.toLowerCase().contains('printer') ?? false);

      if (isCitizenPrinter) {
        printers.add(
          CitizenPrinter(
            connectionMode: 'USB',
            displayName: device.manufacturerName,
            properties: {
              'deviceName': device.deviceName,
              'deviceId': device.deviceId,
              'productName': device.productName,
              'vid': device.vid,
              "pid": device.pid,
              "serial": device.serial,
              "port": device.port,
            },
          ),
        );
      }
    }
  }
}
