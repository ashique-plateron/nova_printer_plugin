// ignore_for_file: constant_identifier_names

const int kDefaultOrderBillCopies = 1;

enum PrintFormat {
  graphicsESC('ESC *'),
  graphicsGSV('GS V 0'),
  graphicsGSL('GS L '),
  unknown(null);

  final String? value;
  const PrintFormat(this.value);

  static PrintFormat fromString(
    String? value,
  ) =>
      PrintFormat.values.firstWhere(
        (element) => element.value == value,
      );
}

enum ConnectionMode {
  USB("USB"),
  TCP("TCP"),
  BLUETOOTH("BLUETOOTH"),
  UNKNOWN(null);

  final String? value;
  const ConnectionMode(this.value);

  static ConnectionMode fromString(
    String? value,
  ) =>
      ConnectionMode.values.firstWhere(
        (element) => element.value == value,
        orElse: () => TCP,
      );
}

enum PrintResult {
  inQueue('InQueue : Print in queue'),
  success('Success : Print completed'),
  failed('Error : Failed to complete print');

  final String value;
  const PrintResult(this.value);
}

enum PrinterStatus {
  failedToConnect('Error: Failed to connect to the printer'),
  printerConnected('Success: Printer is Connected'),
  printerDisconnected('Success: Printer is diconnected'),
  scanInProgress('Error: Printer scanning in progress'),
  printInProgress('Error: Another print in progress'),
  timeout('Error: Printer connection timeout'),
  ticketEmpty('Error: Ticket is empty'),
  unknownError('Error: There is some issue with the printer');

  final String value;
  const PrinterStatus(this.value);
}
