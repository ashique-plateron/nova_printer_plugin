// ignore_for_file: constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PrintCommandId {
  PrintRawData('printRawData'),
  PrintText('printText'),
  AddImage('addImage'),
  AddFeedLine('addFeedLine'),
  AddCut('addCut'),
  AddTextSmooth('addTextSmooth'),
  AddDivider("printText"),
  PrintQRCode("printQRCode"),
  ;

  final String value;
  const PrintCommandId(this.value);
}

@JsonEnum(valueField: 'value')
enum PrintAlign {
  LEFT('LEFT'),
  RIGHT('RIGHT'),
  CENTRE('CENTRE');

  final String value;
  const PrintAlign(this.value);
}

@JsonEnum(valueField: 'value')
enum PrintFont {
  FONT_A('FONT_A'),
  FONT_B('FONT_B'),
  FONT_C('FONT_C'),
  FONT_D('FONT_D'),
  FONT_E('FONT_E');

  final String value;
  const PrintFont(this.value);
}

@JsonEnum(valueField: 'value')
enum PrintColor {
  COLOR_1('COLOR_1'),
  COLOR_2('COLOR_2'),
  COLOR_3('COLOR_3'),
  COLOR_4('COLOR_4'),
  COLOR_NONE('COLOR_NONE');

  final String value;
  const PrintColor(this.value);
}

@JsonEnum(valueField: 'value')
enum PrintAddCutType {
  CUT_FEED('CUT_FEED'),
  CUT_NO_FEED('CUT_NO_FEED'),
  CUT_RESERVE('CUT_RESERVE');

  final String value;
  const PrintAddCutType(this.value);
}

@JsonEnum(valueField: 'value')
enum ImageColorMode {
  MODE_MONO('MODE_MONO'),
  MODE_GRAY16('MODE_GRAY16');

  final String value;
  const ImageColorMode(this.value);
}

enum ImageHalfTone {
  HALFTONE_THRESHOLD('HALFTONE_THRESHOLD'),
  HALFTONE_DITHER('HALFTONE_DITHER'),
  HALFTONE_ERROR_DIFFUSION('HALFTONE_ERROR_DIFFUSION');

  final String value;
  const ImageHalfTone(this.value);
}

enum QRCorrectionLevel {
  LOW('LOW'),
  MEDIUM('MEDIUM'),
  QUARTER('QUARTER'),
  HIGH('HIGH');

  final String value;
  const QRCorrectionLevel(this.value);
}
