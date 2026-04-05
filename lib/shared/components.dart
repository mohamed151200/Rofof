import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/auth/ui/book_reader.dart';
import 'package:the_dark_knight_final/controller/connectivity_controller.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/api_controller.dart';
import '../controller/sql_controller.dart';
import '../module/book_details.dart';

Homecrt crt = Get.put(Homecrt());
Sqlcrt sql = Get.put(Sqlcrt());
ConnectivityController connectivityController = Get.put(ConnectivityController());
Color mainColor =  Color.fromARGB(255, 142, 13, 95);



Widget buildCategorySection(BuildContext context, String title, List books) {
    if (books.isEmpty) return const SizedBox.shrink(); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
        ),
        SizedBox(
          height: 380, // قللت الارتفاع شوية عشان يكون متناسق
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16),
            itemCount: books.length,
            itemBuilder: (context, i) {
              var item = books[i];
              return card(
                map: item,
                image: item.image,
                name: item.title,
                autherName: item.author,
                price: item.price,
                id: item.id ?? "",
              );
            },
          ),
        ),
      ],
    );
  }

var lst = [];
Future<dynamic> _awesome(BuildContext context,Color c,String title,String desc) {
  return AwesomeDialog(
      context: context, 
      dialogType: DialogType.success,
      title: title,
      desc: desc,
      btnOkColor: c,
      btnOkOnPress: () {},
    ).show();
}

Widget myField({
  required BuildContext context,
  required String label,
  var prefix,
  var ontap,
  required TextEditingController controller,
  required TextInputType type,
  required String? Function(String?)? validate,
  required bool isReadonly,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      decoration: InputDecoration(
          label: Text(label),
          prefix: prefix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      controller: controller,
      onTap: ontap,
      readOnly: isReadonly,
      validator: validate!,
    ),
  );
}


class card extends StatelessWidget { 
  final String image;
  final String name;
  final String autherName;
  final String price;
  final String? id;
  final BookModel map;

  // 2. بنستدعي الـ SQL Controller اللي عملنا له put في الـ main
  final Sqlcrt sql = Get.find();

    card({
    Key? key,
    required this.image,
    required this.name,
    required this.autherName,
    required this.price,
    this.id,
     required this.map,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        crt.fetchAuthors(map.author).then((value)
            {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetails(map)));

            });
        
      },
      
      child: Container(
         width: 150,
         height: 390,
         
      
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          //color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
      
    ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // يخلي الكولوم ياخد مساحة اللي جواه بس
          children: [
             ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)
              ,bottom: Radius.circular(15)),
              child:
            Hero(
              tag: id!,
              child: CachedNetworkImage(
  imageUrl: image,
  height: 230,
  width: double.infinity,
  fit: BoxFit.cover,

  // 1. معالجة التحميل (بديل loadingBuilder)
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
    ),),

  // 2. معالجة الخطأ (بديل errorBuilder)
  errorWidget: (context, url, error) => Container(
    height: 250,
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
  ),

  // 3. تحسين الأداء (The Senior Move)
  // ده بيخلي الذاكرة "تشيل" نسخة مصغرة من الصورة على قد الكارت بس
  memCacheHeight: 400, 
  memCacheWidth: 300,
)
                   )   
                      ),
                      

            
            Text(
              textAlign: TextAlign.center,
              name,
              maxLines: 2,
              style:  GoogleFonts.playfairDisplay(
                          color     : context.textPrimary,
                          fontSize  : 15,
                          fontWeight: FontWeight.w600,
                          height    : 1.3,

                        ),
            ),
            Text(
              textAlign: TextAlign.center,
             autherName,
              maxLines: 1,
              style:GoogleFonts.playfairDisplay(
                          color     : context.textHint,
                          fontSize  : 13,
                          fontWeight: FontWeight.w600,
                          height    : 1.3,
                        ),
              
            ),
           

            // 3. هنا "الزتونة": الـ Obx بتراقب التغيير في لستة الـ SQL
            Obx(() {
              // بنشوف هل الـ id بتاع الكتاب ده موجود في اللستة الـ Observable؟
              bool isFavorite = sql.books.any((element) => element.id == id);

              return IconButton(
                onPressed: (){
                            if (isFavorite) {
                              connectivityController.isConnected.value
                                  ? sql.deleteOnline(id!, 'books') // لو متصل، امسحه من الموبايل والسيرفر
                                  : sql.deleteOffline(map, 'books'); // لو مش متصل، امسحه محلياً وسيتم مزامنته لاحقاً
                             
                            } else {
                               connectivityController.isConnected.value?
                              sql.insertOnline(tableName: 'books', image: image, name: name, author: autherName, price: price, id: id!)
                              :sql.insertdata(tableName: 'books', image: image, name: name, author: autherName, price: price, id: id!);

      
                            }
                          },
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                color: isFavorite ? mainColor : Colors.grey,
              );
            }),
          ]),
        ));
      
    
  }   
}
class searchPageCard extends StatelessWidget { 
  final String image;
  final String name;
  final String autherName;
  final String price;
  final String? id;
  final BookModel map;
    final Sqlcrt sql = Get.find();


