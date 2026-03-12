import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/api_controller.dart';

class MyBooks_page extends StatelessWidget {
  TextEditingController c1 = TextEditingController();

  MyBooks_page({super.key});
  @override
  Widget build(BuildContext context) {
    Sqlcrt sql = Get.find<Sqlcrt>();
    
    // ThemeController theme =Get.put(ThemeController());
    return Scaffold(
        appBar: AppBar(title: const Text('My Books')),
        body: Column(
          children: [
            
            Expanded(
              child: 
              GetX<Homecrt>(
                builder: (_) => 
             ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount:sql.books.length,
                            itemBuilder: (context, i) {

                              return SizedBox(
                                height: 410,
                                child: card(
                                  map: sql.books[i],
                                  image:sql.books[i]['volumeInfo']?['imageLinks']?['smallThumbnail']??'https://via.placeholder.com/150',
 
                                name: sql.books[i]['volumeInfo']?['title']??'no name',
                                autherName:  sql.books[i]['volumeInfo']?['authors']?.isNotEmpty == true ? sql.books[i]['volumeInfo']['authors'][0] : 'Unknown Author',
                                price: sql.books[i]['saleInfo']?['listPrice']?['amount'].toString() ?? ""),
                              );})
             ) // 
            )
          ],
        ),
        
        );
  }
}
