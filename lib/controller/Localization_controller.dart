import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';

class MyLocalController extends GetxController {
  final _box = GetStorage();
  final _key = 'currentLang';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = Get.find<ShowPasswordController>().currentUserId;
 

  Future<void> changeLang( String languageCode) async {
    
  // 1. التغيير اللحظي للواجهة (Instant UI Update)
  // عشان اليوزر يحس باستجابة فورية
  Get.updateLocale(Locale(languageCode));

  // 2. تحضير البيانات
  bool isArabic = (languageCode == 'ar');
  String currentTimestamp = DateTime.now().toIso8601String();

  try {
    // 3. تحديث الكاش المحلي (GetStorage) داخل الماب الكبيرة
    Map<String, dynamic> allUsersMap = _box.read('users_settings_map') ?? {};
    
    // سحب ماب المستخدم الحالي أو إنشاء واحدة جديدة
    Map<String, dynamic> currentUserSettings = allUsersMap[uid] ?? {};
    
    // تحديث القيم
    currentUserSettings['isArabic'] = isArabic;
    currentUserSettings['timestamp'] = currentTimestamp;
    
    // الحفظ في الكاش
    allUsersMap[uid] = currentUserSettings;
    await _box.write('users_settings_map', allUsersMap);

    // 4. المزامنة مع الكلاود (Firebase Firestore)
    // بنستخدم merge: true عشان منأثرش على بيانات اليوزر التانية (زي الاسم أو الصورة)
    await _firestore.collection('users').doc(uid).set({
      'settings': {
        'isArabic': isArabic,
        'timestamp': FieldValue.serverTimestamp(), // وقت السيرفر لضمان الدقة في المزامنة مستقبلاً
      }
    }, SetOptions(merge: true));

    print("Language updated locally and on cloud successfully.");

  } catch (e) {
    // لو حصل مشكلة في النت، التغيير مسجل في الكاش وهيترفع في الـ sync الجاي
    debugPrint("Error updating language: $e");
  }
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
