import 'dart:io';
import 'package:flutter/foundation.dart';

String getServertUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:3000/'; // For Flutter web in browser
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/'; // For Android emulator
  } else if (Platform.isIOS) {
    return 'http://127.0.0.1:3000/'; // For iOS simulator
  } else {
    return 'http://127.0.0.1:3000/'; // For desktop or other platforms
  }
}
