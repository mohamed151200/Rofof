import 'package:flutter/material.dart';
import 'package:the_dark_knight_final/module/Fav/Fav_widget.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:the_dark_knight_final/controller/api_controller.dart';
import 'package:the_dark_knight_final/controller/sql_controller.dart';
import 'package:the_dark_knight_final/models/bookModel.dart';
import 'package:the_dark_knight_final/shared/components.dart';
import 'package:get/get.dart';

class Results extends StatelessWidget {
  var lst;
  final String genre;
  

    Results({ this.lst, required this.genre, super.key});
  
   Homecrt crt = Get.find();
   Sqlcrt sql = Get.find();
    //1 

  @override
  Widget build(BuildContext context) {
    // ScrollController للـ load more
    final scrollController = ScrollController();
    lst = crt.genreBooks;
    
    
    // Listener للـ load more
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
          crt.scrollCounter.value++;          
          crt.loadMoreBooks();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(crt.searchQuery.value))),
      body: Obx(() {
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          controller: scrollController,
          itemCount: lst.length + 1, // +1 للـ loading indicator
          itemBuilder: (context, i) {
            // آخر item = loading indicator
            if (i == lst.length) {
              return Obx(() => crt.isFetchingMore.value
                ? const Padding(
                     padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink(),
              );
            }

            var item = lst[i];
            return Container(
              padding: const EdgeInsets.symmetric( vertical: 5),
              child: FavCard(item: item, crt: sql ));
          },
        );
      }),
    );
  }
}