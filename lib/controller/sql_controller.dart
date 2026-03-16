import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:the_dark_knight_final/auth/controller/auth_controller.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Sqlcrt extends GetxController {
  // late Database database;
  var fv = false.obs;
  var fiv = Icons.star_border.obs;
  Database? _database;
  var books = [].obs;
  var recentBooks = [].obs;
  //______________________________
  
  //String uid = Get.find<ShowPasswordController>().currentUserId;


  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() async {
    createdata();
    // حمل البيانات المحلية الأول عشان اليوزر ميبصش على شاشة فاضية
    await getData(database, 'books');

    // بعد ما الداتا تظهر، ابدأ المزامنة في الخلفية براحتك
    await syncMaster();
    await fetchFromCloud();
  }

  change_Icone(fv) {
    fv = !fv;

    return fv;
  }

  // 1. المتغير nullable وبدون late

  // 2. الـ Getter السحري (هو اللي بيضمن الانتظار)
  Future<Database> get database async {
    if (_database != null) return _database!;

    // لو مش موجودة، هننادي ميثود الفتح ونستناها
    _database = await createdata();
    return _database!;
  }

  // 3. تعديل الميثود لتصبح Future<Database> بدلاً من void
  Future<Database> createdata() async {
    String path = join(await getDatabasesPath(), 'books.db');

    // نرجع نتيجة الـ openDatabase مباشرة
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
    CREATE TABLE books (
      id TEXT PRIMARY KEY, 
      image TEXT, 
      name TEXT, 
      author TEXT, 
      price TEXT,
      isnotsync INTEGER DEFAULT 1,
      is_deleted INTEGER DEFAULT 0,
      timestamp INTEGER
    )''');

        await db.execute(
          'CREATE TABLE recentBooks (id TEXT PRIMARY KEY, image TEXT, name TEXT, author TEXT, price TEXT, genre TEXT)',
        );
      },
      onOpen: (db) async {
        // هنا ممكن تحمل البيانات المبدئية لو حابب
        // print("Database Opened!");
      },
    );
  }

  getData(Future<Database> database, String tableName) async {
    final db = await database;

    var result = await db.rawQuery(
      'SELECT * FROM $tableName WHERE is_deleted = 0 OR is_deleted IS NULL',
    );
    books.value = result.map((e) => BookModel.fromMap(e)).toList();
    books.refresh();
    // print('📚 Favorites loaded: ${result.length}');
    /* 
    } else if (tableName == 'recentBooks') {
      var result = await database.rawQuery("SELECT * FROM recentBooks ORDER BY timestamp DESC");
      recentBooks.value = result;
      print('🕒 Recent books loaded: ${result.length}');
    } */
    //print('$tableName data loaded: ${result.length}');
  }

  void insertdata({
    //offline
    String? tableName,
    String? image,
    String? name,
    String? author,
    String? price,
    String? id,
    String? genre,
  }) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.insert(
          'books',
          {
            'id': id,
            'image': image,
            'name': name,
            'author': author,
            'price': price,
            'isnotsync': 1,
            'is_deleted': 0,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          // هذا السطر هو السحر: لو الكتاب موجود، هيحدث بياناته بدل ما يطلع إيرور
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      // تحديث البيانات بعد النجاح
      await getData(database, tableName!);
    } catch (e) {
      //print('❌ SQL Error: ${e.toString()}');
    }
  }

  void insertOnline({
    //offline
    String? tableName,
    String? image,
    String? name,
    String? author,
    String? price,
    String? id,
    String? genre,
  }) async {
    final db = await database;
    Map<String, dynamic> bookData = {
      'id': id,
      'image': image,
      'name': name,
      'author': author,
      'price': price,
      'isnotsync': 0, // نبدأ دايماً كـ "غير متزامن"
      'is_deleted': 0, // مش محذوف
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // الخطوة 1: الحفظ المحلي فوراً (السرعة هي الأولوية)
    try {
      await db.insert(
        'books',
        bookData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      //print('❌ SQL Error: ${e.toString()}');
      }

      // تحديث الشاشة فوراً (اليوزر شاف الكتاب خلاص)
      getData(database, 'books');
      // print('📱 [Step 1] تم الحفظ في الموبايل وتحديث الشاشة');

      // الخطوة 2: محاولة الرفع للسيرفر في الخلفية
      try {
        String uid = Get.find<ShowPasswordController>().currentUserId;
        ///print('____________________${uid}');
        await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('books')
        .doc(id)
        .set({
          'id': id,
          'image': image,
          'name': name,
          'author': author,
          'price': price,
          'is_deleted': 0, // مش محذوف
          'timestamp': DateTime.now().millisecondsSinceEpoch, // وقت الإدراج
        }, SetOptions(merge: true));

        // الخطوة 3: لو نجح الرفع، نعدل الحالة في الموبايل لـ "متزامن"
        await db.update(
          'books',
          {'isnotsync': 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        ///print('⚠️ {$e}[Step 2] فشل الرفع للسيرفر، هيفضل "غير متزامن" حالياً');
      }
    }
  

  void deleteOffline(BookModel book, String tableName) async {
    // 1. تحديث الشاشة فوراً
    books.removeWhere((b) => b.id == book.id);
    update();

    final db = await database;

    // 🎯 التعديل الجوهري هنا:
    // بنجيب الكتاب من الليست الأساسية قبل ما نحذفها أو بنعتمد على الـ ID بتاعه
    // بس الأدق إننا نشيك في الداتا بيز مباشرة أو نمرر الحالة صح

    // خليني أقولك الطريقة الأضمن (قراءة القيمة من الداتا بيز مباشرة قبل القرار):
    List<Map<String, dynamic>> currentBook = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [book.id],
    );

    if (currentBook.isEmpty) return; // لو مش موجود أصلاً

    int currentSyncStatus = currentBook.first['isnotsync'];

    // 2. الفحص الذكي بناءً على القيمة الحقيقية من الداتا بيز
    if (currentSyncStatus == 1) {
      await db.delete(tableName, where: 'id = ?', whereArgs: [book.id]);
      // print('🗑️ [Local] تم حذفه نهائياً من الـ DB لأنه لم يرفع للسيرفر');
      return;
    }

    // 3. لو الكتاب موجود على السيرفر (currentSyncStatus == 0)
    await db.update(
      tableName,
      {
        'is_deleted': 1,
        'isnotsync': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );

    //print('📍 [Cloud-Bound] تم تحديث حالته للمسح في السيرفر لاحقاً');
  }

  Future<void> deleteOnline(String id, String tableName) async {
    // print('_______________${books[0].isnotsync}');
    final db = await database;

    try {
      String uid = Get.find<ShowPasswordController>().currentUserId;
      // 1. محاولة الحذف من فايربيز (Hard Delete)
      await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('books')
      .doc(id)
      .delete();

    //  print('☁️ [Cloud] تم الحذف من السيرفر بنجاح');

      // 2. بما إن السيرفر مسحه، نمسحه نهائياً من الـ SQL (Hard Delete)
      // مفيش داعي نسيبه بـ is_deleted = 1 خلاص
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
      ///print('🗑️ [Local] تم تنظيف القاعدة المحلية نهائياً');
    } catch (e) {
      // لو النت فصل هنا، الكتاب هيفضل في الـ SQL وقيمته is_deleted = 1
      // والـ Sync Master هيحاول يمسحه تاني لما النت يرجع
      ///print('⚠️ [Cloud] فشل الحذف أونلاين: ${e.toString()}');
    }

    // تحديث البيانات في الـ UI
    getData(database, tableName);
  }

  // عدل الميثود لتستقبل الـ query
  Future<void> clearCategoryData(String query) async {
    final db = await database;
    await db.delete(
      'recentBooks',
      where: 'genre = ?', // امسح بس الكتب اللي في نفس القسم
      whereArgs: [query],
    );
  }

  Future<void> saveToOffline(List items, String query) async {
    final db = await database;
    var batch = db.batch();

    for (var item in items) {
      final volumeInfo = item['volumeInfo'] ?? {};
      final saleInfo = item['saleInfo'] ?? {};

      // التعامل مع الصورة بطريقة أنضف وتجنب التكرار
      String imageUrl = 'https://via.placeholder.com/150';
      if (volumeInfo['imageLinks'] != null &&
          volumeInfo['imageLinks']['thumbnail'] != null) {
        imageUrl = volumeInfo['imageLinks']['thumbnail'].replaceFirst(
          'http:',
          'https:',
        );
      }

      batch.insert('recentBooks', {
        'id': item['id'], // الـ Primary Key
        'image': imageUrl,
        'name': volumeInfo['title'] ?? 'عنوان غير معروف',
        'author':
            (volumeInfo['authors'] != null &&
                (volumeInfo['authors'] as List).isNotEmpty)
            ? volumeInfo['authors'][0]
            : 'Unknown Author',
        'price':
            (saleInfo['saleability'] == 'FOR_SALE' &&
                saleInfo['listPrice'] != null)
            ? '${saleInfo['listPrice']['amount']} ${saleInfo['listPrice']['currencyCode']}'
            : 'غير متاح للبيع',
        'genre': query,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    //print("تم الحفظ في القاعدة بنجاح يا سنيور! 🍓🚀");
  }

  Future<List<BookModel>> fetchFromOffline(String query) async {
    final db = await database;

    // 1. تنفيذ الـ Query مع الفلتر والترتيب
    final List<Map<String, dynamic>> maps = await db.query(
      'recentBooks',
      where: 'genre = ?', // بنفلتر بالـ genre
      whereArgs: [
        query,
      ], // بنبعت الـ query هنا عشان نحمي الداتا من الـ SQL Injection
      // أو استخدم 'timestamp DESC' لو عندك العمود ده فعلاً
    );
    ///print(maps[2]);
    // 2. تحويل الـ Maps لـ Objects عشان الـ UI يفهمها
    if (maps.isNotEmpty) {
      return maps.map((bookMap) {
        return BookModel(
          id: bookMap['id'],
          title: bookMap['name'],
          image: bookMap['image'],
          author: bookMap['author'],
          price: bookMap['price'],
          // بنرجع الداتا للموديل بتاعك زي ما الـ API كان بيبعتها بالظبط
        );
      }).toList();
    }

    return []; // لو مفيش داتا متخزنة للـ genre ده
  }

  Future<void> addBookToFirestore(Map<String, dynamic> book) async {
    // كتابة الـ ID الخاص بـ Google API داخل الـ doc()
    await FirebaseFirestore.instance
        .collection('books')
        .doc(book['id']) // هنا نضع الـ ID القادم من Google API
        .set(book, SetOptions(merge: true));
  }

  // 1. جلب كل السجلات التي لم يتم مزامنتها
  Future<void> syncMaster() async {
    final db = await database;
    // print('${books.length} ___________ ${books[0].isnotsync} ___________ ${books[0].isDeleted}');

    // 1. هات كل الكتب اللي محتاجة مزامنة (سواء إضافة أو حذف)
    List<Map<String, dynamic>> pendingSync = await db.query(
      'books',
      where: 'isnotsync = ?',
      whereArgs: [1],
    );

  final String? uid = FirebaseAuth.instance.currentUser?.uid;


    if (pendingSync.isEmpty) {
      //print("✨ لا يوجد بيانات تحتاج للمزامنة");
      return;
    }

    for (var record in pendingSync) {
      String id = record['id'];

      try {
        // 🎯 الحالة الأولى: الكتاب محذوف محلياً (وموجود ع الكلاود)
        // is_deleted == 1 && isnotsync == 1
        if (record['is_deleted'] == 1) {
          // امسح من فايربيز الأول
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('books')
              .doc(id)
              .delete();

          // لو نجح، نظف اللوكال داتا بيز نهائياً
          await db.delete('books', where: 'id = ?', whereArgs: [id]);
          // print('☁️🗑️ تم المزامنة: حذف نهائي من السيرفر والموبايل لـ $id');
        }
        // 🎯 الحالة الثانية: الكتاب تمت إضافته محلياً (ومش ع الكلاود)
        // is_deleted == 0 && isnotsync == 1
        else if (record['is_deleted'] == 0) {
          Map<String, dynamic> cloudData = Map.from(record);
          cloudData.remove('isnotsync'); // حقل لوكال بس

          // ارفع لفايربيز
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('books')
              .doc(id)
              .set(cloudData, SetOptions(merge: true));

          // لو نجح، رجع الحالة لـ متزامن (0)
          await db.update(
            'books',
            {'isnotsync': 0},
            where: 'id = ?',
            whereArgs: [id],
          );
          // print('☁️✅ تم المزامنة: رفع الكتاب $id للسيرفر');
        }
      } catch (e) {
        // لو النت فصل، هيفضل isnotsync = 1 للمرة الجاية
        // print('⚠️ فشل مزامنة $id: $e');
      }
    }
  }

  Future<void> fetchFromCloud() async {
    String uid = Get.find<ShowPasswordController>().currentUserId;

    try {
      // 1. جلب البيانات من فايربيز
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('books')
          .get();

      final db = await database;
      //print('☁️📥 جلب ${snapshot.docs.length} كتاب من الكلاود للموبايل');
      await db.delete('books');


      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();

        // 2. إعداد البيانات للـ SQL المحلي
        // نضع isnotsync = 0 لأنها قادمة من السيرفر فهي متزامنة بالفعل
        data['isnotsync'] = 0;
        data['is_deleted'] = 0;

        // 3. استخدام insert مع ConflictAlgorithm.ignore
        // عشان لو الكتاب موجود أصلاً ميكررش البيانات
        await db.insert(
          'books',
          data,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 4. تحديث الواجهة بعد تحميل البيانات الجديدة
      
      await getData(database, 'books');
      books.refresh();
     // print('✅ ${books.length} تم جلب البيانات من الكلاود وتحديث الشاشة بنجاح'); ;



      //print("☁️📥 تم جلب ${snapshot.docs.length} كتاب من الكلاود للموبايل");
    } catch (e) {
      //print("❌ فشل جلب البيانات من الكلاود: $e");
    }
  }
}
