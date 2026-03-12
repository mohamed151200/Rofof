import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MyLocalController extends GetxController {
  final _box = GetStorage();
  final _key = 'currentLang';
 

  void changeLang(String languageCode) {
    _box.write(_key, languageCode);
    //Locale locale = Locale(languageCode);
    Get.updateLocale(Locale(languageCode));
  }
  Locale getlocale() {
    String? langCode = _box.read(_key);
    if (langCode != null) {
      return Locale(langCode);
    } else {
      return Get.deviceLocale?? Locale('en'); // اللغة الافتراضية
    }
  }
}
