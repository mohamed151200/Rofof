
import 'package:cloud_firestore/cloud_firestore.dart';
class BookModel {
  final String id;
  final String title;
  final String author;
  final String image;
  final String price;
  final String? category;
  final String? description;
  final String? publisher;
  final String? genre;
  final int? isnotsync;
  final int? isDeleted;
  final int? timestamp;

  

  
  

  // ══════════════════════════════════════════
  //  حقول القراءة الجديدة من accessInfo
  // ══════════════════════════════════════════

  /// مستوى الوصول للقراءة
  /// القيم الممكنة من Google Books API:
  ///   FULL_PUBLIC_DOMAIN → الكتاب كامل ومجاني (Public Domain)
  ///   SAMPLE             → preview جزئي فقط
  ///   NONE               → ممنوع القراءة (مدفوع أو محظور)
  final String accessViewStatus;

  /// رابط WebReader من Google Books
  /// شغال دايماً لو accessViewStatus مش NONE
  final String? webReaderLink;

  /// رابط Preview (للـ embedded viewer أو WebView)
  /// موجود في volumeInfo.previewLink
  final String? previewLink;

  /// هل الكتاب في الـ Public Domain؟
  final bool isPublicDomain;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.image,
    required this.price,
    this.category,
    this.description,
    this.publisher,
    this.genre,
    // قيم افتراضية للحقول الجديدة عشان fromMap مش بيجي من API
    this.accessViewStatus = 'NONE',
    this.webReaderLink,
    this.previewLink,
    this.isPublicDomain = false, this.isnotsync, this.isDeleted, this.timestamp,
  });

  // ──────────────────────────────────────────
  //  Helper — بيحدد إيه الـ action المناسب
  // ──────────────────────────────────────────
  /// FULL  → قراءة كاملة جوا التطبيق (WebView)
  /// SAMPLE → preview جوا التطبيق + زرار شراء
  /// NONE   → فتح Google Books خارجياً بس
  ReadAccess get readAccess {
    if (isPublicDomain || accessViewStatus == 'FULL_PUBLIC_DOMAIN') {
      return ReadAccess.full;
    }
    if (accessViewStatus == 'SAMPLE') {
      return ReadAccess.sample;
    }
    return ReadAccess.none;
  }

  factory BookModel.  fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final saleInfo   = json['saleInfo']   ?? {};
    final accessInfo = json['accessInfo'] ?? {}; // ← الجديد

    return BookModel(
      id    : json['id'] ?? '',
      title : volumeInfo['title'] ?? 'عنوان غير معروف',
      author: (volumeInfo['authors'] != null)
          ? volumeInfo['authors'][0]
          : 'Unknown Author',
      image : (volumeInfo['imageLinks'] != null)
          ? volumeInfo['imageLinks']['thumbnail'].replaceFirst('http', 'https')
          : 'https://via.placeholder.com/150',
      price : (saleInfo['saleability'] == 'FOR_SALE')
          ? '${saleInfo['listPrice']['amount']} ${saleInfo['listPrice']['currencyCode']}'
          : 'غير متاح للبيع',
      category   : volumeInfo['categories']?[0] ?? 'غير مصنف',
      description: volumeInfo['description'] ?? 'No description available.',
      publisher  : volumeInfo['publisher'] ?? 'غير معروف',

      // ── حقول القراءة ──
      accessViewStatus: accessInfo['accessViewStatus'] ?? 'NONE',
      webReaderLink   : accessInfo['webReaderLink'],
      previewLink     : volumeInfo['previewLink'],
      isPublicDomain  : accessInfo['publicDomain'] ?? false,
      isnotsync: 1,
      isDeleted: 0,
    );
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id         : map['id'].toString(),
      title      : map['name'].toString(),
      author     : map['author']?.toString()      ?? 'Unknown Author',
      image      : map['image']?.toString()       ?? 'https://via.placeholder.com/150',
      price      : map['price']?.toString()       ?? 'Free',
      category   : map['category']                ?? 'General',
      description: map['description']             ?? '',
      publisher  : map['publisher']               ?? 'غير معروف',
      // fromMap بييجي من الداتابيز المحلية — مش بنحفظ accessInfo فيها
      accessViewStatus: 'NONE',
      isnotsync: map['isnotsync'] ?? 1,
      isDeleted: map['is_deleted'] ?? 0,
      timestamp: map['timestamp'] ?? 0,

    );
  }
  // جوه الـ toMap() في الـ Model بتاعك
Map<String, dynamic> toMap(String currentGenre) { // بنمرر الـ genre هنا
  return {
    'id': id,
    'image': image,
    'name': title,
    'author': author,
    'price': price,
    'genre': currentGenre, 
    

  };
}
Map<String, dynamic> toFirebaseMap() { // بنمرر الـ genre هنا
  return {
    'id': id,
    'image': image,
    'name': title,
    'author': author,
    'price': price,
     
    'updated_at':FieldValue.serverTimestamp(),
    'is_deleted': false,


  };
}

}

/// enum واضح بدل مقارنة الـ Strings في كل مكان
enum ReadAccess { full, sample, none }
