import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale("en"));

  bool isArabic() {
    return (Intl.getCurrentLocale() == "ar_EG" || Intl.getCurrentLocale() == "ar");
  }

  void setLocale(Locale locale) {
    if (locale.languageCode == "en" || locale.languageCode == "ar") {
      emit(locale);
    }
  }

  Locale getLocale() => state;
}
