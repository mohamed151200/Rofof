import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/controller/Localization_controller.dart';
import 'package:the_dark_knight_final/controller/Settings_Controller.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:get/get.dart';



// ══════════════════════════════════════
//  Section Label
// ══════════════════════════════════════



class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.lato(
        fontSize    : 11,
        fontWeight  : FontWeight.bold,
        color       : context.textPrimary,
        letterSpacing: 2,
      ),
    );
  }
}

// ══════════════════════════════════════
//  Settings Tile
// ══════════════════════════════════════
class SettingsTile extends StatelessWidget {
  final IconData  icon;
  final Color     iconColor;
  final String    title;
  final String    subtitle;
  final Widget    trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding   : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color        : context.surface,
          borderRadius : BorderRadius.circular(16),
          border       : Border.all(color: context.border),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width : 38, height: 38,
              decoration: BoxDecoration(
                color        : iconColor.withOpacity(0.12),
                borderRadius : BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: GoogleFonts.lato(
                      color     : context.textPrimary,
                      fontSize  : 15,
                      fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: GoogleFonts.lato(
                      color   :context.textHint,
                      fontSize: 12,
                    )),
                ],
              ),
            ),

            trailing,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
//  Language Toggle
// ══════════════════════════════════════
class LanguageToggle extends StatelessWidget {
  final MyLocalController controller;
  final SettingsController Ctrl = Get.find();
   LanguageToggle({required this.controller});

  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color        : const Color(0xff0D0D12),
        borderRadius : BorderRadius.circular(20),
        border       : Border.all(color: const Color(0xff2a2a3a)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['ar', 'en'].map((lang) {
          final isSelected = Get.locale?.languageCode == lang;
          return GestureDetector(
            onTap: () => Ctrl.changeLang(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color        : isSelected ? mainColor : Colors.transparent,
                borderRadius : BorderRadius.circular(20),
              ),
              child: Text(
                lang == 'ar' ? 'ع' : 'EN',
                style: GoogleFonts.lato(
                  color     : isSelected ? Colors.white : Colors.white38,
                  fontSize  : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

