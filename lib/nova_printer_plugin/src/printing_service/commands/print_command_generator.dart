import 'package:nova_printer_plugin/plugin.dart';

abstract class PrintCommandGenerator {
  EpsonEPOSColor get blackColor => EpsonEPOSColor.COLOR_1;
  EpsonEPOSColor get redColor => EpsonEPOSColor.COLOR_2;

// text size
  PrintTextSize get textSizeSmall => PrintTextSize(height: 1, width: 1);
  PrintTextSize get textSizeMedium => PrintTextSize(height: 1, width: 2);
  PrintTextSize get textSizeLarge => PrintTextSize(height: 2, width: 2);

  PrintCommands insertLineFeed(int noOfLines) {
    return AddFeedlineCommand(
      attributes: FeedlineAttributes(
        lines: noOfLines,
      ),
    );
  }

  PrintCommands getDividerCommand({String symbol = '-'}) {
    return PrintTextCommand(
      type: PrintCommandId.AddDivider,
      attributes: PrintDividerAttribute(
        symbol: symbol,
      ),
    );
  }

  PrintCommands get cut {
    return AddCutCommand(
      attributes: AddCutAttributes(
        cutType: PrintAddCutType.CUT_FEED,
      ),
    );
  }

  PrintCommands getTextCommand(
    String text, {
    PrintAlign alignment = PrintAlign.LEFT,
    PrintFont fontType = PrintFont.FONT_A,
    bool bold = false,
    PrintTextSize? size,
  }) {
    return PrintTextCommand(
      attributes: PrintTextAttributes(
        text: "$text\n",
        alignment: alignment,
        fontType: fontType,
        style: PrintTextStyle(
          bold: bold,
        ),
        smoothenText: true,
        size: size,
      ),
    );
  }

  PrintCommands getRowWithTwoColumnCommand(
    String columnText1,
    String columnText2, {
    PrintAlign alignment = PrintAlign.LEFT,
    PrintFont fontType = PrintFont.FONT_A,
    PrintTextSize? size,
    bool bold = false,
  }) {
    return PrintTextCommand(
      attributes: RowWith2ColumnAttribute(
        text: columnText1,
        column2Text: columnText2,
        alignment: alignment,
        fontType: fontType,
        style: PrintTextStyle(
          bold: bold,
        ),
        smoothenText: true,
        size: size,
      ),
    );
  }

  // Future<PrintCommands> get printCommands;

  // List<PrintCommand> getTextStyle({
  //   EpsonEPOSTextAlign align = EpsonEPOSTextAlign.LEFT,
  //   EpsonEPOSColor color = EpsonEPOSColor.COLOR_1,
  //   bool bold = false,
  // }) {
  //   return [
  //     PrintCommand(
  //       PrintCommandType.textAlign,
  //       TextAlignAttribute(align),
  //     ),
  //     PrintCommand(
  //       PrintCommandType.textStyle,
  //       TextStyleAttribute(bold, false, false, color),
  //     ),
  //     PrintCommand(
  //         PrintCommandType.textSize, textSize ?? TextSizeAttribute(1, 1))
  //   ];
  // }
}
