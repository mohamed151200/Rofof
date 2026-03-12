import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/controller/theme_controller.dart';
import 'package:the_dark_knight_final/module/results.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import '../../controller/api_controller.dart';

// ignore: must_be_immutable, camel_case_types
class search_page extends StatelessWidget {
  final TextEditingController _textCtrl = TextEditingController();

  search_page({super.key});

  final Homecrt      searchCrt = Get.find();
  final Sqlcrt       dbCrt     = Get.find();
  final ThemeController themeCrt = Get.find();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold  (
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Text(
                '20'.tr,
                style: GoogleFonts.lato(fontSize: 14, color: context.textHint),
              ),
            ),

            // ── Search Field ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color        : context.surface,
                  borderRadius : BorderRadius.circular(16),
                  border       : Border.all(color: context.border),
                ),
                child: Row(
                  children: [
                     Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.search_rounded, color: context.iconColor, size: 18),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        style: GoogleFonts.lato(color: context.textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText      : '، رواية، تاريخ...',
                          hintStyle     : GoogleFonts.lato(color: context.textHint, fontSize: 15),
                          border        : InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        onChanged: (value) {
                          searchCrt.lastQuery.value = value.trim();
                          searchCrt.toggleSearching();
                          if (value.trim().length >= 2) {
                            searchCrt.getSuggestions();
                          } else {
                            searchCrt.suggestions.clear();
                          }
                        },
                      ),
                    ),
                    Obx(() => searchCrt.lastQuery.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _textCtrl.clear();
                            searchCrt.lastQuery.value = '';
                            searchCrt.isSearching.value = false;
                            searchCrt.suggestions.clear();
                          },
                          child:  Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.close_rounded, color: context.iconColor, size: 18),
                          ),
                        )
                      : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Content ──
            Expanded(
              child: Obx(() {
                if (!searchCrt.isSearching.value) {
                  return _buildHistorySection();
                }
                return _buildSuggestionsSection();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Obx(() {
      final history = themeCrt.searchHistory;
      if (history.isEmpty) {
        return _buildEmptyState(
          icon    : Icons.history_rounded,
          title   : '21'.tr,
          subtitle: '22'.tr,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('23'.tr,
                  style: GoogleFonts.lato(
                    color: Colors.white38, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    themeCrt.clearallHistory();
                  },
                  child: Text('24'.tr,
                    style: GoogleFonts.lato(color: mainColor, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding         : const EdgeInsets.symmetric(horizontal: 20),
              itemCount       : history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder     : (context, i) => _SearchTile(
                query    : history[i],
                icon     : Icons.history_rounded,
                iconColor: Colors.white24,
                onTap    : () => _search(history[i]),
                onDelete : () => themeCrt.removeSingleQuery(history[i]),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSuggestionsSection() {
    return Obx(() {
      final suggestions = searchCrt.suggestions;
      final query       = searchCrt.lastQuery.value;
      return ListView.separated(
        padding         : const EdgeInsets.symmetric(horizontal: 20),
        itemCount       : suggestions.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder     : (context, i) {
          if (i == 0) {
            return _SearchTile(
              query        : query,
              icon         : Icons.search_rounded,
              iconColor    : mainColor,
              isHighlighted: true,
              onTap        : () => _search(query),
            );
          }
          final suggestion = suggestions[i - 1];
          return _SearchTile(
            query    : suggestion,
            icon     : Icons.auto_stories_outlined,
            iconColor: Colors.white24,
            onTap    : () => _search(suggestion),
          );
        },
      );
    });
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.08),
            ),
            child: Icon(icon, color: Colors.white12, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, 
            style: GoogleFonts.playfairDisplay(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle,
            style: GoogleFonts.lato(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  void _search(String query) {
    Homecrt crt = Get.find();
    
    // 1. التجهيز (Setup State) - لازم يكون الأول
    crt.resetPagination();
    crt.searchQuery.value = query;
    crt.typeofmethod.value = LoadSource.search;
    themeCrt.saveSearchQuery(query);
    themeCrt.searchHistory.refresh();
    Get.to(() => Results(genre: query));

    // 3. اطلب البيانات (ستحدث في الخلفية والـ Shimmer شغال)
    crt.fetchResults(query);
  }
}

// ══════════════════════════════════════
//  _SearchTile
// ══════════════════════════════════════
class _SearchTile extends StatelessWidget {
  final String       query;
  final IconData     icon;
  final Color        iconColor;
  final bool         isHighlighted;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

   _SearchTile({
    required this.query,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isHighlighted = false,
    this.onDelete,
  });

  static const mainColor  = Color(0xff77094E);
  Color  _kSurface  = Get.isDarkMode ?  Color(0xff1C1C1E) :  Color(0xffF5F5F7);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding   : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color       : isHighlighted ? mainColor.withOpacity(0.12) : _kSurface,
          borderRadius: BorderRadius.circular(14),
          border      : Border.all(
            color: isHighlighted ? mainColor.withOpacity(0.4) : const Color(0xff2a2a3a),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color       : context.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                maxLines : 1,
                overflow : TextOverflow.ellipsis,
                style    : GoogleFonts.lato(
                  color     : context.textPrimary,
                  fontSize  : 14,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child:  Padding(
                  padding: EdgeInsets.only(left: 8),
                  child  : Icon(Icons.close_rounded, color: context.iconColor),
                ),
              )
            else
               Icon(Icons.north_west_rounded, color: context.iconColor, size: 16),
          ],
        ),
      ),
    );
  }
}
