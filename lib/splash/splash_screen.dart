import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  // بنعمل Inject للـ Controller هنا
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface, // أو أي لون يناسب البراند بتاعك
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // هنا بنعرض أنيميشن الـ Lottie
            Lottie.asset(
              'assets/animations/book.json',
              width: 750,
              height: 500,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}