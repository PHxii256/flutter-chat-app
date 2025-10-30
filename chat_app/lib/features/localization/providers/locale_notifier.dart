// ignore_for_file: avoid_print
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part "locale_notifier.g.dart";

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    return Locale("en");
  }

  bool isArabic() {
    return (Intl.getCurrentLocale() == "ar_EG" || Intl.getCurrentLocale() == "ar");
  }

  void setLocale(Locale local) {
    if (local.languageCode == "en" || local.languageCode == "ar") {
      state = local;
    }
  }

  void getLocal() => state;
}
