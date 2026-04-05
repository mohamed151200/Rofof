import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_dark_knight_final/controller/connectivity_controller.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:the_dark_knight_final/remote/api_client.dart';
import 'package:the_dark_knight_final/shared/secrets.dart';


enum LoadSource { author, publisher, category, search, none,genre }
class   Homecrt extends GetxController {
  // 1. المتغيرات المرصودة
  var results = <BookModel>[].obs;
  var search = [].obs;
  var simi = [].obs;
  var art = [].obs;
  var history = [].obs;
  var programming = [].obs;
  var science = [].obs;
  var suggestions = <String>[].obs;
  var index = 0.obs;
  var isSearching = false.obs;
  var genreBooks = <BookModel>[].obs;
  var authorBooks = <BookModel>[].obs;
   var titles = [
    '7',
     '8',
      '9',
       '10'
  ];


  
  

  var currentGenre = "".obs;
  var genreStartIndex = 0;

  var lastQuery = "".obs;
  var isFetchingMore = false.obs;
  // عداد بسيط لتتبع عدد مرات التمرير لأسفل
  ScrollController scrollController = ScrollController();
  //final Sqlcrt crt = Get.find<Sqlcrt>();

  
  var scrollCounter = 0.obs; 
  var startIndex = 0.obs;   //1
  var searchQuery =''.obs;     //2
  var typeofmethod = LoadSource.none.obs;  //3  

  // قائمة الكتب التي سيتم عرضها
  var booksList = <BookModel>[].obs;

  // 2. ميثود التصفير الشامل
  void resetPagination() {
    startIndex.value = 0;
    scrollCounter.value = 0;
    searchQuery.value = "";
    typeofmethod.value = LoadSource.none;
    genreBooks.clear(); // مسح البيانات القديمة ضروري جداً علمياً
  }

  // 2. الـ API Key في مكان واحد عشان لو اتغير
  final String _apiKey = Secrets.googleBooksApiKey;

  // 3. ميثود واحدة ذكية بتخدم على كله (General Fetch Method)
  changeIndex(int i) {
    index.value = i;
  }

  void toggleSearching() {
    if (lastQuery.value.trim().isEmpty) {
      isSearching.value = false;
    } else {
      isSearching.value = true;
    }
  }

  //__________________________________________________

