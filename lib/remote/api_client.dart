import 'package:dio/dio.dart';

class ApiClient {
  static late Dio dio;
  static init() {
    dio = Dio(
      BaseOptions(receiveDataWhenStatusError: true,
        baseUrl:
            "https://www.googleapis.com/books/v1", // عدل الرابط حسب الـ API
      ),
    );
  }

 

  Future<Response> getData({
    required String url,
    required Map<String,dynamic> query,
  }) async {
    return await dio.get(url,queryParameters: query);
  }

  //Dio get dio => _dio; // إتاحة Dio للاستخدام في باقي المشروع
}
