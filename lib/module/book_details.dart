import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:the_dark_knight_final/module/results.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/api_controller.dart';
import '../controller/sql_controller.dart';
import '../shared/components.dart';

// ============================================================
//  STATE — محتاج نتحكم في حالة التحميل
// ============================================================
class BookDetailsController extends GetxController {
  var similarBooks = <BookModel>[].obs;
  var isLoadingSimilar = true.obs; // ← هنا بنتحكم في الـ overlay

  final Homecrt _apiCrt = Get.find();

  // WHY: الـ method دي بتجيب الكتب المشابهة وبتتحكم في الـ loading state
  // بدل ما نعمل navigate لصفحة تانية
  Future<void> loadSimilarBooks(String authorOrCategory) async {
    try {
      isLoadingSimilar.value = true;
       await _apiCrt.fetchAuthors(authorOrCategory);
      similarBooks.assignAll(_apiCrt.genreBooks);
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر تحميل الكتب المشابهة',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    } finally {
      // WHY: finally بتضمن إن الـ loading بيختفي حتى لو في error
      isLoadingSimilar.value = false;
    }
  }
}

// ============================================================
//  MAIN PAGE
// ============================================================
class BookDetails extends StatelessWidget {
  final BookModel book;

  // WHY: مش محتاج تبعت الـ lst من بره — الصفحة بتجيب بياناتها هي
  // ده بيحل مشكلة الـ stale data اللي كانت بتتبعت
  BookDetails(this.book, {super.key});

  // WHY: lazyPut عشان كل ما تفتح صفحة تفاصيل تاخد instance جديدة نضيفة
  final BookDetailsController _ctrl = Get.put(BookDetailsController());
  final Sqlcrt _sql = Get.find();

