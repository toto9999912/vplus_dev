/// 表單驗證器集合
class FormValidators {
  /// 電子郵件驗證
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子郵件';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return '請輸入有效的電子郵件格式';
    }
    
    return null;
  }

  /// 手機號碼驗證
  static String? mobile(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入手機號碼';
    }
    
    // 台灣手機號碼格式：09開頭，總長度10位
    final mobileRegex = RegExp(r'^09\d{8}$');
    if (!mobileRegex.hasMatch(value)) {
      return '請輸入有效的手機號碼格式 (09xxxxxxxx)';
    }
    
    return null;
  }

  /// 密碼驗證
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    
    if (value.length < minLength) {
      return '密碼長度至少需要 $minLength 個字元';
    }
    
    return null;
  }

  /// 強密碼驗證
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    
    if (value.length < 8) {
      return '密碼長度至少需要 8 個字元';
    }
    
    // 檢查是否包含大寫字母
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return '密碼必須包含至少一個大寫字母';
    }
    
    // 檢查是否包含小寫字母
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return '密碼必須包含至少一個小寫字母';
    }
    
    // 檢查是否包含數字
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '密碼必須包含至少一個數字';
    }
    
    // 檢查是否包含特殊字符
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return '密碼必須包含至少一個特殊字符';
    }
    
    return null;
  }

  /// 確認密碼驗證
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return '請確認密碼';
    }
    
    if (value != originalPassword) {
      return '密碼不一致';
    }
    
    return null;
  }

  /// 必填欄位驗證
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '此欄位'}為必填';
    }
    return null;
  }

  /// 數字驗證
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? '此欄位'}為必填';
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? '此欄位'}必須為數字';
    }
    
    return null;
  }

  /// 整數驗證
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? '此欄位'}為必填';
    }
    
    if (int.tryParse(value) == null) {
      return '${fieldName ?? '此欄位'}必須為整數';
    }
    
    return null;
  }

  /// 長度限制驗證
  static String? length(String? value, {int? min, int? max, String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? '此欄位'}為必填';
    }
    
    if (min != null && value.length < min) {
      return '${fieldName ?? '此欄位'}長度不能少於 $min 個字元';
    }
    
    if (max != null && value.length > max) {
      return '${fieldName ?? '此欄位'}長度不能超過 $max 個字元';
    }
    
    return null;
  }

  /// 組合驗證器
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}