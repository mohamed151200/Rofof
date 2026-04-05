import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


// ══════════════════════════════════════════════════════════
//
//  BookReaderScreen
//
//  3 سيناريوهات:
//  1. FULL_PUBLIC_DOMAIN → WebView جوا التطبيق (قراءة كاملة)
//  2. SAMPLE             → WebView للـ preview + زرار شراء
//  3. NONE               → شاشة تشرح الوضع + زرار فتح Google Books
//
// ══════════════════════════════════════════════════════════
class BookReaderScreen extends StatefulWidget {
  final BookModel book;
  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late final WebViewController? _webController;
 // final Sqlcrt _sql = Get.find();

  // ── State ──
  bool _isLoading       = true;
  bool _hasError        = false;
  double _loadProgress  = 0.0;
  bool _isFullscreen    = false;

  // ── ألوان ──
  
  

  @override
  void initState() {
    super.initState();

    // لو NONE مش محتاجين نعمل WebViewController خالص
    if (widget.book.readAccess == ReadAccess.none) {
      _webController = null;
      return;
    }

    _webController = _buildWebController();

    // حفظ الكتاب في Recent automatically لما يفتح
   
  }

  // ─────────────────────────────────────────────
  // _sql بناء الـ WebViewController بإعدادات كاملة
  // ─────────────────────────────────────────────
  WebViewController _buildWebController() {
    // اختيار الـ URL الصح:
    //   previewLink → URL بيفتح Google Books Viewer
    //   webReaderLink → URL لصفحة القراءة المباشرة
    // WHY webReaderLink أفضل لـ FULL لأنه بيفتح على أول صفحة مباشرة
    final url = (widget.book.readAccess == ReadAccess.full)
        ? (widget.book.webReaderLink ?? widget.book.previewLink ?? '')
        : (widget.book.previewLink   ?? widget.book.webReaderLink ?? '');

    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      // WHY: بنضيف User-Agent بتاع Chrome عشان Google Books
      // أحياناً بيرفض الـ default Flutter WebView agent
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )

      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() {
          _isLoading = true;
          _hasError  = false;
        }),
        onProgress: (p) => setState(() => _loadProgress = p / 100.0),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (_) => setState(() {
          _isLoading = false;
          _hasError  = true;
        }),

        // WHY: بنمنع الـ navigation لروابط تانية
        // عشان مايطلعش من شاشة القراءة غلط
        onNavigationRequest: (req) {
          if (req.url.contains('books.google.com') ||
              req.url.contains('play.google.com/books')) {
            return NavigationDecision.navigate;
          }
          // أي لينك تاني → افتحه في المتصفح الخارجي
          launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.bg,
        body: switch (widget.book.readAccess) {
          ReadAccess.full   => _buildWebView(isPreviewOnly: false),
          ReadAccess.sample => _buildWebView(isPreviewOnly: true),
          ReadAccess.none   => _buildNoAccessScreen(),
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WebView Screen (Full + Sample)
  // ─────────────────────────────────────────────
  Widget _buildWebView({required bool isPreviewOnly}) {
    return Column(
      children: [
        // ── AppBar مخصص ──
        _buildCustomAppBar(isPreviewOnly: isPreviewOnly),

        // ── Progress Bar ──
        if (_isLoading)
          LinearProgressIndicator(
            value           : _loadProgress > 0 ? _loadProgress : null,
            backgroundColor : Colors.white12,
            color           : mainColor,
            minHeight       : 2,
          ),

        // ── WebView أو Error ──
        Expanded(
          child: _hasError ? _buildErrorWidget() : WebViewWidget(controller: _webController!),
        ),

        // ── Banner للـ SAMPLE فقط ──
       // if (isPreviewOnly) _buildPreviewBanner(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Custom AppBar
  // ─────────────────────────────────────────────
  Widget _buildCustomAppBar({required bool isPreviewOnly}) {
    return Container(
      color: context.customBar  ,
      padding: EdgeInsets.only(
        top  : MediaQuery.of(context).padding.top + 8,
        left : 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          // زرار الرجوع
          IconButton(
            icon            : const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed       : () => Get.back(),
          ),

          // عنوان الكتاب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  maxLines : 1,
                  overflow : TextOverflow.ellipsis,
                  style    : GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPreviewOnly)
                  Text(
                    'Preview Only',
                    style: GoogleFonts.lato(color: Colors.orange, fontSize: 11),
                  ),
              ],
            ),
          ),

          // زرار Fullscreen
          IconButton(
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white70,
            ),
            onPressed: _toggleFullscreen,
          ),

          // زرار فتح في Browser
          IconButton(
            icon     : const Icon(Icons.open_in_browser, color: Colors.white70, size: 20),
            onPressed: _openInBrowser,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Banner "هذا Preview فقط" للـ Sample
  // ─────────────────────────────────────────────
  Widget _buildPreviewBanner() {
    return Container(
      width  : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color   : Colors.orange.withOpacity(0.12),
        border  : const Border(top: BorderSide(color: Colors.orange, width: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'هذا preview جزئي — لقراءة الكتاب كاملاً اشترِه من Google Books',
              style: GoogleFonts.lato(color: Colors.orange, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(widget.book.webReaderLink ?? widget.book.previewLink ?? ''),
              mode: LaunchMode.externalApplication,
            ),
            child: Container(
              padding   : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color        : Colors.orange,
                borderRadius : BorderRadius.circular(20),
              ),
              child: Text(
                'اشترِ الآن',
                style: GoogleFonts.lato(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  شاشة NONE — مش متاح للقراءة
  // ─────────────────────────────────────────────
  Widget _buildNoAccessScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon     : const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),

            const Spacer(),

            // Lock icon مع glow
            Container(
              width : 100, height: 100,
              decoration: BoxDecoration(
                shape   : BoxShape.circle,
                color   : mainColor.withOpacity(0.1),
                border  : Border.all(color: mainColor.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.lock_rounded, color: Colors.white54, size: 44),
            ),

            const SizedBox(height: 28),

            Text('45'.tr,
              style: GoogleFonts.playfairDisplay(
                color: context.textPrimary, fontSize: 22, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('48'.tr,
              textAlign: TextAlign.center,
              style    : GoogleFonts.lato(color: context.textHint, fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 40),

            // ── زرار Google Books ──
            _ActionButton(
              label  : '47'.tr,
              icon   : Icons.menu_book_rounded,
              color  : mainColor,
              onTap  : () => launchUrl(
                Uri.parse(
                  widget.book.previewLink ??
                  'https://books.google.com/books?id=${widget.book.id}',
                ),
                mode: LaunchMode.externalApplication,
              ),
            ),

            const SizedBox(height: 12),

            // ── زرار البحث عن نسخة مجانية ──
            _ActionButton(
              label  : '46'.tr,
              icon   : Icons.search_rounded,
              color  : const Color.fromARGB(0, 0, 0, 0),
              onTap  : () => launchUrl(
                Uri.parse(
                  'https://www.google.com/search?q=${Uri.encodeComponent(widget.book.title + " " + widget.book.author + " free pdf")}',
                ),
                mode: LaunchMode.externalApplication,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Error Widget لو الـ WebView فشل
  // ─────────────────────────────────────────────
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(Icons.wifi_off_rounded, color: context.iconColor, size: 64),
          const SizedBox(height: 16),
          Text(
           '49'.tr,
            style: GoogleFonts.playfairDisplay(color: context.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed : () => _webController?.reload(),
            icon      :  Icon(Icons.refresh, color:  context.textHint),
            label     : Text('50'.tr,
              style: GoogleFonts.lato(color: context.textHint)),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed : _openInBrowser,
            icon      : const Icon(Icons.open_in_browser, color: Color(0xff77094E)),
            label     : Text('51'.tr,
              style: GoogleFonts.lato(color: Color(0xff77094E))),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────
  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _openInBrowser() {
    final url = widget.book.webReaderLink
        ?? widget.book.previewLink
        ?? 'https://books.google.com/books?id=${widget.book.id}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    // إعادة الـ System UI لحالته الطبيعية لو كان Fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════
//  _ActionButton — زرار بسيط ومنظم
// ══════════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width      : double.infinity,
        padding    : const EdgeInsets.symmetric(vertical: 14),
        decoration : BoxDecoration(
          color        : color,
          borderRadius : BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
