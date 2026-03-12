import 'package:get/get.dart';
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/controller/api_controller.dart' show Homecrt;
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/layout/home.dart';
class SplashController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
    startApp();
  }

 void startApp() async {
  bool isRemembered = await Get.find<ShowPasswordController>().checkFirstTimeSync();
  //  print("Step 1: Start SQL");
  //await Get.find<Sqlcrt>().createdata();
  
  //print("Step 2: Start API Fetching");
  // جرب تشيل الـ await من هنا عشان لو الـ API علق التطبيق يكمل
  /* Get.find<Homecrt>().getArt();
  Get.find<Homecrt>().getHistory();
  Get.find<Homecrt>().getprogramming();
  Get.find<Homecrt>().getscience(); */
if (isRemembered) {
    // لو متسجل وتوثيق الإيميل تمام (ممكن تضيف فحص الإيميل هنا)
    Get.off(Home_page()); 
  } else {
    Get.off(SignIn());
  }
}
}