import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/controller/api_controller.dart';
import 'package:the_dark_knight_final/controller/connectivity_controller.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:the_dark_knight_final/module/book_details.dart';
import 'package:the_dark_knight_final/shared/components.dart';

class FavCard extends StatelessWidget {
  final dynamic item;
  final Sqlcrt  crt;

  const FavCard({required this.item, required this.crt});


  

  @override
  Widget build(BuildContext context) {
    ConnectivityController connectivityController = Get.find<ConnectivityController>();

    return Dismissible(
      // ← سحب لليسار يحذف من المفضلة
      key      : Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        
      connectivityController.isConnected.value?
      crt.deleteOnline(item.id, 'books') // لو متصل، امسحه من الموبايل والسيرفر
      :crt.deleteOffline(item.id, 'books'); // لو مش متصل، امس
    
      },
      background: Container(
        alignment   : Alignment.centerRight,
        padding     : const EdgeInsets.only(right: 20),
        decoration  : BoxDecoration(
          color       : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border      : Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
      ),

      child: GestureDetector(
        onTap: () {
          // الضغط يروح لـ BookDetails
          final Homecrt apiCrt = Get.find();
          apiCrt.fetchAuthors(item.author.isNotEmpty ? item.author : item.category ?? '').then((lst) {
            Get.to(
              () => BookDetails(item,   ),
              transition: Transition.cupertino,
            );
          });
        },
        child: Container(
          padding   : const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color       : context.surface,
            borderRadius: BorderRadius.circular(16),
            border      : Border.all(color: context.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── صورة الكتاب ──
              Hero(
                tag: item.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.image,
                    width : 80,
                    height: 115,
                    fit   : BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width : 80, height: 115,
                      decoration: BoxDecoration(
                        color       : const Color(0xff1a1a2e),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.white24, size: 32),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Info ──
              Expanded(
                child: SizedBox(
                  height: 115,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children: [

                      // العنوان
                      Text(
                        item.title,
                        maxLines : 2,
                        overflow : TextOverflow.ellipsis,
                        style    : GoogleFonts.playfairDisplay(
                          color     : context.textPrimary,
                          fontSize  : 15,
                          fontWeight: FontWeight.w600,
                          height    : 1.3,
                        ),
                      ),

                      // المؤلف
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.author.isNotEmpty ? item.author : 'Unknown Author',
                              maxLines : 1,
                              overflow : TextOverflow.ellipsis,
                              style    : GoogleFonts.lato(
                                color  : context.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Price + Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // السعر
                          Container(
                            padding   : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color       : mainColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border      : Border.all(color: mainColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              item.price.contains('غير') ? 'Free' : item.price,
                              style: GoogleFonts.lato(
                                color    : const Color(0xffC2185B),
                                fontSize : 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // زرار حذف
                          GestureDetector(
                            onTap: () {
                              connectivityController.isConnected.value?
                              crt.deleteOnline(item.id, 'books') // لو متصل، امسحه من الموبايل والسيرفر
                              :crt.deleteOffline(item.id, 'books'); // لو مش متصل، امس
                            },
                            child: Container(
                              width : 32, height: 32,
                              decoration: BoxDecoration(
                                color       : Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bookmark_remove_outlined,
                                color: Colors.redAccent,
                                size : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );}}

    class BuildEmptyState extends StatelessWidget {
  const BuildEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة كبيرة مع glow
          Container(
            width : 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.08),
              border: Border.all(color: mainColor.withOpacity(0.15), width: 1.5),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white24,
              size : 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '34'.tr,
            style: GoogleFonts.playfairDisplay(
              color   : Colors.white38,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '35'.tr,
            style: GoogleFonts.lato(
              color   : Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
    

    
    