// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/module/Fav/fav_Screen.dart';
import 'package:the_dark_knight_final/module/homePage.dart';
import 'package:the_dark_knight_final/module/Profile/profile_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/api_controller.dart';
import '../module/Search/search_screen.dart';
import '../shared/components.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ignore: camel_case_types
class Home_page extends StatelessWidget {
  // جوه الكلاس بتاع الـ View
  

   Home_page({super.key});

  List<Widget> pages = [
    Homepage(),//==0
    search_page(),//==1
    Fav(),//==2
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
      final Homecrt crt = Get.find();
    
    return Scaffold(
      bottomNavigationBar: Obx(()
        => BottomNavigationBar(
          currentIndex: crt.index.value,
          type: BottomNavigationBarType.fixed,
          items:  [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '7'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '8'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_sharp), label: '9'.tr),
            BottomNavigationBarItem( icon: Icon(Icons.person),label: '10'.tr,),
          ],
          
         onTap: (value) => crt.changeIndex(value),),
      ),
      appBar:  AppBar( 
        title: Obx(()=>Text(crt.titles[crt.index.value].tr, style: GoogleFonts.playfairDisplay(
                            fontSize  : 25,
                            fontWeight: FontWeight.bold,
                            color     : const Color.fromARGB(255, 255, 255, 255),
                          ),),),
        //centerTitle: false,
        actions: [
          
          buildConnectivityStatus(),
          ],),
      
        body:Obx(() => pages[crt.index.value]),
        
        
         /* CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // الـ Header المبهر (SliverAppBar)
            const SliverAppBar(
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Books Library', style: TextStyle(color: Colors.white)),
                centerTitle: true,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),

            // محتوى الصفحة
            SliverToBoxAdapter(
              child: 
            ),
          ],
        ), */
      
    );
  }
}
