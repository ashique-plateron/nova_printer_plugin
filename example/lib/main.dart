import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova_printer_plugin/plugin.dart';

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
                          Text(
                              (" ${printer.manufacturerName.name} ${printer.properties['series']}")),
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
    printers = await NovaPrinterPlugin.discoverPrinters();
    // await findCitizenDevice();

    setState(() {});
  }

  Future<void> printData({required Printer printer}) async {
    var imageData = await rootBundle.load('assets/test_print.jpg');
    var b = imageData.buffer.asUint8List();
    await printer.print(getCommands());
  }

  List<PrintCommands> getCommands() {
    return TestCmdGenerator().commands;
  }
}

class TestCmdGenerator extends PrintCommandGenerator {
  List<PrintCommands> get commands => [
        // PrintImage(
        //   attributes: PrintImageAttributes(
        //     width: 500,
        //     height: 400,
        //     posX: 50,
        //     posY: 50,
        //     bitmap: b,
        //     halftone: ImageHalfTone.HALFTONE_ERROR_DIFFUSION,
        //   ),
        // ),
        // AddTextSmoothCommand(
        //   attributes: AddTextSmoothAttributes(
        //     addTextSmooth: true,
        //   ),
        // ),

        // getTextCommand(
        //   '''12345678901234567890123456789012345678901234567890''',
        //   size: textSizeSmall,
        // ),
        // getTextCommand(
        //   '''12345678901234567890123456789012345678901234567890''',
        //   size: textSizeMedium,
        // ),
        // getTextCommand(
        //   '''12345678901234567890123456789012345678901234567890''',
        //   size: textSizeLarge,
        // ),
        PrintTextCommand(
          attributes: PrintTextAttributes(
            fontType: PrintFont.FONT_B,
            text:
                '''123456789012345678901231234567890123456789012312345678901234567890123123456789012345678901231234567890123456789012312345678901234567890123123456789012345678901231234567890123456789012312345678901234567890123''',
            style: PrintTextStyle(bold: false),
          ),
        ),
        // getDividerCommand(),

        AddFeedlineCommand(
          attributes: FeedlineAttributes(lines: 5),
        ),
        // PrintRawData(
        //   attributes: PrintRawDataAttributes(
        //     rawData: Uint8List.fromList([0, 2, 5, 7]),
        //   ),
        // ),
        // PrintQRCommand(
        //   attributes: PrintQRAttributes(
        //     data: "https://www.google.com/",
        //     size: 16,
        //     alignment: PrintAlign.CENTRE,
        //   ),
        // ),

        getRowWithTwoColumnCommand(
          "Menu Name",
          "QTY",
          size: textSizeSmall,
        ),

        AddCutCommand(),
      ];
}
