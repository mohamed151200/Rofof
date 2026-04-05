import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/module/homePage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/shared/colors.dart';

import 'components.dart';

class AppThemes {
  static final lightTheme =
   ThemeData.light().copyWith(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:  AppColors.lightBg,
      
      selectedItemColor: mainColor,
      unselectedItemColor: Colors.grey,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 225, 213, 213),
    cardColor: AppColors.lightSurface,
     dividerColor:AppColors.lightBorder,
    appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: "PlayfairDisplay"), // لون النص العادي
      bodyMedium: GoogleFonts.caveat(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      bodySmall: GoogleFonts.caveat(
        fontSize: 20,
        color: mainColor,
      ),
    ),

    primaryColor: Colors.blueGrey.shade300,
    
    
  );

  static final darkTheme = ThemeData.dark().copyWith(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: mainColor,
      unselectedItemColor: Colors.grey,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
  cardColor              : AppColors.darkSurface,
  dividerColor           : AppColors.darkBorder,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
      primaryColor: mainColor,
      
      
      

      
      textTheme: TextTheme(
        bodyLarge: const TextStyle(
          fontFamily: "PlayfairDisplay",
          color: Colors.white, fontSize: 18), // لون النص العادي
        bodyMedium: GoogleFonts.caveat(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: GoogleFonts.caveat(
          fontSize: 20,
          color: mainColor,
          fontWeight: FontWeight.bold,
        ),
      ),
     );
}
