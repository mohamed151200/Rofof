import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkTheme';
  final _searchHistoryKey = 'search_history';
  var searchHistory = [].obs;

  

  // Getter لاختصار استدعاء القيمة من التخزين
  bool get isDarkMode => _box.read(_key) ?? false;
  

  // لتحديد الثيم عند بداية تشغيل التطبيق (نستخدمها في الـ main)
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    // تغيير الثيم في الـ UI
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    
    // حفظ الحالة الجديدة في الذاكرة
    _box.write(_key, !isDarkMode);
    
    // تحديث الواجهة (لو مستخدم GetBuilder أو لتأكيد التغيير)
    update();
  }


//__________________________________________________________________________//

//__________________________________________________________________________//

@override
  void onInit() {
  super.onInit();
  getHistory();
}
// ميثود الحفظ الذكي
void saveSearchQuery(String query) {
  // 1. هنجيب الليستة القديمة (لو فاضية هنرجع لستة فاضية)
  List<dynamic> history = _box.read(_searchHistoryKey) ?? [];

  // 2. لو الكلمة موجودة قبل كدة نمسحها عشان نجيبها "قدام" (Recent)
  if (history.contains(query)) {
    history.remove(query);
  }

  // 3. نضيف الكلمة الجديدة في أول الليستة
  history.insert(0, query);

  // 4. لو الليستة زادت عن 3، نشيل آخر واحدة (الأقدم)
  if (history.length > 3) {
    history.removeLast();


  }

searchHistory.value = history; // تحديث الـ UI بالليستة الجديدة
  // 5. نحفظ الليستة الجديدة
  _box.write(_searchHistoryKey, history);
   // تحديث الـ UI بعد الحفظ
}

// ميثود القراءة
void getHistory() {
  searchHistory.value = _box.read(_searchHistoryKey) ?? [];
  //print('${searchHistory.value}___________________________________');
}
void removeSingleQuery(String query) {
  // 1. اقرأ من الـ storage كـ List عادية
  List<dynamic> history = List.from(_box.read(_searchHistoryKey) ?? []);
  
  // 2. امسح منها
  history.remove(query);
  
  // 3. احفظ الـ List العادية
  _box.write(_searchHistoryKey, history);
  
  // 4. حدّث الـ UI
  searchHistory.value = history;
}
void clearallHistory() {
  // 1. امسح من الليستة اللي في الـ Memory
  searchHistory.clear();
  _box.remove(  _searchHistoryKey);
  // 2. اكتب لستة فاضية مكان القديمة
  _box.write(_searchHistoryKey, []);
}}