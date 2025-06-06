import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../service/token_service.dart';

/// HTTP 錯誤攔截器
///
/// 負責處理所有 HTTP 請求的錯誤回應，包括：
/// - 401 未授權錯誤的自動處理
/// - Token 刷新機制
/// - 通用錯誤訊息顯示
/// - 網絡連接錯誤處理
class ErrorInterceptor extends Interceptor {
  final TokenService _tokenService;

  // 用於防止重複刷新 token 的標記
  bool _isRefreshing = false;

  // 儲存等待 token 刷新完成的請求
  final List<RequestOptions> _pendingRequests = [];

  ErrorInterceptor({required TokenService tokenService}) : _tokenService = tokenService;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('❌ ErrorInterceptor: ${err.response?.statusCode} - ${err.message}');

    // 根據錯誤類型進行處理
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _handleTimeoutError(err);
        break;

      case DioExceptionType.connectionError:
        _handleConnectionError(err);
        break;

      case DioExceptionType.badResponse:
        await _handleBadResponse(err, handler);
        return; // 重要：避免繼續執行 handler.next(err)

      case DioExceptionType.cancel:
        debugPrint('❌ 請求被取消');
        break;

      case DioExceptionType.unknown:
      default:
        _handleUnknownError(err);
        break;
    }

    // 繼續傳遞錯誤
    handler.next(err);
  }

  /// 處理 HTTP 回應錯誤
  Future<void> _handleBadResponse(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response == null) {
      _showGenericError('伺服器回應錯誤');
      handler.next(err);
      return;
    }

    switch (response.statusCode) {
      case 400:
        _handleBadRequestError(response);
        break;

      case 401:
        // 處理未授權錯誤，嘗試刷新 token
        final refreshResult = await _handleUnauthorizedError(err, handler);
        if (refreshResult) {
          return; // Token 刷新成功，請求已重新發送
        }
        break;

      case 403:
        _handleForbiddenError(response);
        break;

      case 404:
        _handleNotFoundError(response);
        break;

      case 422:
        _handleValidationError(response);
        break;

      case 429:
        _handleRateLimitError(response);
        break;

      case 500:
      case 502:
      case 503:
      case 504:
        _handleServerError(response);
        break;

      default:
        _handleGenericHttpError(response);
        break;
    }

    handler.next(err);
  }

  /// 處理 401 未授權錯誤
  Future<bool> _handleUnauthorizedError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('❌ 401 未授權錯誤，嘗試刷新 Token');

    // 如果正在刷新 token，將請求加入等待列表
    if (_isRefreshing) {
      _pendingRequests.add(err.requestOptions);
      return true; // 表示請求會被重新處理
    }

    // 檢查是否有 refresh token
    if (_tokenService.refreshToken == null || _tokenService.refreshToken!.isEmpty) {
      debugPrint('❌ 沒有 Refresh Token，導向登入頁面');
      _redirectToLogin();
      return false;
    }

    _isRefreshing = true;

    try {
      // 嘗試刷新 token
      final success = await _refreshToken();

      if (success) {
        debugPrint('✅ Token 刷新成功，重新發送原始請求');

        // 重新發送原始請求
        final newResponse = await _retryRequest(err.requestOptions);
        handler.resolve(newResponse);

        // 重新發送等待中的請求
        await _retryPendingRequests();

        return true;
      } else {
        debugPrint('❌ Token 刷新失敗，導向登入頁面');
        _redirectToLogin();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token 刷新過程中發生錯誤: $e');
      _redirectToLogin();
      return false;
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  /// 刷新 Access Token
  Future<bool> _refreshToken() async {
    try {
      // 這裡需要根據你的 API 來實作 token 刷新邏輯
      // 由於你的程式碼中沒有看到具體的刷新 API，這裡提供一個範例

      final dio = Dio();
      final response = await dio.post('${_getBaseUrl()}/auth/refresh', data: {'refreshToken': _tokenService.refreshToken});

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String?;

        // 更新 token
        await _tokenService.saveToken(accessToken: newAccessToken, refreshToken: newRefreshToken ?? _tokenService.refreshToken!);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Token 刷新 API 呼叫失敗: $e');
      return false;
    }
  }

  /// 重新發送請求
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // 更新請求的 Authorization header
    requestOptions.headers['Authorization'] = 'Bearer ${_tokenService.accessToken}';

    final dio = Dio();
    return await dio.fetch(requestOptions);
  }

  /// 重新發送等待中的請求
  Future<void> _retryPendingRequests() async {
    for (final requestOptions in _pendingRequests) {
      try {
        await _retryRequest(requestOptions);
      } catch (e) {
        debugPrint('❌ 重新發送等待請求失敗: $e');
      }
    }
  }

  /// 導向登入頁面
  void _redirectToLogin() {
    // 清除所有 token
    _tokenService.clearTokens();

    // 這裡需要導向登入頁面，你可以根據你的路由系統來實作
    // 例如使用 AutoRouter
    // _ref.read(appRouterProvider).replaceAll([const LoginRoute()]);

    _showError(
      '登入已過期',
      '您的登入狀態已過期，請重新登入。',
      onOk: () {
        // 導向登入頁面的邏輯
      },
    );
  }

  /// 處理 400 錯誤
  void _handleBadRequestError(Response response) {
    final message = _extractErrorMessage(response) ?? '請求參數錯誤';
    _showError('請求錯誤', message);
  }

  /// 處理 403 錯誤
  void _handleForbiddenError(Response response) {
    final message = _extractErrorMessage(response) ?? '您沒有權限執行此操作';
    _showError('權限不足', message);
  }

  /// 處理 404 錯誤
  void _handleNotFoundError(Response response) {
    final message = _extractErrorMessage(response) ?? '請求的資源不存在';
    _showError('資源不存在', message);
  }

  /// 處理 422 驗證錯誤
  void _handleValidationError(Response response) {
    final message = _extractErrorMessage(response) ?? '輸入資料格式錯誤';
    _showError('驗證失敗', message);
  }

  /// 處理 429 請求頻率限制錯誤
  void _handleRateLimitError(Response response) {
    _showError('請求過於頻繁', '您的請求過於頻繁，請稍後再試。');
  }

  /// 處理伺服器錯誤 (5xx)
  void _handleServerError(Response response) {
    final statusCode = response.statusCode;
    String message;

    switch (statusCode) {
      case 500:
        message = '伺服器內部錯誤，請稍後再試';
        break;
      case 502:
        message = '伺服器連接錯誤，請稍後再試';
        break;
      case 503:
        message = '服務暫時無法使用，請稍後再試';
        break;
      case 504:
        message = '伺服器回應超時，請稍後再試';
        break;
      default:
        message = '伺服器錯誤，請稍後再試';
    }

    _showError('伺服器錯誤', message);
  }

  /// 處理通用 HTTP 錯誤
  void _handleGenericHttpError(Response response) {
    final message = _extractErrorMessage(response) ?? '發生未知錯誤';
    _showError('請求失敗', message);
  }

  /// 處理連接超時錯誤
  void _handleTimeoutError(DioException err) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '連接伺服器超時，請檢查網路連接';
        break;
      case DioExceptionType.sendTimeout:
        message = '發送請求超時，請重試';
        break;
      case DioExceptionType.receiveTimeout:
        message = '伺服器回應超時，請重試';
        break;
      default:
        message = '請求超時，請重試';
    }

    _showError('連接超時', message);
  }

  /// 處理網絡連接錯誤
  void _handleConnectionError(DioException err) {
    _showError('網絡錯誤', '無法連接到伺服器，請檢查您的網路連接。');
  }

  /// 處理未知錯誤
  void _handleUnknownError(DioException err) {
    final message = err.message ?? '發生未知錯誤';
    _showError('錯誤', message);
  }

  /// 從回應中提取錯誤訊息
  String? _extractErrorMessage(Response response) {
    try {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // 嘗試從不同的欄位中提取錯誤訊息
        return data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];
      }

      if (data is String) {
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('❌ 提取錯誤訊息失敗: $e');
      return null;
    }
  }

  /// 顯示錯誤對話框
  void _showError(String title, String message, {VoidCallback? onOk}) {
    try {} catch (e) {
      debugPrint('❌ 顯示錯誤對話框失敗: $e');
      // 如果對話框服務失敗，至少在控制台記錄錯誤
      debugPrint('❌ $title: $message');
    }
  }

  /// 顯示通用錯誤訊息
  void _showGenericError(String message) {
    _showError('錯誤', message);
  }

  /// 獲取基礎 URL
  String _getBaseUrl() {
    // 這裡需要根據你的配置來回傳正確的基礎 URL
    // 可以從 FlavorConfig 或其他配置來源獲取
    return 'http://your-api-base-url.com';
  }
}
