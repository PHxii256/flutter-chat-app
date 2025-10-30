import 'dart:convert';
import 'dart:developer';

void prettyJsonPrint(dynamic res) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String formattedJson = encoder.convert(res);
  log(formattedJson);
}
