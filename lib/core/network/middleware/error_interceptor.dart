import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 在這裡處理錯誤
    print('Error occurred: ${err.message}');
    super.onError(err, handler);
  }
}
