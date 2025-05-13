import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint("🔍 發出請求: ${options.method} ${options.uri}");
    debugPrint("🔍 請求模型: ${options.data}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("✅ 成功回應: ${response.statusCode}");
    debugPrint("回應模型: ${response.data}");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint("❌ 錯誤代碼: ${err.response?.statusCode}");
    debugPrint("❌ 錯誤數據: ${err.response?.data}");

    handler.next(err);
  }
}
