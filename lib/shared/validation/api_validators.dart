import '../models/api_response.dart';

/// API 回應驗證器
class ApiValidators {
  /// 驗證 API 回應是否成功
  static bool isSuccess(ApiResponse response) {
    // 根據你的 API 規範調整成功代碼判斷
    return response.code == "0" || response.code == "200" || response.code == "success";
  }

  /// 驗證 API 回應資料是否為空
  static bool hasData<T>(ApiResponse<T> response) {
    return response.data != null;
  }

  /// 驗證列表資料是否為空
  static bool hasListData<T>(ApiResponse<List<T>> response) {
    return response.data != null && response.data!.isNotEmpty;
  }

  /// 安全地獲取 API 回應資料
  static T? safeGetData<T>(ApiResponse<T> response) {
    if (isSuccess(response) && hasData(response)) {
      return response.data;
    }
    return null;
  }

  /// 安全地獲取列表資料
  static List<T> safeGetListData<T>(ApiResponse<List<T>> response) {
    if (isSuccess(response) && hasListData(response)) {
      return response.data!;
    }
    return <T>[];
  }

  /// 獲取錯誤訊息
  static String getErrorMessage(ApiResponse response) {
    if (!isSuccess(response)) {
      return response.message.isNotEmpty ? response.message : '請求失敗';
    }
    return '';
  }

  /// 驗證必要參數
  static void validateRequiredParams(Map<String, dynamic> params, List<String> requiredKeys) {
    for (final key in requiredKeys) {
      if (!params.containsKey(key) || params[key] == null) {
        throw ArgumentError('必要參數 $key 不能為空');
      }
    }
  }

  /// 驗證 ID 參數
  static void validateId(int? id, {String fieldName = 'ID'}) {
    if (id == null || id <= 0) {
      throw ArgumentError('$fieldName 必須是正整數');
    }
  }

  /// 驗證分頁參數
  static Map<String, int> validatePaginationParams({int? page, int? limit}) {
    final validatedPage = (page != null && page > 0) ? page : 1;
    final validatedLimit = (limit != null && limit > 0 && limit <= 100) ? limit : 20;
    
    return {
      'page': validatedPage,
      'limit': validatedLimit,
    };
  }
}