import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_dark_knight_final/auth/ui/signIn.dart';
import 'package:the_dark_knight_final/controller/Localization_controller.dart';
import 'package:the_dark_knight_final/controller/Settings_Controller.dart';
import 'package:the_dark_knight_final/controller/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/module/Profile/profile_widgets.dart';
import 'package:the_dark_knight_final/shared/components.dart';

class Profile extends StatelessWidget {
   Profile({super.key});
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  @override
  Widget build(BuildContext context) {
    final MyLocalController localCtrl = Get.find();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
     
      backgroundColor: context.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── SliverAppBar مع Avatar ──
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 260,
            pinned: true,
            backgroundColor: context.bg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  // خلفية gradient ناعمة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end  : Alignment.bottomCenter,
                        colors:  Get.isDarkMode
          ? const [const Color(0xff1a0010), const Color(0xff0D0D12)]  // dark
          : const [const Color(0xffF8E8F0), const Color(0xffF5F5F7)],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),

                  // دوائر زخرفية
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20, left: -60,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor.withOpacity(0.04),
                      ),
                    ),
                  ),

                  // Avatar + Info
                  Positioned(
                    bottom: 24, left: 0, right: 0,
                    child: Column(
                      children: [
                        // Avatar مع border
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [mainColor, mainColor.withOpacity(0.3)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: context.surface,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : const NetworkImage(
                                    'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // الاسم
                        Text(
                          user?.displayName ?? 'Book Lover',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // الإيميل
                        Text(
                          user?.email ?? 'reader@books.com',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: context.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ── Section: Appearance ──
                  SectionLabel(label: '11'.tr),
                  const SizedBox(height: 12),

                  // Dark Mode Toggle
                  GetX<SettingsController>(
                    builder: (ctrl) => SettingsTile(
                      icon    : ctrl.isDarkMode.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      iconColor: ctrl.isDarkMode.value ? Colors.purpleAccent : Colors.orange,
                      title   : '1'.tr,
                      subtitle: ctrl.isDarkMode.value ? '12'.tr : '13'.tr,
                      trailing: Switch.adaptive(
                        value          : ctrl.isDarkMode.value,
                        onChanged      : (_) => ctrl.changeTheme(),
                        activeColor    : mainColor,
                        activeTrackColor: mainColor.withOpacity(0.3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Language
                  SettingsTile(
                    icon     : Icons.language_rounded,
                    iconColor: const Color(0xff4fc3f7),
                    title    : '14'.tr,
                    subtitle : Get.locale?.languageCode == 'ar' ? 'العربية' : 'English',
                    trailing : LanguageToggle(controller: localCtrl),
                  ),

                  const SizedBox(height: 28),

                  // ── Section: Account ──
                   SectionLabel(label: '15'.tr),
                  const SizedBox(height: 12),

                  SettingsTile(
                    icon     : Icons.verified_user_rounded,
                    iconColor: user?.emailVerified == true ? Colors.greenAccent : Colors.orange,
                    title    : '16'.tr,
                    subtitle : user?.emailVerified == true ? '17'.tr : '18'.tr,
                    trailing : user?.emailVerified == true
                        ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
                        : const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  ),

                  const SizedBox(height: 8),

                  SettingsTile(
                    icon     : Icons.logout_rounded,
                    iconColor: Colors.redAccent,
                    title    : '19'.tr,
                    subtitle : '32'.tr,
                    trailing : const Icon(Icons.chevron_right, color: Colors.white24),
                    onTap    : () async {
                      await _googleSignIn.signOut();
                      Get.offAll(SignIn());
                    },
                  ),

                  const SizedBox(height: 40),

                  // ── Footer ──
                  Center(
                    child: Text(
                      'The Dark Knight v1.0',
                      style: GoogleFonts.lato(
                        color   : context.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



