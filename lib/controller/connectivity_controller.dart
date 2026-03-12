import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  // 1. مراقب للحالة (Observable)
  var isConnected = true.obs;
  
  // 2. كائن للاشتراك في الـ Stream
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  
  // 3. أداة الـ Connectivity
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    // 4. البداية: فحص الحالة الحالية أول ما الكلاس يشتغل
    _checkInitialConnection();
    
    // 5. المراقبة: الاستماع لأي تغيير في الشبكة
// في onInit
_subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
  _updateConnectionStatus(results.first); // نبعت أول عنصر في القائمة
});  }

  // فحص الحالة وقت تشغيل الكلاس
  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result.first);
  }

  // تحديث الحالة عند حدوث تغيير (اونلاين -> اوفلاين أو العكس)
  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      // هنا ممكن تضيف SnackBar تطلع للمستخدم تقوله "أنت اوفلاين"
      Get.snackbar(
        "لا يوجد إنترنت",
        "تم تفعيل وضع الأوفلاين",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } else {
      isConnected.value = true;
    }
  }
 
}