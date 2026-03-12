import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/controller/api_controller.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/module/Fav/Fav_widget.dart' show BuildEmptyState, FavCard;
import 'package:the_dark_knight_final/module/book_details.dart';
import 'package:the_dark_knight_final/shared/components.dart';

class Fav extends StatelessWidget {
  const Fav({super.key});

  static const _kPrimary = Color(0xff77094E);
  

  @override
  Widget build(BuildContext context) {
    final Sqlcrt crt = Get.find();

    return Scaffold(
     
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          '${crt.books.length} ${crt.books.length == 1 ? 'book' : 'books'} saved',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color   : context.textHint,
                          ),
                        )),
                      ],
                    ),
                  ),

                  // أيقونة bookmark زخرفية
                  Container(
                    width : 44, height: 44,
                    decoration: BoxDecoration(
                      color        : _kPrimary.withOpacity(0.12),
                      borderRadius : BorderRadius.circular(12),
                      border       : Border.all(color: _kPrimary.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: _kPrimary,
                      size : 22,
                    ),
                  ),
                ],
              ),
            ),

            // Divider خفيف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 0.5,
                color : context.border,
              ),
            ),

            // ── List / Empty State ──
            Expanded(
              child: GetX<Sqlcrt>(
                builder: (_) {
                  if (crt.books.isEmpty) {
                    
                    return BuildEmptyState();
                  }

                  return ListView.separated(
                    padding         : const EdgeInsets.symmetric(horizontal: 20),
                    itemCount       : crt.books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder     : (context, i) {
                     
                      final item = crt.books[i];
                      return FavCard(item: item, crt: crt);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
 
}