  // 2. بنستدعي الـ SQL Controller اللي عملنا له put في الـ main
  

  searchPageCard({
    Key? key,
    required this.image,
    required this.name,
    required this.autherName,
    required this.price,
    this.id,
     required this.map,
  }) : super(key: key);

  @override
 Widget build(BuildContext context) {
  return InkWell(
   onTap: () {
        Get.to( () => BookDetails(map));
        
      },
    child: Container(
      color: context.surface,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // مسافة حوالين الكارت كله
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // يخلي الكلام يبدأ من فوق مع الصورة
          children: [
            // 1. الجزء الخاص بالصورة (تحكم كامل في الأبعاد)
            SizedBox(
              width: 100,  // العرض اللي أنت عاوزه
              height: 150, // الارتفاع اللي يظهر غلاف الكتاب بوضوح
              child:ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Hero(
      tag: id!,
      child: CachedNetworkImage(
        imageUrl      : image,
        fit           : BoxFit.cover,       // cover أحسن من fill
        width         : double.infinity,
        height        : double.infinity,
      
        // ✅ Shimmer شغال 100%
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor     : const Color(0xff1C1C1E), // dark theme
          highlightColor: const Color(0xff2a2a3a),
          child: Container(color: const Color(0xff1C1C1E)),
        ),
      
        errorWidget: (context, url, error) => Container(
          color: const Color(0xff1a1a2e),
          child: const Icon(Icons.menu_book, color: Colors.white24, size: 28),
        ),
      ),
        ),
      ),
            ),
            
            const SizedBox(width: 16), // مسافة بين الصورة والكلام
      
            // 2. الجزء الخاص بالكلام (ياخد باقي عرض الشاشة)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.caveat(fontSize: 22, color: context.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    autherName,
                    maxLines: 1,
                    style: GoogleFonts.caveat(fontSize: 18, color: context.textHint),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.caveat(fontSize: 20, color: Colors.indigoAccent, fontWeight: FontWeight.bold),
                      ),
                      // زر النجمة
                      Obx(() {
                        bool isFavorite = sql.books.any((element) => element.id == id);
                        return IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              connectivityController.isConnected.value
                                  ? sql.deleteOnline(id!, 'books') // لو متصل، امسحه من الموبايل والسيرفر
                                  : sql.deleteOffline(map, 'books'); // لو مش متصل، امسحه محلياً وسيتم مزامنته لاحقاً
                             
                            } else {
                               connectivityController.isConnected.value?
                              sql.insertOnline(tableName: 'books', image: image, name: name, author: autherName, price: price, id: id!)
                              :sql.insertdata(tableName: 'books', image: image, name: name, author: autherName, price: price, id: id!);

      
                            }
                          },
                          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                          color: isFavorite ? Colors.yellow : Colors.grey,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}


TextStyle fontStyle = GoogleFonts.caveat(
  fontSize: 30,
  color: Colors.black,
  fontWeight: FontWeight.bold,
);
class ReadButton extends StatelessWidget {
  final BookModel book;
  const ReadButton({super.key, required this.book});