  @override
  Widget build(BuildContext context) {
    // بنجيب الكتب المشابهة فور ما الصفحة تتبني
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadSimilarBooks(book.author.isNotEmpty ? book.author : book.category ?? '');
    });

    return Scaffold(
      backgroundColor: context.bg,
      body: Obx(() {
        return Stack(
          children: [
            // ─────────────────────────────────────────────
            //  MAIN CONTENT (بيتعرض دايماً)
            // ─────────────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookInfo(context),
                      _buildDescription(context),
                      // بعد الـ Description مباشرة
                        ReadButton(book: book),
                      _buildMetaRow(context),
                      _buildSimilarSection(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),

            // ─────────────────────────────────────────────
            //  LOTTIE LOADING OVERLAY
            //  WHY: AnimatedSwitcher بيعمل fade transition
            //  ناعم بين الـ overlay وبين اختفاؤه
            // ─────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _ctrl.isLoadingSimilar.value
                  ? _LottieLoadingOverlay(key: const ValueKey('loading'))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SLIVER APP BAR — صورة الكتاب تملأ الشاشة بشكل سينمائي
  // ─────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      //backgroundColor: const Color(0xff0D0D0D),
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      actions: [
        // ── زر المفضلة في الـ AppBar ──
        Obx(() {
          final isFav = _sql.books.any((b) => b.id == book.id);
          return GestureDetector(
            onTap: () {
              if (isFav) { connectivityController.isConnected.value
                                  ? sql.deleteOnline(book.id, 'books') // لو متصل، امسحه من الموبايل والسيرفر
                                  : sql.deleteOffline(book, 'books'); // لو مش متصل، امسحه محلياً وسيتم مزامنته لاحقاً
                              }
              else {
                 connectivityController.isConnected.value?
                              sql.insertOnline(tableName: 'books', image: book.image, name: book.title, author: book.author, price: book.price, id: book.id)
                              :sql.insertdata(tableName: 'books', image: book.image, name: book.title, author: book.author, price: book.price, id: book.id);}
                
              
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.amber.withOpacity(0.9)
                    : Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // صورة الكتاب
            Hero(
              tag: book.id,
              child: CachedNetworkImage(
                imageUrl: book.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(color: Colors.grey),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xff1a1a2e),
                  child: const Icon(Icons.menu_book, size: 80, color: Colors.white24),
                ),
              ),
            ),
            // Gradient عشان الـ text يقرأ فوق الصورة
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xff0D0D0D)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BOOK INFO — العنوان والمؤلف والسعر
  // ─────────────────────────────────────────────────────────
  Widget _buildBookInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
               Icon(Icons.person_outline, color: context.iconColor, size: 16),
              const SizedBox(width: 4),
              Text(
                book.author.isNotEmpty ? book.author : '43'.tr,
                style: GoogleFonts.lato(fontSize: 14, color: context.textHint),
              ),
              const Spacer(),
              _PriceChip(price: book.price),
            ],
          ),
          if (book.category != null && book.category!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CategoryChip(category: book.category!),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  DESCRIPTION
  // ─────────────────────────────────────────────────────────
  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: '27'.tr),
          const SizedBox(height: 12),
          _ExpandableText(
            text: book.description ?? '41'.tr,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  AUTHOR + PUBLISHER ROW — قابلين للضغط
  // ─────────────────────────────────────────────────────────
  Widget _buildMetaRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _MetaCard(
              label: '28'.tr,
              value: book.author.isNotEmpty ? book.author : '29'.tr,
              icon: Icons.person,
              onTap: () => _navigateToResults(book.author),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetaCard(
              label: '30'.tr,
              value: book.publisher ?? '29'.tr,
              icon: Icons.business,
              onTap: () => _navigateToPublisher(book.publisher ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SIMILAR BOOKS — بتتعرض بعد اختفاء الـ overlay
  // ─────────────────────────────────────────────────────────
  Widget _buildSimilarSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(title: '31'.tr),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (_ctrl.isLoadingSimilar.value) {
              // Shimmer placeholder أثناء التحميل
              return _SimilarBooksShimmer();
            }

            if (_ctrl.similarBooks.isEmpty) {
              return  Padding(
                padding: EdgeInsets.all(20),
                child: Text('42'.tr,
                    style: TextStyle(color: Colors.white38)),
              );
            }

            return SizedBox(
              height: 405,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20),
                itemCount: _ctrl.similarBooks.length,
                itemBuilder: (context, i) {
                  final item = _ctrl.similarBooks[i];
                  return card(
                    map: item,
                    image: item.image,
                    name: item.title,
                    autherName: item.author,
                    price: item.price,
                    id: item.id,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToResults(String author) {
    Homecrt crt = Get.find();
    
    // 1. التجهيز (Setup State) - لازم يكون الأول
    crt.resetPagination();
    crt.searchQuery.value = author;
    crt.typeofmethod.value = LoadSource.author; 

    // 2. التنفيذ (Execution)
   Get.to(() => Results(genre: author));

    // 3. اطلب البيانات (ستحدث في الخلفية والـ Shimmer شغال)
    crt.fetchAuthors(author);
  }

  void _navigateToPublisher(String publisher) { Homecrt crt = Get.find();
    
    // 1. التجهيز (Setup State) - لازم يكون الأول
    crt.resetPagination();
    crt.searchQuery.value = publisher;
    crt.typeofmethod.value = LoadSource.publisher; 

    // 2. التنفيذ (Execution)
   Get.to(() => Results(genre: publisher));

    // 3. اطلب البيانات (ستحدث في الخلفية والـ Shimmer شغال)
    crt.fetchPublisher(publisher);
  }
}

// ============================================================
//  LOTTIE LOADING OVERLAY
//  WHY: Overlay شفاف فوق المحتوى — المستخدم يحس إن في حاجة
//  بتتحمل من غير ما يتنقل لصفحة تانية
// ============================================================
class _LottieLoadingOverlay extends StatelessWidget {
  const _LottieLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // نفس الـ Lottie animation اللي عندك في الـ splash
            Lottie.asset(
              'assets/animations/book.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading similar books...',
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  HELPER WIDGETS — صغيرة وقابلة لإعادة الاستخدام
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xff77094E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Expandable Description ──
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: Text(
          widget.text,
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(color: context.textHint, fontSize: 14, height: 1.6),
        ),
        secondChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: GoogleFonts.lato(color: context.textPrimary, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 4),
            Text('Show less',
                style: TextStyle(
                    color: const Color(0xff77094E), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Meta Card (Author / Publisher) ──
class _MetaCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _MetaCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff77094E), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:  TextStyle(color: context.textHint, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                        color: context.textHint, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Price Chip ──
class _PriceChip extends StatelessWidget {
  final String price;
  const _PriceChip({required this.price});

  @override
  Widget build(BuildContext context) {
    final isFree = price.contains('غير') || price.toLowerCase().contains('44'.tr.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.green.withOpacity(0.15)
            : const Color(0xff77094E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? Colors.green.withOpacity(0.4) : const Color(0xff77094E),
        ),
      ),
      child: Text(
        isFree ? 'Free' : price,
        style: TextStyle(
          color: isFree ? Colors.greenAccent : const Color(0xffC2185B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Category Chip ──
class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: Text(
        category,
        style:  TextStyle(color: context.textHint, fontSize: 12),
      ),
    );
  }
}

// ── Shimmer للـ Similar Books أثناء التحميل ──
class _SimilarBooksShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: 5,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}