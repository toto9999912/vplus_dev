import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vplus_dev/core/service/token_service.dart';
import 'package:vplus_dev/shared/enum/backend_type.dart';
import 'package:vplus_dev/shared/models/api_response.dart';
import 'middleware/error_interceptor.dart';
import 'middleware/logging_interceptor.dart';

class ApiClient {
  final BackendType backendType;
  final TokenService tokenService;
  late final Dio _client;

  ApiClient(this.backendType, {required this.tokenService}) {
    // 在建構函式體中初始化_client，而不是在宣告時初始化
    _client = Dio(
      BaseOptions(
        baseUrl: '${backendType.url}/api/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 40),
        responseType: ResponseType.json,
      ),
    );
    _client.interceptors.add(LoggingInterceptor());
    _client.interceptors.add(ErrorInterceptor(tokenService: tokenService));
  }

  Map<String, dynamic> createHeaders({Map<String, String>? headers, bool withToken = false}) {
    headers = headers ?? {};

    if (withToken) {
      headers['Authorization'] = 'Bearer ${tokenService.accessToken}';
    }

    debugPrint('header: ${headers.toString()}');

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    required T Function(Object?) fromJsonT,
    bool withToken = false,
  }) async {
    try {
      final response = await _client.get(
        path,
        queryParameters: params,
        options: Options(headers: createHeaders(headers: headers, withToken: withToken)),
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } catch (e) {
      debugPrint('get error: $e');
      rethrow;
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? params,
    dynamic body,
    Map<String, String>? headers,
    required T Function(Object?) fromJsonT,
    bool withToken = false,
  }) async {
    final response = await _client.post(
      path, // 同上
      queryParameters: params,
      data: body,
      options: Options(headers: createHeaders(headers: headers, withToken: withToken)),
    );
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  Future<ApiResponse<T?>> put<T>(
    String path, {
    Map<String, dynamic>? params,
    dynamic body,
    Map<String, String>? headers,
    T? Function(Object?)? fromJsonT,
    bool withToken = false,
  }) async {
    final response = await _client.put(
      path, // 同上
      queryParameters: params,
      data: body,
      options: Options(headers: createHeaders(headers: headers, withToken: withToken)),
    );
    if (fromJsonT == null) {
      return ApiResponse(code: response.data?['code'] ?? "0", message: response.data?['message'] ?? "success", data: null);
    } else {
      return ApiResponse.fromJson(response.data, fromJsonT);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? params,
    dynamic body,
    Map<String, String>? headers,
    required T Function(Object?) fromJsonT,
    bool withToken = false,
  }) async {
    final response = await _client.delete(
      path, // 同上
      queryParameters: params,
      data: body,
      options: Options(headers: createHeaders(headers: headers, withToken: withToken)),
    );
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  /// 用於表單資料上傳（包括檔案上傳）的方法
  /// [path] API路徑
  /// [data] FormData 格式的資料
  /// [queryParameters] URL查詢參數
  /// [headers] 自定義標頭
  /// [onSendProgress] 發送進度回調
  /// [onReceiveProgress] 接收進度回調
  /// [withToken] 是否需要授權令牌
  Future<Response> postForm(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool withToken = true,
  }) async {
    try {
      final response = await _client.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: createHeaders(headers: headers, withToken: withToken)),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      debugPrint('postForm error: $e');
      rethrow;
    }
  }
}
