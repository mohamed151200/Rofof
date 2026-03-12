import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/controller/api_controller.dart';
import 'package:the_dark_knight_final/module/results.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:the_dark_knight_final/module/book_details.dart';

// ═══════════════════════════════════════════════
//  الألوان — نفس باليت الـ app بتاعك
// ═══════════════════════════════════════════════
const _kPrimary = Color(0xff77094E);
const _kDark = Color(0xff0D0D12);
const _kCard = Color(0xff16161E);
const _kCardBorder = Color(0xff2A2A3A);

// ═══════════════════════════════════════════════
//  Greeting ذكي حسب الوقت
// ═══════════════════════════════════════════════
String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning 🌅';
  if (h < 17) return 'Good Afternoon ☀️';
  if (h < 21) return 'Good Evening 🌆';
  return 'Good Night 🌙';
}

// ═══════════════════════════════════════════════
//  بيانات كل category
// ═══════════════════════════════════════════════
const _categoryIcons = [
  Icons.palette_outlined,
  Icons.history_edu_outlined,
  Icons.code_outlined,
  Icons.science_outlined,
];

const _categoryAccents = [
  Color(0xffE91E63),
  Color(0xffE91E63),
  Color(0xffE91E63),
  Color(0xffE91E63),
];

// ═══════════════════════════════════════════════════════════════
//  HOMEPAGE
//  الفكرة: مش بنغير buildCategorySection في components.dart
//  بس بنلفها بـ _AnimatedSection اللي بيضيف:
//    1. Stagger entrance animation (fade + slide من أسفل)
//    2. Colored icon badge جنب العنوان
//    3. Featured Banner لأول كتاب
//    4. Shimmer skeleton وقت التحميل
//    5. FAB للرجوع لأعلى
// ═══════════════════════════════════════════════════════════════
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final Homecrt _crt = Get.find<Homecrt>();

  // ── Scroll ──
  final _scrollCtrl = ScrollController();
  bool _showFab = false;

  // ── Stagger: كل section ليه controller منفصل ──
  late final List<AnimationController> _anims;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  // ── Header fade-in عند أول تحميل ──
  late final AnimationController _headerAnim;

  List<String> _titles = ['3'.tr, '4'.tr, '5'.tr, '6'.tr];

  @override
  void initState() {
    super.initState();

    // 4 stagger controllers — واحد لكل section
    _anims = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );

    _fades = _anims
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _slides = _anims
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _startStagger();

    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 350;
      if (show != _showFab) setState(() => _showFab = show);
    });
  }

  // كل section يظهر بعد السابق بـ 130ms — ده الـ stagger
  void _startStagger() async {
    for (int i = 0; i < _anims.length; i++) {
      await Future.delayed(Duration(milliseconds: 150 + 130 * i));
      if (mounted) _anims[i].forward();
    }
  }

  @override
  void dispose() {
    // WHY: لازم dispose كل AnimationController عشان مفيش memory leak
    for (final c in _anims) c.dispose();
    _headerAnim.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
     // backgroundColor: _kDark,

      // ── زر الرجوع لأعلى يظهر بعد scroll 350px ──
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: FloatingActionButton.small(
            backgroundColor: _kPrimary,
            onPressed: () => _scrollCtrl.animateTo(
              0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
            child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
          ),
        ),
      ),

      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Sticky Header ──
          //_buildSliverHeader(),

          // ── 2. Featured Book Banner ──
          SliverToBoxAdapter(child: _buildFeaturedBanner()),

          // ── 3. الـ 4 Categories مع Stagger Animation ──
          for (int i = 0; i < 4; i++)
            SliverToBoxAdapter(
              child: _AnimatedSection(
                fadeAnim: _fades[i],
                slideAnim: _slides[i],
                // ─────────────────────────────────────────
                //  هنا بنلف buildCategorySection الموجودة
                //  بـ _PremiumHeader + _CategoryBodyOnly
                //  WHY: مش بنغير components.dart خالص
                //  بس بنقسم الـ section لجزئين:
                //    - header جديد احترافي (icon + title)
                //    - body نفسه بالظبط (card widget)
                // ─────────────────────────────────────────
                child: Obx(() {
                  final books = _getBooks(i);

                  if (books.isEmpty) {
                    return _SectionShimmer(
                      title: _titles[i],
                      icon: _categoryIcons[i],
                      accent: Color(0xffE91E63),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PremiumHeader(
                        title: _titles[i],
                        icon: _categoryIcons[i],

                        
                        accent: _categoryAccents[i],
                      ),
                      _CategoryBodyOnly(books: books),
                      // Divider خفيفة بين الـ sections
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Container(
                          height: 1,
                          color: Get.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ],  
                  );
                }),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SLIVER HEADER
  // ─────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: _kDark,
      expandedHeight: 115,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: FadeTransition(
          opacity: _headerAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: GoogleFonts.lato(
                  fontSize: 10,
                  color: Colors.white38,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Discover Books',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient glow في الكورنر
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_kPrimary.withOpacity(0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _kDark],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kCardBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white70, size: 20),
              onPressed: () => Get.find<Homecrt>().changeIndex(1),
              tooltip: 'Search',
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  FEATURED BANNER — أول كتاب في Art
  // ─────────────────────────────────────────────
  Widget _buildFeaturedBanner() {
    return Obx(() {
      if (_crt.art.isEmpty) return _FeaturedShimmer();

      final book = _crt.art.first;

      return GestureDetector(
        onTap: () => Get.to(
          () => BookDetails(book),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 400),
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: book.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: _kCard),
                  errorWidget: (_, __, ___) => Container(color: _kCard),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.88),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Hero(
                        tag: book.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: book.image,
                            width: 82,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // FEATURED badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _kPrimary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '25'.tr,
                                style: GoogleFonts.lato(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.title,
                              maxLines: 3,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author.isNotEmpty ? book.author : 'Unknown',
                              maxLines: 1,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '26'.tr,
                                    style: GoogleFonts.lato(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List _getBooks(int i) {
    switch (i) {
      case 0:
        return _crt.art;
      case 1:
        return _crt.history;
      case 2:
        return _crt.programming;
      case 3:
        return _crt.science;
      default:
        return [];
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  _AnimatedSection — Wrapper للـ fade + slide
// ═══════════════════════════════════════════════════════════════
class _AnimatedSection extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Widget child;

  const _AnimatedSection({
    required this.fadeAnim,
    required this.slideAnim,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  _PremiumHeader — بيستبدل العنوان البسيط في buildCategorySection
// ═══════════════════════════════════════════════════════════════
class _PremiumHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Homecrt _crt = Get.find<Homecrt>();

  _PremiumHeader({
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              /* final genreQuery = switch (title) {
                'Art'||'فن' => '3'.tr,
                'History'||'تاريخ' => 'history',
                'Programming'||'برمجة' => 'programming',
                'Science'||'علوم' => 'physics',
                _ => title.toLowerCase(),
              }; */
                 crt.resetPagination();
                crt.searchQuery.value = title;
                 crt.typeofmethod.value = LoadSource.genre;
                  Get.to(() => Results( genre: title));
              // حمّل الكتب وروح لـ Results
              crt.loadGenreBooks(title);
            },
            child: Row(
              children: [
                Text(
                  '33'.tr,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: accent, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  _CategoryBodyOnly
//  بتعرض الـ ListView بس من غير العنوان
//  لأن _PremiumHeader اتحط فوقه
//  وبتستخدم نفس الـ card widget الموجودة في components.dart
// ═══════════════════════════════════════════════════════════════
class _CategoryBodyOnly extends StatelessWidget {
  final List books;
  const _CategoryBodyOnly({required this.books});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        itemCount: books.length,
        itemBuilder: (context, i) {
          final item = books[i];
          // ← نفس الـ card بتاعت components.dart بالظبط
          return card(
            map: item,
            image: item.image,
            name: item.title,
            autherName: item.author,
            price: item.price,
            id: item.id ?? '',
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHIMMER WIDGETS
// ═══════════════════════════════════════════════════════════════
class _SectionShimmer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;

  const _SectionShimmer({
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Icon(icon, color: accent.withOpacity(0.4), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16),
            itemCount: 5,
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: _kCard,
              highlightColor: _kCardBorder,
              child: Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _kCard,
      highlightColor: _kCardBorder,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        height: 190,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