  @override
  void onInit() {
  getArt();
  getHistory();
  getprogramming();
  getscience();
  setupDebounce();

    
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        scrollCounter.value++;
        loadMoreBooks();
      }
    });
    super.onInit();
  }

  //__________________________________________________

  Future<void> loadGenreBooks(String genre) async {
    currentGenre.value = genre;
    scrollCounter.value=0;
    genreStartIndex = 0;
    genreBooks.value = await fetchBooks(genre);
  }

  //__________________________________________________

 void loadMoreBooks() async {
    // 1. صمامات الأمان (Guards)
    // منع الطلب إذا كان: جاري التحميل، أو لا يوجد استعلام، أو تجاوزنا العداد (3 مرات)
    if (isFetchingMore.value || searchQuery.value.isEmpty || scrollCounter.value > 2) {
      return;
    }

    isFetchingMore.value = true;
    // زيادة الـ Index بمقدار 10 تمهيداً للطلب القادم
    startIndex.value += 10; 

    try {
      // 2. بناء جملة الاستعلام (Dynamic Query Construction)
      // العلم وراء API جوجل للكتب يعتمد على بادئات مثل subject أو inauthor
      String finalQ = "";
      switch (typeofmethod.value) {
        case LoadSource.genre:
          finalQ = "subject:${searchQuery.value}";
          break;
        case LoadSource.author:
          finalQ = "inauthor:${searchQuery.value}";
          break;
        case LoadSource.publisher:
          finalQ = "inpublisher:${searchQuery.value}";
          break;
        case LoadSource.search:
          finalQ = searchQuery.value;
          break;
        default:
          finalQ = searchQuery.value;
      }

      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          'q': finalQ,
          'key': _apiKey,
          'startIndex': startIndex.value,
          'maxResults': 10,
          'maxAllowedMaturityRating': 'not-mature',
        },
      );

      if (response.statusCode == 200 && response.data['items'] != null) {
        List items = response.data['items'];
        
        // تحويل البيانات وإضافتها للقائمة الحالية
        genreBooks.addAll(items.map((e) => BookModel.fromJson(e)).toList());
        
        // 3. تحديث العداد بعد نجاح العملية (Success Increment)
        scrollCounter.value++;
      }
    } catch (e) {
      // معالجة الخطأ علمياً لضمان عدم تعليق التطبيق
      //print("Error in loadMoreBooks: $e");
    } finally {
      isFetchingMore.value = false;
    }
  }

  //__________________________________________________

  void setupDebounce() {
    // هنا تحط الـ debounce اللي لسه شارحينه
    debounce(
      lastQuery,
      (_) => getSuggestions(),
      time: Duration(milliseconds: 500),
    );
  }
  //__________________________________________________
  bool isArabic(String text) {
  // ده "الكود السحري" اللي بيشوف لو النص فيه حروف عربي
  return RegExp(r'^[\u0600-\u06FF]').hasMatch(text);
}

  Future<List<BookModel>> fetchBooks(String query) async {
    final Sqlcrt crt = Get.find<Sqlcrt>();
      
    try {
      // لو الكلمة فيها حروف عربي، ابعتها query عادية من غير subject
//String finalUrl = isArabic(query) ? query : "subject:$query";
      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          "q": "subject:$query",
          "key": _apiKey,
          "maxResults": 10,
        },
      );

      if (response.data["items"] != null) {
        List items = response.data["items"];
        //print('Fetched ${items.length} items for_____+__________+_______+ query: $query');
        crt.clearCategoryData(query); 
        //print('Cleared all data for query: $query'); // مسح البيانات القديمة في الـ DB قبل الحفظ الجديد
        crt.saveToOffline(items, query); // حفظ البيانات الجديدة في الـ DB  
        // هنا السحر: تحويل الـ Maps لـ Objects فوراً
        //print('${items.length} items fetched __________________for query: $query');
        
        return items.map((e) => BookModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
     return crt.fetchFromOffline(query);
       
    

    }
  }

  //__________________________________________________
  Future<void> fetchAuthors(String query) async {
    genreBooks.clear();
    currentGenre.value=query;
    genreStartIndex = 0;


    try {
      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          "q": 'inauthor:"$query"',
          "key": _apiKey,
          "maxResults": 10,
        },
      );
      //Get.to(SplashScreen());
      if (response.data["items"] != null) {
        List items = response.data["items"];
        // هنا السحر: تحويل الـ Maps لـ Objects فوراً
        genreBooks.assignAll(items.map((e) => BookModel.fromJson(e)).toList());
      }
    } catch (e) {
    }

  }

  //___________________________________________________________
  Future<void> fetchResults(String query) async {
    try {
      currentGenre.value = query; // ← عشان loadMore يعرف يكمل
      scrollCounter.value = 0; // ← reset
      genreStartIndex = 0;

      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          "q": query,
          "key": _apiKey,
          "maxResults": 10,
          'orderBy': "relevance",
        },
      );
      if (response.data["items"] != null) {
        List items = response.data["items"];
        genreBooks.value = items.map((e) => BookModel.fromJson(e)).toList();
      } else {
        genreBooks.clear();
      }
    } catch (e) {
      genreBooks.clear();
    }
  }

  //___________________________________________________________
  Future<List<BookModel>> fetchPublisher(String query) async {
    try {
      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          "q": "inpublisher:$query",
          "key": _apiKey,
          "maxResults": 10,
          'orderBy': 'newest',
        },
      );

      if (response.data["items"] != null) {
        List items = response.data["items"];
        // هنا السحر: تحويل الـ Maps لـ Objects فوراً
        return items.map((e) => BookModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  //___________________________________________________________

  void getSuggestions() async {
    String query = lastQuery.value.trim();
    try {
      var response = await ApiClient().getData(
        url: "/volumes",
        query: {
          "q":
              "inauthor:$query+intitle:$query", // هنا السحر! "intitle:" بتخلي جوجل يدور في العناوين بس
          // قلل العدد لـ 7 عشان الزحمة في الـ UI
          "projection": "lite",
          "printType": "books",
          "key": _apiKey,
        },
      );

      if (response.data['items'] != null) {
        List items = response.data['items'];

        var uniqueTitles = items
            .map((item) => item['volumeInfo']['title'].toString())
            .toSet()
            .toList();

        suggestions.assignAll(uniqueTitles);
      }
    } catch (e) {
     /// print('Error fetching suggestions_____________________: $e');
     // print(suggestions);
    }
  }

  //__________________________________________________

  // 4. الميثودز بقت سطر واحد!
  // void searchBook() async
  // {
  //    search.value = await _fetchResults(lastQuery.value);
  //   print('Search results count: ${lastQuery.value}_______________');

  // }
  similarBooks(String query) async {
    // simi.value = await _fetchBooks(query);

    //return simi.assignAll(await _fetchBooks(query));
    var seme = await fetchBooks(query);
    return seme;
  }

  void getArt() async => art.value = await fetchBooks("novels");
  void getHistory() async => history.value = await fetchBooks("history");
  void getprogramming() async =>
      programming.value = await fetchBooks("programming");
  void getscience() async => science.value = await fetchBooks("physics");
}

/*import 'package:flutter_application_1_new/remote/api_client.dart';
import 'package:get/get.dart';
class Homecrt extends GetxController 
{
  var search=[].obs;
  var simi=[].obs;
  var art=[].obs;
  var history=[].obs;
  var programming =[].obs;
  var science =[].obs;

  void searchBook(String query)
  {
    ApiClient().getData(url: "/volumes", query: {"q": query})
    .then((value) 
    {
      search.value=value.data["items"];
    });
    print(search);
    
  }
   void similarBooks(String query)
  {
    ApiClient().getData(url: "/volumes", query: {"q": query})
    .then((value) 
    {
      simi.value=value.data["items"];
    });
    print(search);
    
  }
  void getArt()
  {
    
    ApiClient().getData(url: "/volumes", query: {
      "q": "art",
      "key":"AIzaSyCcMV7VKILWQTQof-YYmswiYBHSMjRN8A0"
 })
    .then((value) 
    {
      art.value=value.data["items"];
    });
    print(art);
    
  }
 void getHistory()
  {
    ApiClient().getData(url: "/volumes", query: {
      "q": "history",
      "key":"AIzaSyCcMV7VKILWQTQof-YYmswiYBHSMjRN8A0"
 })
    .then((value) 
    {
      history.value=value.data["items"];
    });
    print(history);
    
  }
 void getprogramming()
  {
    ApiClient().getData(url: "/volumes", query: {
      "q": "programming",
      "key":"AIzaSyCcMV7VKILWQTQof-YYmswiYBHSMjRN8A0"
 })
    .then((value) 
    {
      programming.value=value.data["items"];
    });
    print(programming);
    
  }
 void getscience()
  {
    ApiClient().getData(url: "/volumes", query: {
      "q": "self development",
      "key":"AIzaSyCcMV7VKILWQTQof-YYmswiYBHSMjRN8A0"
 })
    .then((value) 
    {
      science.value=value.data["items"];
    });
    print(science);
    
  }
}*/
