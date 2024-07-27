// ignore_for_file: constant_identifier_names
import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin_example/citizen_consts.dart';

@JsonEnum()
enum CitizenTextAlignment {
  LEFT('LEFT'),
  CENTRE('CENTRE'),
  RIGHT('RIGHT');

  final String value;

  const CitizenTextAlignment(this.value);

  static CitizenTextAlignment fromValue(String? value) {
    return CitizenTextAlignment.values.firstWhere(
      (e) => e.value.toLowerCase() == value?.toLowerCase(),
      orElse: () => LEFT,
    );
  }
}

@JsonEnum()
enum CitizenTextStyle {
  CMP_FNT_DEFAULT(CitizenConsts.CMP_FNT_DEFAULT),
  CMP_FNT_FONTC(CitizenConsts.CMP_FNT_FONTC),
  CMP_FNT_BOLD(CitizenConsts.CMP_FNT_BOLD),
  CMP_FNT_REVERSE(CitizenConsts.CMP_FNT_REVERSE),
  CMP_FNT_UNDERLINE(CitizenConsts.CMP_FNT_UNDERLINE),
  CMP_FNT_ITALIC(CitizenConsts.CMP_FNT_ITALIC),
  CMP_FNT_STRIKEOUT(CitizenConsts.CMP_FNT_STRIKEOUT);

  final int value;

  const CitizenTextStyle(this.value);

  static CitizenTextStyle fromValue(int? value) {
    return CitizenTextStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CMP_FNT_DEFAULT,
    );
  }
}
