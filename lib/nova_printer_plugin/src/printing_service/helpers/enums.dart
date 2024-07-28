// ignore_for_file: constant_identifier_names

enum EpsonEPOSPortType { ALL, TCP, BLUETOOTH, USB }

enum EpsonEPOSPrintLang {
  MODEL_ANK,
  MODEL_CHINESE,
  MODEL_TAIWAN,
  MODEL_KOREAN,
  MODEL_THAI,
  MODEL_SOUTHASIA
}

enum EpsonEPOSCut { CUT_FEED, CUT_NO_FEED, CUT_RESERVE }

enum EpsonEPOSTextAlign { LEFT, CENTER, RIGHT }

enum EpsonEPOSFont { FONT_A, FONT_B, FONT_C, FONT_D, FONT_E }

enum EpsonEPOSColor {
  COLOR_NONE,
  COLOR_1,
  COLOR_2,
  COLOR_3,
  COLOR_4,
}

enum ManufactureName {
  Epson,
  Citizen,
  None;

  static ManufactureName fromValue(String? value) {
    return ManufactureName.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => None,
    );
  }
}
