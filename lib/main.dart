import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/controller/Localization_controller.dart';
import 'package:the_dark_knight_final/controller/Settings_Controller.dart';
import 'package:the_dark_knight_final/controller/connectivity_controller.dart';
import 'package:the_dark_knight_final/controller/theme_controller.dart';
import 'package:the_dark_knight_final/remote/api_client.dart';
import 'package:the_dark_knight_final/shared/Localization.dart';
import 'package:the_dark_knight_final/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/splash/splash_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/api_controller.dart';
import 'controller/sql_controller.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
   // GoogleFonts.config.allowRuntimeFetching = false;
    await GetStorage.init();
    //print("Storage Initialized");
    // جرب تشغل الفايربيز بـ Timeout
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
  } catch (e) {
    //print("Firebase Initialization Timed Out or Failed: $e");
    // حتى لو فشل، هنكمل عشان الأبلكيشن يفتح
  }
  ApiClient.init();

  Get.put( Sqlcrt());

  Get.put(  Homecrt());
  Get.put(  SettingsController());


   Get.put(ConnectivityController());
   Get.put(ShowPasswordController());

  


 // await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final localController = Get.put(MyLocalController());
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      
      translations: Mylocal(),
      debugShowCheckedModeBanner: false,

      home:
          SplashScreen(),
    );
  }
}
