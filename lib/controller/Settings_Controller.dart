import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();
  
  var isDarkMode = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";
  String? get lastUid => _box.read('last_uid');

  @override
  void onInit() {
    super.onInit();
    var allUsers = _box.read('users_settings_map');
    if (allUsers != null ) {
      var userSettings = allUsers[currentUserId];
      if (userSettings != null) {
        isDarkMode.value = userSettings['isDark'] ?? false;
      }
    }
    // تنفيذ التهيأة فوراً عند استدعاء الكنترولر

    initUserSettings(lastUid ?? currentUserId);
  }
  // فانكشن تحديث الإعدادات

  Future<void> _syncWithCloud(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'settings': data,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Cloud Sync Failed: $e");
    }
  }

 Future<void> changeLang(String languageCode) async {
  // 1. نجيب الـ UID "الآن" مباشرة من Firebase لضمان الدقة
  final String? freshUid = FirebaseAuth.instance.currentUser?.uid;
  
  if (freshUid == null || freshUid.isEmpty) {
    debugPrint("No user logged in!");
    return;
  }

  // 2. التغيير اللحظي للواجهة
  Get.updateLocale(Locale(languageCode));
  // تحديث الـ Rx variable لو موجود

  bool isArabic = (languageCode == 'ar');
  String currentTimestamp = DateTime.now().toIso8601String();

  try {
    // 3. تحديث الكاش المحلي (GetStorage)
    Map<String, dynamic> allUsersMap = _box.read('users_settings_map') ?? {};
    Map<String, dynamic> currentUserSettings = allUsersMap[freshUid] ?? {};

    currentUserSettings['isArabic'] = isArabic;
    currentUserSettings['timestamp'] = currentTimestamp;

    allUsersMap[freshUid] = currentUserSettings;
    await _box.write('users_settings_map', allUsersMap);
    await _box.write('last_uid', freshUid); // تحديث آخر مستخدم

    // 4. المزامنة مع الكلاود (التعديل الجوهري هنا)
    // نستخدم .update() مع Dot Notation عشان يدخل جوه الماب فعلياً
    await _firestore.collection('users').doc(freshUid).update({
      'settings.isArabic': isArabic,
      'settings.timestamp': FieldValue.serverTimestamp(),
    });

    //print("Language updated for UID: $freshUid");

  } catch (e) {
    // ملاحظة: لو الدوكيومنت مش موجود أصلاً، الـ update هتفشل، وقتها نستخدم set
    if (e is FirebaseException && e.code == 'not-found') {
      await _firestore.collection('users').doc(freshUid).set({
        'settings': {
          'isArabic': isArabic,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    }
    debugPrint("Error updating language: $e");
  }
}
  //_____________________________________________________________________________

  Future<void> initUserSettings(String uid) async {
    // 1. قراءة الماب المحلية
    Map<String, dynamic> allUsersMap = _box.read('users_settings_map') ?? {};
   // print('${allUsersMap}_______________//_________________//');

    // حالة أ: اليوزر موجود في الكاش (السيناريو الأسرع)
    if (allUsersMap.containsKey(uid)) {
      _applySettings(allUsersMap[uid]);
      // ونعمل المزامنة في الخلفية للتأكد من الوقت (Timestamp Sync)
      syncSettingsWithCloud(uid);
      return;
    }

    // حالة ب: اليوزر مش في الكاش (جهاز جديد أو مسح الداتا)
    // نروح نشيك في الكلاود
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> cloudData =
            (doc.data() as Map<String, dynamic>)['settings'] ?? {};

        if (cloudData.isNotEmpty) {
          // اليوزر كان مسجل من جهاز تاني، ناخد بيانات الكلاود ونخزنها محلياً
          allUsersMap[uid] = {
            'isArabic': cloudData['isArabic'],
            'isDark': cloudData['isDark'],
            'timestamp': (cloudData['timestamp'] as Timestamp)
                .toDate()
                .toIso8601String(),
          };
          await _box.write('users_settings_map', allUsersMap);
          _applySettings(allUsersMap[uid]);
          return;
        }
      }
    } catch (e) {
      debugPrint("Error checking cloud during init: $e");
    }

    // حالة ج: يوزر جديد تماماً (مش في الكاش ولا الكلاود)
    // نستخدم إعدادات الجهاز الافتراضية
    allUsersMap[uid] = {
      'isArabic': Get.deviceLocale?.languageCode == 'ar',
      'isDark': Get.isPlatformDarkMode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _box.write('users_settings_map', allUsersMap);
    _applySettings(allUsersMap[uid]);

    // نرفع النسخة الافتراضية للكلاود فوراً
    _syncWithCloud(uid, allUsersMap[uid]);
  }
  //_____________________________________________________________________________

  void _applySettings(Map<String, dynamic> settings) {
    bool isArabic = settings['isArabic'] ?? false;
    bool isDark = settings['isDark'] ?? false;
    Get.updateLocale(isArabic ? const Locale('ar') : const Locale('en'));
   Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  //_____________________________________________________________________________

  Future<void> syncSettingsWithCloud(String uid) async {
    try {
      // 1. جلب داتا الكلاود (Cloud Snapshot)
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) return;

      // بنسحب ماب الـ settings من جوا الدوكيومنت
      Map<String, dynamic> cloudData =
          (doc.data() as Map<String, dynamic>)['settings'] ?? {};
      if (cloudData.isEmpty) return;

      // 2. جلب داتا الكاش (Local Cache)
      Map<String, dynamic> allUsersMap = _box.read('users_settings_map') ?? {};
      Map<String, dynamic> localData = allUsersMap[uid] ?? {};

      // 3. تحويل التايم لمقارنته
      // الفايربيز بيبعت Timestamp، والكاش مخزن ISO String
      DateTime cloudTime = (cloudData['timestamp'] as Timestamp).toDate();
      DateTime localTime = DateTime.parse(
        localData['timestamp'] ??
            DateTime.now()
                .subtract(const Duration(days: 365))
                .toIso8601String(),
      );

      // 4. منطق المقارنة (The Decision Making)

      if (cloudTime.isAfter(localTime)) {
        // الحالة الأولى: الكلاود أحدث (اليوزر غير إعداداته من جهاز تاني)
        //print("Cloud is newer, updating local cache...");

        // نحدث ماب اليوزر في الكاش بالقيم الجديدة
        localData['isArabic'] = cloudData['isArabic'];
        localData['isDark'] = cloudData['isDark'];
        localData['timestamp'] = cloudTime
            .toIso8601String(); // نخزنه String في الكاش

        allUsersMap[uid] = localData;
        await _box.write('users_settings_map', allUsersMap);

        // نطبق الإعدادات فوراً في التطبيق
        _applySettings(localData);
      } else if (localTime.isAfter(cloudTime)) {
        // الحالة الثانية: الكاش أحدث (اليوزر عدل وهو أوفلاين على الجهاز ده)
       // print("Local cache is newer, uploading to cloud...");

        // نرفع بيانات الكاش للسيرفر عشان نحدث الكلاود
        await _syncWithCloud(uid, localData);
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  //_____________________________________________________________________________

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    }
  //_____________________________________________________________________________
Future<void> _syncThemeToCloud(bool darkMode) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'settings.isDark': darkMode,
        'settings.timestamp': FieldValue.serverTimestamp(),
      });
    }
}
//_____________________________________________________________________________
void changeTheme() async {
  final String? freshUid = FirebaseAuth.instance.currentUser?.uid;
  
  // 1. الحماية: لو مفيش يوزر، غير الثيم محلياً بس واخرج
  if (freshUid == null) {
    toggleTheme(); // بتعكس القيمة (True -> False)
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
    return;
  }

  // 2. عكس الحالة (Toggle)
  toggleTheme();
  //print(  "Theme toggled locally: ${isDarkMode.value ? "Dark" : "Light"} for UID: $freshUid");
  Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

  try {
    // 3. تحديث الكاش المحلي (GetStorage)
    Map<String, dynamic> allUsersMap = _box.read('users_settings_map') ?? {};
    Map<String, dynamic> currentUserSettings = allUsersMap[freshUid] ?? {};

    currentUserSettings['isDark'] = isDarkMode.value;
    currentUserSettings['timestamp'] = DateTime.now().toIso8601String();

    allUsersMap[freshUid] = currentUserSettings;
    
    // السطر ده هو اللي كان ناقص يا بطل!
    await _box.write('users_settings_map', allUsersMap); 

    // 4. المزامنة مع الكلاود
    _syncThemeToCloud(isDarkMode.value);
    
   // print("Theme updated locally and sync started for UID: $freshUid");
  } catch (e) {
    debugPrint("Error in changeTheme: $e");
  }
}

    
}
