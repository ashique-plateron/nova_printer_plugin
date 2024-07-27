import 'package:nova_printer_plugin/src/printing_service/helpers/epson_epos.dart';
import 'package:nova_printer_plugin/src/printing_service/model/epson/commands/print_commands.dart';

abstract class PrintCommandGenerator {
  EpsonEPOSColor get blackColor => EpsonEPOSColor.COLOR_1;

  EpsonEPOSColor get redColor => EpsonEPOSColor.COLOR_2;

// text size
  TextSizeAttribute get textSizeSmall => TextSizeAttribute(1, 1);

  TextSizeAttribute get textSizeMedium => TextSizeAttribute(1, 2);

  TextSizeAttribute get textSizeLarge => TextSizeAttribute(2, 2);

  List<PrintCommand> getTextStyle({
    EpsonEPOSTextAlign align = EpsonEPOSTextAlign.LEFT,
    EpsonEPOSColor color = EpsonEPOSColor.COLOR_1,
    TextSizeAttribute? textSize,
    bool bold = false,
  }) {
    return [
      PrintCommand(
        PrintCommandType.textAlign,
        TextAlignAttribute(align),
      ),
      PrintCommand(
        PrintCommandType.textStyle,
        TextStyleAttribute(bold, false, false, color),
      ),
      PrintCommand(
          PrintCommandType.textSize, textSize ?? TextSizeAttribute(1, 1))
    ];
  }

  List<PrintCommand> insertLineFeed(int noOfLines) {
    return [
      PrintCommand(PrintCommandType.feedLine, FeedLineAttribute(noOfLines)),
    ];
  }

  List<PrintCommand> getDividerCommand() {
    return [
      PrintCommand(PrintCommandType.divider, DividerAttribute()),
    ];
  }

  PrintCommand get cut {
    return PrintCommand(
        PrintCommandType.cut, CutAttribute(EpsonEPOSCut.CUT_FEED));
  }

  PrintCommand getTextCommand(String text) {
    return PrintCommand(PrintCommandType.text, TextAttribute(text));
  }

  PrintCommand getRowWithTwoColumnCommand(
      String columnText1, String columnText2) {
    return PrintCommand(PrintCommandType.rowWithTwoColumns,
        RowWithTwoColumnAttribute(columnText1, columnText2));
  }

  Future<PrintCommands> get printCommands;
}
