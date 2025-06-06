/// 型別安全工具類
class TypeSafetyUtils {
  /// 安全轉換為字串
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// 安全轉換為整數
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    
    return defaultValue;
  }

  /// 安全轉換為雙精度浮點數
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    
    return defaultValue;
  }

  /// 安全轉換為布林值
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
    }
    
    return defaultValue;
  }

  /// 安全轉換為 DateTime
  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      // 假設是 Unix 時間戳（毫秒）
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// 安全轉換為列表
  static List<T> safeList<T>(dynamic value, T Function(dynamic) converter) {
    if (value == null) return <T>[];
    
    if (value is List) {
      return value.map((item) {
        try {
          return converter(item);
        } catch (e) {
          return null;
        }
      }).where((item) => item != null).cast<T>().toList();
    }
    
    return <T>[];
  }

  /// 安全獲取 Map 中的值
  static T? safeMapValue<T>(Map<String, dynamic>? map, String key, {T? defaultValue}) {
    if (map == null || !map.containsKey(key)) return defaultValue;
    
    final value = map[key];
    if (value is T) return value;
    
    return defaultValue;
  }

  /// 安全執行可能拋出異常的操作
  static T? safeTry<T>(T Function() operation, {T? defaultValue}) {
    try {
      return operation();
    } catch (e) {
      return defaultValue;
    }
  }

  /// 驗證並轉換 JSON 資料
  static Map<String, dynamic> validateJsonMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    
    if (json is Map) {
      // 轉換為 Map<String, dynamic>
      return Map<String, dynamic>.from(json);
    }
    
    throw ArgumentError('Invalid JSON data: expected Map<String, dynamic>');
  }

  /// 檢查字串是否為有效的非空值
  static bool isValidString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// 檢查列表是否為有效的非空值
  static bool isValidList<T>(List<T>? list) {
    return list != null && list.isNotEmpty;
  }

  /// 檢查 Map 是否為有效的非空值
  static bool isValidMap<K, V>(Map<K, V>? map) {
    return map != null && map.isNotEmpty;
  }
}