  static const _kPrimary = Color(0xff77094E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: switch (book.readAccess) {

        // ── قراءة كاملة مجانية ──
        ReadAccess.full => _ReadBtn(
          label    : 'اقرأ الآن — مجاناً',
          subtitle : 'كتاب متاح للجميع',
          icon     : Icons.menu_book_rounded,
          gradient : const [Color(0xff1a7a4a), Color(0xff0d5c36)],
          badge    : 'مجاني',
          badgeColor: Colors.green,
          onTap    : () => Get.to(
            () => BookReaderScreen(book: book),
            transition: Transition.downToUp,
            duration  : const Duration(milliseconds: 400),
          ),
        ),

        // ── Preview جزئي ──
        ReadAccess.sample => _ReadBtn(
          label    : '36'.tr,
          subtitle : '',
          icon     : Icons.auto_stories_outlined,
          gradient : const [Color(0xffb35c00), Color(0xff7a3d00)],
          badge    : '37'.tr,
          badgeColor: Colors.orange,
          onTap    : () => Get.to(
            () => BookReaderScreen(book: book),
            transition: Transition.downToUp,
            duration  : const Duration(milliseconds: 400),
          ),
        ),

        // ── غير متاح ──
        ReadAccess.none => _ReadBtn(
          label    :'40'.tr,
          subtitle : '39'.tr,
          icon     : Icons.open_in_new_rounded,
          gradient : const [Color(0xff2a2a3a), Color(0xff1a1a2a)],
          badge    : '38'.tr,
          badgeColor: Colors.grey,
          onTap    : () => Get.to(
            () => BookReaderScreen(book: book),
            transition: Transition.downToUp,
            duration  : const Duration(milliseconds: 400),
          ),
        ),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _ReadBtn — الزرار نفسه
// ══════════════════════════════════════════════════════════
class _ReadBtn extends StatelessWidget {
  final String       label;
  final String       subtitle;
  final IconData     icon;
  final List<Color>  gradient;
  final String       badge;
  final Color        badgeColor;
  final VoidCallback onTap;

  const _ReadBtn({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding   : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient     : LinearGradient(
            colors: gradient,
            begin : Alignment.topLeft,
            end   : Alignment.bottomRight,
          ),
          borderRadius : BorderRadius.circular(18),
          boxShadow    : [
            BoxShadow(
              color  : gradient[0].withOpacity(0.35),
              blurRadius  : 16,
              offset      : const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              width : 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),

            // Label + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Badge
            Container(
              padding   : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color        : badgeColor.withOpacity(0.2),
                borderRadius : BorderRadius.circular(20),
                border       : Border.all(color: badgeColor.withOpacity(0.5)),
              ),
              child: Text(
                badge,
                style: GoogleFonts.lato(
                  color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
// بدل ما تكرر Theme.of(context) في كل مكان
extension ThemeX on BuildContext {
  Color get bg      => Theme.of(this).scaffoldBackgroundColor;
  Color get surface => Theme.of(this).cardColor;
  Color get border  => Theme.of(this).dividerColor;
  /* Color get textPrimary   => Theme.of(this).colorScheme.onSurface;
  Color get textSecondary => Theme.of(this).hintColor; */
  bool  get isDark  => Theme.of(this).brightness == Brightness.dark;
  //__________________________________________________________________
  Color get textPrimary   => isDark ? Colors.white        : Colors.black;
  Color get textSecondary => isDark ? Colors.white70      : Colors.black87;
  Color get textHint      => isDark ? Colors.white38      : Colors.black45;
  Color get textFaint     => isDark ? Colors.white24      : Colors.black26;
  Color get textGhost     => isDark ? Colors.white12      : Colors.black12;
  Color get customBar     => isDark ? Colors.black      : mainColor;
}
 Widget buildConnectivityStatus() {
  final connectivityController = Get.find<ConnectivityController>();

  return Obx(() {
    bool isConnected = connectivityController.isConnected.value;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: isConnected
          ? _buildOnlineStatus() // يعرض حالة "متصل" ثم يختفي
          : _buildOfflineStatus(), // يظل ثابتاً في حالة "غير متصل"
    );
  });
}

// 1. واجهة الأوفلاين (ثابتة)
Widget _buildOfflineStatus() {
  return const SizedBox(
    width: 100, // تحديد عرض مناسب للـ AppBar actions
    child: ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.wifi_off, color: Colors.amber, size: 20),
      title: Text(
        "غير متصل",
        style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// 2. واجهة الأونلاين (تظهر لثوانٍ ثم تختفي)
Widget _buildOnlineStatus() {
  // استخدام FutureBuilder لإخفاء الويدجيت بعد 3 ثوانٍ
  return FutureBuilder(
    future: Future.delayed(const Duration(seconds: 3)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return const SizedBox.shrink(); // تختفي بعد 3 ثوانٍ
      }
      return const SizedBox(
        width: 115,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle, color: Colors.green, size: 20),
          title: Text(
            "أنت الآن متصل",
            style: TextStyle(color: Colors.green, fontSize: 11),
          ),
        ),
      );
    },
  );

}

 